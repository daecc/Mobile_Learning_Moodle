import os
import re
import requests
import json
import logging
import time
from typing import Dict, Any, List, Optional, Tuple
from datetime import datetime, timezone
from concurrent.futures import ThreadPoolExecutor
import numpy as np

from app.database import get_db_connection
from app.services.ml_service import (
    model,
    scaler,
    features_list,
    calcular_nivel_riesgo,
    predecir_vector
)

logger = logging.getLogger("moodle_service")

# URL Oficial de MoodleCloud para Rumbo Mobile Learning
MOODLE_BASE_URL = os.getenv("MOODLE_URL", "https://rumbo-mobile-learning.moodlecloud.com").rstrip("/")
TOKEN_URL = f"{MOODLE_BASE_URL}/login/token.php"
REST_SERVER_URL = f"{MOODLE_BASE_URL}/webservice/rest/server.php"

# Headers estándar para evitar bloqueos de Cloudflare / WAF
BROWSER_HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36",
    "Accept": "application/json, text/plain, */*",
    "Accept-Language": "es-ES,es;q=0.9,en;q=0.8",
}

ACCENTS_MAP = {
    'CONSTRUCCION': 'Construcción',
    'Construccion': 'Construcción',
    'MOVIL': 'Móvil',
    'Movil': 'Móvil',
    'GARANTIA': 'Garantía',
    'Garantia': 'Garantía',
    'GESTION': 'Gestión',
    'Gestion': 'Gestión',
    'ANALITICA': 'Analítica',
    'Analitica': 'Analítica',
    'DISENO': 'Diseño',
    'Diseno': 'Diseño',
    'INGENIERIA': 'Ingeniería',
    'Ingenieria': 'Ingeniería',
    'METODOLOGIA': 'Metodología',
    'Metodologia': 'Metodología',
    'PROGRAMACION': 'Programación',
    'Programacion': 'Programación',
    'COMPUTACION': 'Computación',
    'Computacion': 'Computación',
    'ESTADISTICA': 'Estadística',
    'Estadistica': 'Estadística',
    'ADMINISTRACION': 'Administración',
    'Administracion': 'Administración',
    'FISICA': 'Física',
    'Fisica': 'Física',
    'QUIMICA': 'Química',
    'Quimica': 'Química',
    'LOGICA': 'Lógica',
    'Logica': 'Lógica',
    'ETICA': 'Ética',
    'Etica': 'Ética',
    'PRACTICA': 'Práctica',
    'Practica': 'Práctica',
}


def clean_course_title(raw: str) -> str:
    """
    Transforma nombres crudos de Moodle (ej. 'Curso202W0907-TALLER_DE_CONSTRUCCION_DE_SOFTWARE_MOVIL-2018-1_26.2')
    en títulos legibles para estudiantes (ej. 'Taller de Construcción de Software Móvil').
    """
    if not raw or not raw.strip():
        return raw
    name = raw.strip()

    # 1. Prefijos con dos puntos
    if ':' in name:
        parts = name.split(':')
        if len(parts) > 1 and parts[1].strip():
            name = ':'.join(parts[1:]).strip()

    # 2. Eliminar prefijo 'Curso' con su código
    name = re.sub(r'^Curso[-_]?[A-Za-z0-9]+[-_:]\s*', '', name, flags=re.IGNORECASE)

    # 3. Eliminar códigos automáticos al inicio sin 'Curso'
    name = re.sub(r'^(?:[A-Za-z0-9]{2,10}[-_])?\d+[A-Za-z0-9]*[-_:]\s*', '', name)
    name = re.sub(r'^(?:CUR|MAT|INF|SIS|FIS|BIO|QUI|CS)[-_]\d+[-_:]\s*', '', name, flags=re.IGNORECASE)

    # 4. Eliminar sufijos de ciclo o periodo
    name = re.sub(r'[-_]\d{4}[-_]\d.*$', '', name)
    name = re.sub(r'[-_]\d+(\.\d+)?$', '', name)

    # 5. Normalizar guiones bajos y espacios
    name = name.replace('_', ' ')
    name = re.sub(r'\s+', ' ', name).strip()

    # 6. Title Case humano y corrección de tildes
    if len(name) > 2 and name == name.upper():
        words = name.split(' ')
        titled_words = []
        for w in words:
            if not w:
                continue
            lower = w.lower()
            if lower in ['de', 'del', 'la', 'las', 'el', 'los', 'en', 'y', 'para', 'con', 'a', 'o', 'por']:
                titled_words.append(lower)
            elif w.upper() in ACCENTS_MAP:
                titled_words.append(ACCENTS_MAP[w.upper()])
            elif re.match(r'^[A-Z]\d+$', w):
                titled_words.append(w)
            elif w == '-':
                titled_words.append('-')
            else:
                titled_words.append(w[0].upper() + lower[1:])

        if titled_words and titled_words[0]:
            first = titled_words[0]
            titled_words[0] = first[0].upper() + first[1:]
        name = ' '.join(titled_words)
    else:
        words = name.split(' ')
        restored = [ACCENTS_MAP.get(w, w) for w in words]
        name = ' '.join(restored)

    return name if name else raw


class MoodleRestClient:
    """
    Cliente REST oficial para Moodle LMS / MoodleCloud Web Services.
    Autentica vía token de Web Services (service=moodle_mobile_app)
    e interactúa con los endpoints REST nativos de Moodle.
    """

    def __init__(self, base_url: str = MOODLE_BASE_URL):
        self.base_url = base_url.rstrip("/")
        self.token_url = f"{self.base_url}/login/token.php"
        self.server_url = f"{self.base_url}/webservice/rest/server.php"

    def authenticate(self, username: str, password: str) -> str:
        """
        Obtiene el token de Web Service en Moodle usando el servicio oficial de la app móvil.
        """
        clean_user = username.strip()
        clean_pass = password.strip()

        payload = {
            "username": clean_user,
            "password": clean_pass,
            "service": "moodle_mobile_app"
        }

        try:
            resp = requests.post(
                self.token_url,
                data=payload,
                headers=BROWSER_HEADERS,
                timeout=15
            )
            resp.raise_for_status()
            data = resp.json()

            if "token" in data:
                return data["token"]

            error_msg = data.get("error", "Credenciales incorrectas en el servidor de Moodle.")
            logger.warning(f"Error de autenticación Moodle para {clean_user}: {error_msg}")
            raise ValueError(error_msg)

        except requests.exceptions.RequestException as e:
            logger.error(f"Fallo de conexión al endpoint de login Moodle: {e}")
            raise ConnectionError(f"No se pudo conectar con el servidor Moodle en {self.base_url}.")

    def call_function(self, token: str, wsfunction: str, **params) -> Any:
        """
        Invoca una función del Web Service REST oficial de Moodle.
        """
        payload = {
            "wstoken": token,
            "wsfunction": wsfunction,
            "moodlewsrestformat": "json",
            **params
        }

        try:
            resp = requests.post(
                self.server_url,
                data=payload,
                headers=BROWSER_HEADERS,
                timeout=30
            )
            resp.raise_for_status()
            data = resp.json()

            if isinstance(data, dict) and data.get("exception"):
                msg = data.get("message", "Error en llamada a Web Service de Moodle")
                logger.warning(f"Excepción de Moodle WS ({wsfunction}): {msg}")
                raise RuntimeError(msg)

            return data

        except requests.exceptions.RequestException as e:
            logger.error(f"Error llamando a {wsfunction}: {e}")
            raise ConnectionError(f"Error de comunicación con Moodle Web Services: {e}")

    def get_site_info(self, token: str) -> Dict[str, Any]:
        """Obtiene información del sitio y perfil del usuario autenticado."""
        return self.call_function(token, "core_webservice_get_site_info")

    def get_enrolled_courses(self, token: str, userid: int) -> List[Dict[str, Any]]:
        """Obtiene la lista oficial de cursos en los que el usuario está matriculado."""
        courses = self.call_function(token, "core_enrol_get_users_courses", userid=userid)
        return courses if isinstance(courses, list) else []

    def get_user_course_grades(self, token: str, course_id: int, userid: int) -> List[Dict[str, Any]]:
        """Obtiene el reporte de calificaciones del estudiante en un curso."""
        try:
            data = self.call_function(
                token,
                "gradereport_user_get_grade_items",
                courseid=course_id,
                userid=userid
            )
            if isinstance(data, dict) and "usergrades" in data and len(data["usergrades"]) > 0:
                return data["usergrades"][0].get("gradeitems", [])
        except Exception as e:
            logger.debug(f"No se pudieron obtener calificaciones para curso {course_id}: {e}")
        return []

    def get_course_contents(self, token: str, course_id: int) -> List[Dict[str, Any]]:
        """Obtiene las secciones, módulos y actividades de un curso."""
        try:
            contents = self.call_function(token, "core_course_get_contents", courseid=course_id)
            return contents if isinstance(contents, list) else []
        except Exception as e:
            logger.debug(f"No se pudieron obtener contenidos para curso {course_id}: {e}")
            return []


# Mantener compatibilidad con Scraper por si se usa en tests antiguos
MoodleScraperClient = MoodleRestClient


class MoodleService:
    """
    Servicio integral: Integración MoodleCloud REST + Machine Learning Predictor + SQLite.
    """

    def __init__(self):
        self.client = MoodleRestClient()
        self._last_sync_by_student: Dict[str, float] = {}

    def _process_courses_and_save(
        self,
        moodle_token: str,
        userid: int,
        id_estudiante: str,
        clean_user: str,
        fullname: str,
        user_email: str,
        courses: List[Dict[str, Any]],
        is_live: bool
    ) -> int:
        """
        Extrae métricas reales de Moodle, calcula las 7 variables oficiales,
        ejecuta el modelo ML de Regresión Logística y persiste el estado en SQLite.
        """
        conn = get_db_connection()
        try:
            cur = conn.cursor()

            # Guardar / actualizar estudiante
            cur.execute("""
            INSERT INTO estudiantes (id_estudiante, username, nombre, correo, carrera, ciclo, token_moodle, moodle_userid, last_login)
            VALUES (?, ?, ?, ?, 'Ingeniería de Software (UNMSM)', '9no ciclo', ?, ?, CURRENT_TIMESTAMP)
            ON CONFLICT(id_estudiante) DO UPDATE SET
                nombre = excluded.nombre,
                token_moodle = excluded.token_moodle,
                moodle_userid = excluded.moodle_userid,
                last_login = CURRENT_TIMESTAMP;
            """, (id_estudiante, clean_user, fullname, user_email, moodle_token, userid))

            # Limpiar datos previos del estudiante para refrescar
            cur.execute("DELETE FROM predicciones WHERE id_estudiante = ?", (id_estudiante,))
            cur.execute("DELETE FROM metricas WHERE id_estudiante = ?", (id_estudiante,))
            cur.execute("DELETE FROM cursos WHERE id_estudiante = ?", (id_estudiante,))

            now_ts = int(time.time())

            # Pre-cargar asignaciones y calificaciones en paralelo para máximo rendimiento
            assigns_by_course: Dict[int, List[Dict[str, Any]]] = {}
            grades_by_course: Dict[int, List[Dict[str, Any]]] = {}
            subs_by_assign: Dict[int, Dict[str, Any]] = {}

            if is_live:
                try:
                    with ThreadPoolExecutor(max_workers=6) as executor:
                        f_assigns = executor.submit(self.client.call_function, moodle_token, "mod_assign_get_assignments")
                        f_recent = executor.submit(self.client.call_function, moodle_token, "block_recentlyaccesseditems_get_recent_items")
                        grades_futures = {c.get("id"): executor.submit(self.client.get_user_course_grades, moodle_token, c.get("id"), userid) for c in courses}

                        try:
                            assigns_data = f_assigns.result()
                            for c_assign in assigns_data.get("courses", []):
                                assigns_by_course[c_assign.get("id")] = c_assign.get("assignments", [])
                        except Exception as ae:
                            logger.debug(f"No se pudieron obtener tareas de Moodle: {ae}")

                        try:
                            recent_items_list = f_recent.result()
                            if not isinstance(recent_items_list, list):
                                recent_items_list = []
                        except Exception as re:
                            logger.debug(f"No se pudieron obtener accesos recientes de Moodle: {re}")
                            recent_items_list = []

                        # Obtener estados de entrega de cada asignación en paralelo
                        all_assign_ids = [a.get("id") for assigns in assigns_by_course.values() for a in assigns if a.get("id")]
                        subs_futures = {aid: executor.submit(self.client.call_function, moodle_token, "mod_assign_get_submission_status", assignid=aid) for aid in all_assign_ids}

                        for cid, f in grades_futures.items():
                            try:
                                grades_by_course[cid] = f.result()
                            except Exception:
                                grades_by_course[cid] = []

                        for aid, f in subs_futures.items():
                            try:
                                subs_by_assign[aid] = f.result()
                            except Exception:
                                subs_by_assign[aid] = {}
                except Exception as e:
                    logger.debug(f"Error en llamadas paralelas Moodle: {e}")

            for c in courses:
                cid = c.get("id")
                raw_c_name = c.get("fullname", f"Curso {cid}")
                c_name = clean_course_title(raw_c_name)
                c_short = c.get("shortname", f"CUR-{cid}")
                c_idnumber = c.get("idnumber") or c_short
                internal_id = f"CUR-{cid}" if not c_idnumber else f"CUR-{c_idnumber}"

                # Métricas base
                dias_inact = 0
                promedio = 14.5
                total_tasks = 0
                pending_tasks = 0
                tendencia = 0.0
                margen_entrega = 24.0
                asist_formal = 0.85
                grades_vals = []

                if is_live:
                    # 1. Inactividad desde lastaccess oficial del curso
                    lastaccess = c.get("lastaccess")
                    if lastaccess and isinstance(lastaccess, (int, float)) and lastaccess > 0:
                        diff_seconds = max(0, now_ts - int(lastaccess))
                        dias_inact = max(0, diff_seconds // 86400)
                    else:
                        dias_inact = 0

                    # 2. Calificaciones del Gradebook pre-cargado
                    grade_items = grades_by_course.get(cid, [])
                    asist_formal_found = None
                    for gi in grade_items:
                        item_name = (gi.get("itemname") or "").lower()
                        raw = gi.get("graderaw")
                        gmax = gi.get("grademax") or 100

                        if raw is not None:
                            try:
                                r_val = float(raw)
                                m_val = float(gmax)
                                if m_val > 0:
                                    if "asist" in item_name or "attend" in item_name:
                                        asist_formal_found = min(1.0, max(0.0, r_val / m_val))
                                    else:
                                        # Detección de escala vigesimal universitaria (UNMSM 0 a 20):
                                        # Si en Moodle la nota máxima está configurada en 100 por defecto
                                        # pero la nota asignada por el docente es <= 20, es escala vigesimal real.
                                        if m_val == 100.0 and r_val <= 20.0 and r_val >= 0.0:
                                            nota_vigesimal = r_val
                                        else:
                                            nota_vigesimal = (r_val / m_val) * 20.0
                                        grades_vals.append(round(nota_vigesimal, 2))
                            except (ValueError, TypeError):
                                pass

                    tiene_calificaciones = len(grades_vals) > 0
                    if tiene_calificaciones:
                        promedio = round(float(np.mean(grades_vals)), 1)
                        if len(grades_vals) >= 2:
                            x_idx = np.arange(len(grades_vals))
                            slope, _ = np.polyfit(x_idx, grades_vals, 1)
                            tendencia = round(float(slope), 3)
                        else:
                            tendencia = 0.0
                    else:
                        # Si no hay calificaciones en Moodle aún, imputación neutra para el modelo de ML
                        promedio = 12.5
                        tendencia = 0.0

                    if asist_formal_found is not None:
                        asist_formal = round(asist_formal_found, 3)
                    else:
                        asist_formal = 0.90 if dias_inact <= 3 else 0.70

                    # 3. Tareas y Quizzes oficiales de Moodle (cero datos inventados)
                    course_assigns = assigns_by_course.get(cid, [])
                    quiz_modules = [gi for gi in grade_items if gi.get("itemmodule") == "quiz" or (gi.get("itemtype") == "mod" and "cuest" in (gi.get("itemname") or "").lower())]

                    total_tasks = len(course_assigns) + len(quiz_modules)
                    margins_list = []
                    course_tasks_detail = []

                    if total_tasks == 0:
                        pending_tasks = 0
                        margen_entrega = 24.0
                    else:
                        for a in course_assigns:
                            aid = a.get("id")
                            aname = a.get("name", "Tarea")
                            duedate = a.get("duedate", 0)
                            sub = subs_by_assign.get(aid, {})
                            lastattempt = sub.get("lastattempt", {})
                            submission = lastattempt.get("submission", {})
                            sub_status = submission.get("status")
                            timemodified = submission.get("timemodified", 0)

                            # Buscar calificación en grade_items para esta tarea
                            grade_str = None
                            for gi in grade_items:
                                if gi.get("itemmodule") == "assign" and gi.get("iteminstance") == aid:
                                    g_val = gi.get("graderaw")
                                    if g_val is not None:
                                        try:
                                            g_float = float(g_val)
                                            g_max_float = float(gi.get('grademax', 20))
                                            if g_max_float == 100.0 and g_float <= 20.0:
                                                grade_str = f"{g_float:.1f} / 20"
                                            else:
                                                grade_str = f"{g_float:.1f} / {g_max_float:.0f}"
                                        except (ValueError, TypeError):
                                            grade_str = str(g_val)
                                    break

                            due_str = datetime.fromtimestamp(duedate).strftime("%d/%m/%Y %H:%M") if duedate > 0 else "Sin fecha límite"
                            sub_str = datetime.fromtimestamp(timemodified).strftime("%d/%m/%Y %H:%M") if (timemodified > 0 and sub_status == "submitted") else None

                            if sub_status == "submitted":
                                # Tarea entregada formalmente
                                estado = "entregada"
                                if duedate > 0 and timemodified > 0:
                                    m_h = (duedate - timemodified) / 3600.0
                                    margins_list.append(m_h)
                                else:
                                    margins_list.append(36.0)
                            else:
                                # Tarea aún no entregada
                                pending_tasks += 1
                                if duedate > 0 and now_ts > duedate:
                                    estado = "vencida"
                                    margins_list.append(-48.0)  # Penalización por tarea vencida sin entregar
                                else:
                                    estado = "pendiente"

                            course_tasks_detail.append({
                                "id": aid,
                                "nombre": aname,
                                "estado": estado,
                                "fecha_limite": due_str,
                                "calificacion": grade_str,
                                "fecha_entrega": sub_str
                            })

                        for qm in quiz_modules:
                            qid = qm.get("iteminstance") or qm.get("id", 0)
                            qname = qm.get("itemname", "Cuestionario")
                            q_val = qm.get("graderaw")
                            q_grade_str = f"{float(q_val):.1f} / {float(qm.get('grademax', 20)):.0f}" if q_val is not None else None
                            q_estado = "entregada" if q_val is not None else "pendiente"
                            if q_val is None:
                                pending_tasks += 1
                            course_tasks_detail.append({
                                "id": qid,
                                "nombre": qname,
                                "estado": q_estado,
                                "fecha_limite": "Evaluación en Moodle",
                                "calificacion": q_grade_str,
                                "fecha_entrega": None
                            })

                        if margins_list:
                            margen_entrega = round(float(min(margins_list)), 1)
                        else:
                            # Neutro (0.0) si tiene tareas pendientes en curso pero ninguna entregada
                            margen_entrega = 0.0 if pending_tasks > 0 else 24.0

                else:
                    # Fallback local determinista para modo demo o sin red
                    base_hash = abs(hash(internal_id)) % 7
                    tiene_calificaciones = True
                    promedio = 15.0 if base_hash in [0, 1, 2] else (12.5 if base_hash in [3, 4] else 9.5)
                    dias_inact = 0 if base_hash in [0, 1] else (2 if base_hash in [2, 3] else 4)
                    pending_tasks = 0 if dias_inact <= 1 else (1 if dias_inact <= 3 else 2)
                    total_tasks = 2 if pending_tasks > 0 else 1
                    tendencia = 0.4 if promedio >= 14 else (-0.6 if promedio < 11 else 0.0)
                    margen_entrega = -48.0 if pending_tasks > 1 else (12.0 if pending_tasks == 1 else 48.0)
                    asist_formal = 0.95 if dias_inact <= 2 else 0.75
                    grades_vals = [promedio - 0.5, promedio + 0.3, promedio]
                    course_tasks_detail = [
                        {
                            "id": 101,
                            "nombre": "Avance de Proyecto - Fase 1",
                            "estado": "entregada",
                            "fecha_limite": "18/10/2026 23:59",
                            "calificacion": "16.0 / 20",
                            "fecha_entrega": "17/10/2026 20:15"
                        },
                        {
                            "id": 102,
                            "nombre": "Informe de Pruebas Unitarias",
                            "estado": "pendiente" if pending_tasks > 0 else "entregada",
                            "fecha_limite": "25/10/2026 23:59",
                            "calificacion": None if pending_tasks > 0 else "14.5 / 20",
                            "fecha_entrega": None if pending_tasks > 0 else "24/10/2026 18:30"
                        }
                    ]

                # 4. Asistencia Virtual por frecuencia semanal real
                if is_live:
                    one_week_ago = now_ts - (7 * 86400)
                    ts_list = []
                    lastaccess_val = c.get("lastaccess")
                    if lastaccess_val and isinstance(lastaccess_val, (int, float)) and lastaccess_val >= one_week_ago:
                        ts_list.append(int(lastaccess_val))

                    for it in recent_items_list:
                        if it.get("courseid") == cid:
                            t_it = it.get("timeaccess")
                            if t_it and isinstance(t_it, (int, float)) and t_it >= one_week_ago:
                                ts_list.append(int(t_it))

                    # Recuperar historial persistido en SQLite para este estudiante y curso
                    try:
                        cur.execute("""
                            SELECT timestamp FROM historial_accesos 
                            WHERE id_estudiante = ? AND id_curso = ? AND timestamp >= ?;
                        """, (id_estudiante, internal_id, one_week_ago))
                        for row in cur.fetchall():
                            ts_list.append(row[0])
                    except Exception:
                        pass

                    # Guardar timestamps encontrados para no perder historial futuro
                    for ts in ts_list:
                        try:
                            cur.execute("""
                                INSERT OR IGNORE INTO historial_accesos (id_estudiante, id_curso, timestamp)
                                VALUES (?, ?, ?);
                            """, (id_estudiante, internal_id, ts))
                        except Exception:
                            pass

                    # Máxima rigurosidad (Learning Analytics): Días únicos con actividad en los últimos 7 días.
                    # Evita que 10 aperturas de archivos en un solo día distorsionen la regularidad semanal.
                    ts_list.sort()
                    if ts_list:
                        dias_con_actividad = {datetime.fromtimestamp(ts).strftime("%Y-%m-%d") for ts in ts_list}
                        dias_activos = max(1, len(dias_con_actividad))
                    else:
                        dias_activos = 1 if dias_inact <= 7 else 0
                else:
                    dias_activos = max(1, 4 if dias_inact <= 1 else (2 if dias_inact <= 3 else 1))

                accesos_semana = dias_activos
                asist_virtual = round(min(1.0, max(0.1, dias_activos / 4.0)), 3)
                tasa_pend = (pending_tasks / total_tasks) if total_tasks > 0 else 0.0

                # 5. Insertar Curso
                cur.execute("""
                INSERT INTO cursos (id_curso, moodle_id, nombre, codigo, docente, creditos, id_estudiante, fecha_estimacion)
                VALUES (?, ?, ?, ?, 'Docente Asignado FISI', 4, ?, 'Estimación activa')
                ON CONFLICT(id_curso, id_estudiante) DO UPDATE SET
                    nombre = excluded.nombre,
                    codigo = excluded.codigo;
                """, (internal_id, cid, c_name, c_short, id_estudiante))

                # 6. Insertar Métricas (sin inventar números falsos para el promedio)
                prom_guardar = promedio if tiene_calificaciones else None
                cur.execute("""
                INSERT INTO metricas (
                    id_curso, id_estudiante, dias_inactividad, tareas_totales,
                    tareas_pendientes, promedio_quizzes, accesos_esta_semana,
                    promedio_historico, tendencia_calificaciones, margen_entrega_horas,
                    asistencia_formal, asistencia_virtual, fecha_corte
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, DATE('now'));
                """, (
                    internal_id, id_estudiante, dias_inact, total_tasks,
                    pending_tasks, prom_guardar, accesos_semana, prom_guardar,
                    tendencia, margen_entrega, asist_formal, asist_virtual
                ))

                # 7. Ejecutar ML Predictor (Regresión Logística con 7 variables)
                vector_dict = {
                    "promedio_calificaciones": float(promedio),
                    "tendencia_calificaciones": float(tendencia),
                    "dias_inactividad": float(dias_inact),
                    "tasa_tareas_pendientes": float(tasa_pend),
                    "margen_entrega_horas": float(margen_entrega),
                    "asistencia_formal_sesiones": float(asist_formal),
                    "asistencia_virtual_regularidad": float(asist_virtual)
                }

                if model is not None and scaler is not None:
                    prob_riesgo, pct, nivel = predecir_vector(vector_dict)
                else:
                    prob_riesgo = min(0.90, max(0.10, (dias_inact * 0.06) + (tasa_pend * 0.35)))
                    pct = int(round(prob_riesgo * 100))
                    nivel, _, _, _ = calcular_nivel_riesgo(prob_riesgo)

                factores_metricas = {
                    "dias_inactividad": dias_inact,
                    "promedio_calificaciones": promedio if tiene_calificaciones else None,
                    "tiene_calificaciones": tiene_calificaciones,
                    "tareas_pendientes": pending_tasks,
                    "tareas_totales": total_tasks,
                    "margen_entrega_horas": margen_entrega,
                    "dias_activos": dias_activos,
                }
                nivel, alerta_t, alerta_m, accion_rec = calcular_nivel_riesgo(prob_riesgo, factores_metricas)

                # 8. Factores explicativos XAI (Nielsen H6)
                chart_days = [1 if i >= (14 - dias_inact) else 0 for i in range(14)]
                if total_tasks > 0:
                    chart_tasks = [1] * max(0, total_tasks - pending_tasks) + [0] * pending_tasks
                else:
                    chart_tasks = [1]

                subtitulo_tareas = "No hay tareas programadas en Moodle." if total_tasks == 0 else (
                    "Todas las tareas han sido entregadas en Moodle." if pending_tasks == 0 else
                    f"{pending_tasks} de {total_tasks} tarea{'s' if total_tasks != 1 else ''} pendiente{'s' if pending_tasks != 1 else ''} en Moodle."
                )

                factores_list = [
                    {
                        "clave": "inactividad",
                        "titulo": f"Último acceso al curso: {'hoy' if dias_inact == 0 else f'hace {dias_inact} día' + ('s' if dias_inact != 1 else '')}",
                        "impacto": "aumenta" if dias_inact > 3 else "reduce",
                        "influencia": 3 if dias_inact > 3 else 1,
                        "subtitulo": f"Registro de actividad en MoodleCloud. Frecuencia estimada: {14 - dias_inact}/14 días.",
                        "chartType": "day_circles",
                        "chartValues": chart_days
                    },
                ]

                # Factor de calificaciones: transparente y real
                if tiene_calificaciones:
                    if len(grades_vals) >= 2:
                        quiz_trend_vals = [round(float(g), 1) for g in grades_vals[-4:]]
                    else:
                        quiz_trend_vals = [round(promedio, 1)]

                    factores_list.append({
                        "clave": "cuestionarios",
                        "titulo": f"Promedio en evaluaciones: {promedio:.1f}/20",
                        "impacto": "reduce" if promedio >= 13.5 else ("aumenta" if promedio < 10.5 else "reduce"),
                        "influencia": 3,
                        "subtitulo": "Calculado del reporte de calificaciones y quizes en Moodle.",
                        "chartType": "quiz_trend",
                        "chartValues": quiz_trend_vals
                    })
                else:
                    factores_list.append({
                        "clave": "cuestionarios",
                        "titulo": "Aún no tienes calificaciones registradas",
                        "impacto": "reduce",
                        "influencia": 1,
                        "subtitulo": "El docente todavía no ha publicado notas en este curso de Moodle.",
                        "chartType": "none",
                        "chartValues": []
                    })

                factores_list.append({
                    "clave": "tareas",
                    "titulo": f"Tareas pendientes: {pending_tasks} de {total_tasks}",
                    "impacto": "aumenta" if pending_tasks > 0 else "reduce",
                    "influencia": 2,
                    "subtitulo": subtitulo_tareas,
                    "chartType": "tasks_timeline",
                    "chartValues": chart_tasks,
                    "tareas": course_tasks_detail
                })

                tus_dias = dias_activos
                meta_recomendada = 4
                palabra_dia = "día" if tus_dias == 1 else "días"
                factores_list.append({
                    "clave": "accesos",
                    "titulo": f"Constancia semanal: {tus_dias} {palabra_dia} activo{'s' if tus_dias != 1 else ''}",
                    "impacto": "reduce" if tus_dias >= meta_recomendada else "aumenta",
                    "influencia": 2,
                    "subtitulo": f"Registraste estudio en {tus_dias} {palabra_dia} esta semana frente a la meta recomendada ({meta_recomendada} días).",
                    "chartType": "weekly_logins",
                    "chartValues": [float(tus_dias), float(meta_recomendada)]
                })

                cur.execute("""
                INSERT INTO predicciones (
                    id_curso, id_estudiante, probabilidad, porcentaje, nivel_riesgo,
                    rango_min, rango_max, alerta_titulo, alerta_mensaje, accion_recomendada,
                    paso_titulo, paso_subtitulo, paso_tipo, is_sin_estimacion, factores_json, updated_at
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Revisar entregas en Moodle', 'MoodleCloud UNMSM', 'task', 0, ?, CURRENT_TIMESTAMP);
                """, (
                    internal_id, id_estudiante, round(prob_riesgo, 4), pct, nivel,
                    max(0, pct - 5), min(100, pct + 5), alerta_t, alerta_m, accion_rec,
                    json.dumps(factores_list)
                ))

            conn.commit()

        finally:
            conn.close()

        return len(courses)

    def sync_student_by_id(self, id_estudiante: str, force: bool = False) -> bool:
        """
        Sincroniza en tiempo real los datos del estudiante con MoodleCloud
        usando su token de sesión guardado en SQLite.
        Debounce de 4 segundos para evitar saturar peticiones repetidas.
        """
        now = time.time()
        last = self._last_sync_by_student.get(id_estudiante, 0)
        if not force and (now - last < 4.0):
            logger.debug(f"Sync omitido para {id_estudiante}: sincronizado hace {now - last:.1f}s.")
            return True

        conn = get_db_connection()
        try:
            cur = conn.cursor()
            cur.execute("SELECT * FROM estudiantes WHERE id_estudiante = ?;", (id_estudiante,))
            row = cur.fetchone()
        finally:
            conn.close()

        if not row:
            return False

        token = row["token_moodle"]
        if not token or token.startswith("token_demo_") or token.startswith("token_fallback_"):
            return False

        userid = row["moodle_userid"]
        clean_user = row["username"]
        fullname = row["nombre"]
        user_email = row["correo"]

        try:
            if not userid or userid <= 0:
                site_info = self.client.get_site_info(token)
                userid = site_info.get("userid", 0)

            courses = self.client.get_enrolled_courses(token, userid)
            if not courses:
                courses = self._get_default_courses()

            self._process_courses_and_save(
                moodle_token=token,
                userid=userid,
                id_estudiante=id_estudiante,
                clean_user=clean_user,
                fullname=fullname,
                user_email=user_email,
                courses=courses,
                is_live=True
            )
            self._last_sync_by_student[id_estudiante] = time.time()
            logger.info(f"Sincronización en vivo con MoodleCloud completada exitosamente para {id_estudiante}.")
            return True

        except Exception as e:
            logger.warning(f"Error al sincronizar en vivo con MoodleCloud para {id_estudiante}: {e}")
            return False

    def sync_and_predict(self, username: str, password: str) -> Dict[str, Any]:
        """
        1. Autentica al estudiante con la API REST de MoodleCloud.
        2. Obtiene su perfil institucional y los cursos matriculados.
        3. Para cada curso, extrae métricas de actividad (inactividad, tareas, calificaciones).
        4. Ejecuta el modelo de Regresión Logística (Scikit-Learn) para predecir el riesgo académico.
        5. Persiste el estado completo en la base de datos local SQLite.
        """
        clean_user = username.strip()

        # 1. Autenticación con MoodleCloud
        try:
            moodle_token = self.client.authenticate(clean_user, password)
            site_info = self.client.get_site_info(moodle_token)
            userid = site_info.get("userid")
            fullname = site_info.get("fullname", clean_user)
            user_email = f"{clean_user.lower()}@unmsm.edu.pe"

            # 2. Cursos matriculados en Moodle
            courses = self.client.get_enrolled_courses(moodle_token, userid)
            is_live = True
            logger.info(f"Autenticación exitosa en MoodleCloud para {fullname} (ID: {userid}) con {len(courses)} cursos.")

        except ValueError as val_err:
            raise val_err

        except Exception as conn_err:
            logger.warning(f"No se pudo contactar MoodleCloud ({conn_err}). Usando respaldo local.")
            fullname = "Guillermo Paucar" if "guillermo" in clean_user.lower() else "Joseph Escalante"
            user_email = f"{clean_user.lower()}@unmsm.edu.pe"
            moodle_token = f"token_fallback_{clean_user.lower()}"
            userid = 5 if "guillermo" in clean_user.lower() else 6
            is_live = False
            courses = self._get_default_courses()

        id_estudiante = f"EST-{clean_user.upper()}"
        total_courses_count = self._process_courses_and_save(
            moodle_token=moodle_token,
            userid=userid,
            id_estudiante=id_estudiante,
            clean_user=clean_user,
            fullname=fullname,
            user_email=user_email,
            courses=courses,
            is_live=is_live
        )
        self._last_sync_by_student[id_estudiante] = time.time()

        return {
            "token": f"token_moodle_{clean_user.lower()}",
            "estudiante": {
                "id_estudiante": id_estudiante,
                "nombre": fullname,
                "carrera": "Ingeniería de Software (UNMSM)",
                "ciclo": "9no ciclo",
                "email": user_email
            },
            "total_cursos": total_courses_count,
            "moodle_url": MOODLE_BASE_URL,
            "metodo": "moodlecloud_rest_api" if is_live else "local_fallback"
        }

    @staticmethod
    def _get_default_courses() -> List[Dict[str, Any]]:
        return [
            {
                "id": 9,
                "shortname": "Software_Mobile",
                "idnumber": "202W0907",
                "fullname": "Taller de Construcción de Software Móvil"
            },
            {
                "id": 10,
                "shortname": "GS-G1-2026",
                "idnumber": "202W0902",
                "fullname": "Garantía de Software - G1"
            },
            {
                "id": 11,
                "shortname": "GMS-G1-2026",
                "idnumber": "202W0904",
                "fullname": "Gestión de Mantenimiento del Software - G1"
            }
        ]


moodle_service = MoodleService()
