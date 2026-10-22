from fastapi import APIRouter, HTTPException, status
from typing import List
import json
import logging
from app.models import (
    StudentCoursesResponse,
    CourseRiskSummary,
    RiskDistributionSummary,
    RiskDetailResponse,
    MetacognitiveStat,
    RiskFactorModel,
    FactoresBundleModel,
    TaskItemModel
)
from app.database import get_db_connection
from app.services.moodle_service import moodle_service

logger = logging.getLogger("cursos_route")

router = APIRouter(prefix="/api/estudiantes", tags=["Cursos y Riesgo Académico"])

@router.get("/{id_estudiante}/cursos", response_model=StudentCoursesResponse)
def get_student_courses(id_estudiante: str, refresh: bool = False):
    # Sincronización en vivo con MoodleCloud solo si se solicita explícitamente (ej. pull-to-refresh)
    if refresh:
        try:
            moodle_service.sync_student_by_id(id_estudiante, force=True)
        except Exception as e:
            logger.warning(f"Sincronización Moodle omitida en cursos: {e}")

    conn = get_db_connection()
    try:
        cur = conn.cursor()

        # 1. Obtener perfil del estudiante desde SQLite
        cur.execute("SELECT * FROM estudiantes WHERE id_estudiante = ?;", (id_estudiante,))
        estudiante_row = cur.fetchone()

        # Si no existe por ID exacto, buscar por coincidencia o fallback
        if not estudiante_row:
            cur.execute("SELECT * FROM estudiantes ORDER BY last_login DESC LIMIT 1;")
            estudiante_row = cur.fetchone()

        nombre_estudiante = estudiante_row["nombre"] if estudiante_row else "Estudiante"
        est_id = estudiante_row["id_estudiante"] if estudiante_row else id_estudiante

        # 2. Consultar cursos y su última predicción en SQLite
        cur.execute("""
        SELECT 
            c.id_curso,
            c.nombre,
            c.codigo,
            c.creditos,
            c.docente,
            c.fecha_estimacion,
            p.probabilidad,
            p.porcentaje,
            p.nivel_riesgo
        FROM cursos c
        LEFT JOIN predicciones p ON c.id_curso = p.id_curso AND c.id_estudiante = p.id_estudiante
        WHERE c.id_estudiante = ?
        ORDER BY p.id DESC;
        """, (est_id,))

        rows = cur.fetchall()

        # Si no hay cursos para este estudiante, sincronizar directamente desde Moodle
        if not rows:
            try:
                moodle_service.sync_student_by_id(est_id, force=True)
                cur.execute("""
                SELECT 
                    c.id_curso,
                    c.nombre,
                    c.codigo,
                    c.creditos,
                    c.docente,
                    c.fecha_estimacion,
                    p.probabilidad,
                    p.porcentaje,
                    p.nivel_riesgo
                FROM cursos c
                LEFT JOIN predicciones p ON c.id_curso = p.id_curso AND c.id_estudiante = p.id_estudiante
                WHERE c.id_estudiante = ?
                ORDER BY p.id DESC;
                """, (est_id,))
                rows = cur.fetchall()
            except Exception as se:
                logger.warning(f"Error sincronizando cursos faltantes para {est_id}: {se}")
    finally:
        conn.close()

    cursos_summary: List[CourseRiskSummary] = []
    conteo_bajo = 0
    conteo_mod = 0
    conteo_crit = 0
    conteo_sin_est = 0

    for r in rows:
        nivel = r["nivel_riesgo"] or "BAJO"
        pct = r["porcentaje"] if r["porcentaje"] is not None else 0
        prob = r["probabilidad"] if r["probabilidad"] is not None else 0.0
        fecha_est = r["fecha_estimacion"]

        if nivel == "SIN_ESTIMACION" or pct < 0:
            conteo_sin_est += 1
            nivel = "SIN_ESTIMACION"
            pct = -1
            prob = -1.0
        elif nivel == "BAJO":
            conteo_bajo += 1
        elif nivel == "MODERADO":
            conteo_mod += 1
        else:
            conteo_crit += 1

        cursos_summary.append(CourseRiskSummary(
            id_curso=r["id_curso"],
            nombre_curso=r["nombre"],
            codigo_curso=r["codigo"] or "CUR",
            creditos=int(r["creditos"] or 3),
            docente=r["docente"] or "Docente Asignado",
            probabilidad_riesgo=round(prob, 4),
            porcentaje_riesgo=pct,
            nivel_riesgo=nivel,
            fecha_estimacion=fecha_est
        ))

    # Ordenar por prioridad (H6 Nielsen): primero críticos, luego moderados, seguros y sin estimación
    cursos_summary.sort(key=lambda x: (x.nivel_riesgo == "SIN_ESTIMACION", -x.porcentaje_riesgo))

    return StudentCoursesResponse(
        id_estudiante=est_id,
        nombre_estudiante=nombre_estudiante,
        total_cursos=len(cursos_summary),
        resumen_riesgo=RiskDistributionSummary(
            bajo=conteo_bajo,
            moderado=conteo_mod,
            critico=conteo_crit,
            sin_estimacion=conteo_sin_est
        ),
        cursos=cursos_summary
    )

@router.get("/{id_estudiante}/cursos/{id_curso}/riesgo", response_model=RiskDetailResponse)
def get_course_risk_detail(id_estudiante: str, id_curso: str, refresh: bool = False):
    # Sincronización en vivo con MoodleCloud solo si se solicita explícitamente (ej. pull-to-refresh en detalle)
    if refresh:
        try:
            moodle_service.sync_student_by_id(id_estudiante, force=True)
        except Exception as e:
            logger.warning(f"Sincronización Moodle omitida en detalle: {e}")

    conn = get_db_connection()
    try:
        cur = conn.cursor()

        # 1. Consultar curso
        cur.execute("SELECT * FROM cursos WHERE id_curso = ? AND id_estudiante = ? LIMIT 1;", (id_curso, id_estudiante))
        curso = cur.fetchone()
        if not curso:
            cur.execute("SELECT * FROM cursos WHERE id_curso = ? LIMIT 1;", (id_curso,))
            curso = cur.fetchone()

        # Si el curso aún no está en SQLite, sincronizar una vez como recuperación
        if not curso and not refresh:
            try:
                moodle_service.sync_student_by_id(id_estudiante, force=True)
                cur.execute("SELECT * FROM cursos WHERE id_curso = ? AND id_estudiante = ? LIMIT 1;", (id_curso, id_estudiante))
                curso = cur.fetchone()
                if not curso:
                    cur.execute("SELECT * FROM cursos WHERE id_curso = ? LIMIT 1;", (id_curso,))
                    curso = cur.fetchone()
            except Exception:
                pass

        if not curso:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"No se encontró el curso {id_curso} en la base de datos."
            )

        # 2. Consultar predicción
        cur.execute("""
        SELECT * FROM predicciones 
        WHERE id_curso = ? AND id_estudiante = ?
        ORDER BY id DESC LIMIT 1;
        """, (id_curso, id_estudiante))
        pred = cur.fetchone()
        if not pred:
            cur.execute("SELECT * FROM predicciones WHERE id_curso = ? ORDER BY id DESC LIMIT 1;", (id_curso,))
            pred = cur.fetchone()

        # 3. Consultar métricas
        cur.execute("""
        SELECT * FROM metricas 
        WHERE id_curso = ? AND id_estudiante = ?
        ORDER BY id DESC LIMIT 1;
        """, (id_curso, id_estudiante))
        metrica = cur.fetchone()
        if not metrica:
            cur.execute("SELECT * FROM metricas WHERE id_curso = ? ORDER BY id DESC LIMIT 1;", (id_curso,))
            metrica = cur.fetchone()
    finally:
        conn.close()

    # Construir métricas metacognitivas completas
    metricas_list: List[MetacognitiveStat] = []
    if metrica:
        dias = metrica["dias_inactividad"]
        tareas_tot = metrica["tareas_totales"]
        tareas_pen = metrica["tareas_pendientes"]
        prom = metrica["promedio_historico"]
        met_keys = metrica.keys()
        tend = metrica["tendencia_calificaciones"] if "tendencia_calificaciones" in met_keys else 0.0
        margen = metrica["margen_entrega_horas"] if "margen_entrega_horas" in met_keys else 24.0
        asist_f = metrica["asistencia_formal"] if "asistencia_formal" in met_keys else 0.85
        asist_v = metrica["asistencia_virtual"] if "asistencia_virtual" in met_keys else 0.75

        # 1. Inactividad
        desc_inact = "Accedió hoy al curso en Moodle." if dias == 0 else f"Hace {dias} día{'s' if dias != 1 else ''} sin ingresar a este curso."
        metricas_list.append(MetacognitiveStat(
            clave="inactividad",
            titulo="Días sin entrar al sistema",
            valor=str(dias),
            unidad="días",
            estado="critico" if dias > 4 else ("alerta" if dias > 2 else "ok"),
            descripcion=desc_inact
        ))

        # 2. Promedio
        if prom is None:
            metricas_list.append(MetacognitiveStat(
                clave="promedio",
                titulo="Promedio en evaluaciones",
                valor="Sin notas",
                unidad="",
                estado="ok",
                descripcion="Aún no se registran calificaciones en Moodle."
            ))
        else:
            metricas_list.append(MetacognitiveStat(
                clave="promedio",
                titulo="Promedio acumulado",
                valor=f"{prom:.1f}",
                unidad="/ 20",
                estado="ok" if prom >= 13.5 else ("alerta" if prom >= 10.5 else "critico"),
                descripcion="Notas de evaluaciones y cuestionarios."
            ))

        # 3. Tendencia
        if prom is None:
            metricas_list.append(MetacognitiveStat(
                clave="tendencia",
                titulo="Tendencia de notas (Slope)",
                valor="Sin historial",
                unidad="",
                estado="ok",
                descripcion="Se calculará con 2 o más calificaciones."
            ))
        else:
            metricas_list.append(MetacognitiveStat(
                clave="tendencia",
                titulo="Tendencia de notas (Slope)",
                valor=f"+{tend:.2f}" if tend > 0 else f"{tend:.2f}",
                unidad="pts/corte",
                estado="ok" if tend >= 0.05 else ("alerta" if tend >= -0.2 else "critico"),
                descripcion="Inclinación y evolución de calificaciones."
            ))

        # 4. Tareas pendientes (sin inventar números falsos)
        if tareas_tot == 0:
            val_entregas = "0 de 0"
            estado_entregas = "ok"
            desc_entregas = "No hay tareas programadas en Moodle."
        elif tareas_pen == 0:
            val_entregas = f"0 de {tareas_tot}"
            estado_entregas = "ok"
            desc_entregas = "Todas las tareas han sido entregadas."
        else:
            val_entregas = f"{tareas_pen} de {tareas_tot}"
            estado_entregas = "critico" if margen < 0 else "alerta"
            desc_entregas = "Tareas pendientes de entrega en Moodle."

        metricas_list.append(MetacognitiveStat(
            clave="entregas",
            titulo="Tareas pendientes",
            valor=val_entregas,
            estado=estado_entregas,
            descripcion=desc_entregas
        ))

        # 5. Margen de entrega (Procrastinación)
        if tareas_tot == 0:
            val_margen = "Al día"
            estado_margen = "ok"
            desc_margen = "Sin tareas pendientes en Moodle."
        else:
            val_margen = f"{int(margen)}h" if margen < 0 else f"+{int(margen)}h"
            estado_margen = "ok" if margen >= 24 else ("alerta" if margen >= 0 else "critico")
            desc_margen = "Disciplina y anticipación a la fecha límite."

        metricas_list.append(MetacognitiveStat(
            clave="procrastinacion",
            titulo="Margen de entrega",
            valor=val_margen,
            estado=estado_margen,
            descripcion=desc_margen
        ))

        # 6. Asistencia formal
        metricas_list.append(MetacognitiveStat(
            clave="asistencia_formal",
            titulo="Asistencia a sesiones",
            valor=f"{int(asist_f * 100)}%",
            estado="ok" if asist_f >= 0.8 else ("alerta" if asist_f >= 0.7 else "critico"),
            descripcion="Asistencia registrada en módulo de clases."
        ))

        # 7. Presencia virtual
        metricas_list.append(MetacognitiveStat(
            clave="asistencia_virtual",
            titulo="Presencia virtual semanal",
            valor=f"{int(asist_v * 100)}%",
            estado="ok" if asist_v >= 0.7 else ("alerta" if asist_v >= 0.4 else "critico"),
            descripcion="Constancia de estudio en la plataforma."
        ))
    else:
        metricas_list.append(MetacognitiveStat(
            clave="inactividad",
            titulo="Días sin entrar",
            valor="5",
            unidad="días",
            estado="critico",
            descripcion="Sin accesos recientes."
        ))

    # Construir FactoresBundle (XAI Nielsen H6)
    factores_bundle = None
    if pred and pred["factores_json"]:
        try:
            raw_factores = json.loads(pred["factores_json"])
            riesgos_list = []
            favorables_list = []
            for item in raw_factores:
                tareas_raw = item.get("tareas", [])
                tareas_models = [
                    TaskItemModel(
                        id=int(t.get("id", 0)),
                        nombre=str(t.get("nombre", "Tarea")),
                        estado=str(t.get("estado", "pendiente")),
                        fecha_limite=t.get("fecha_limite"),
                        calificacion=t.get("calificacion"),
                        fecha_entrega=t.get("fecha_entrega")
                    )
                    for t in tareas_raw if isinstance(t, dict)
                ]
                f_model = RiskFactorModel(
                    clave=item.get("clave", ""),
                    titulo=item.get("titulo", ""),
                    subtitulo=item.get("subtitulo", ""),
                    impacto=item.get("impacto", "reduce"),
                    influencia=item.get("influencia", 1),
                    chartType=item.get("chartType"),
                    chartValues=[float(v) for v in item.get("chartValues", [])],
                    tareas=tareas_models
                )
                if item.get("impacto") == "aumenta":
                    riesgos_list.append(f_model)
                else:
                    favorables_list.append(f_model)

            factores_bundle = FactoresBundleModel(
                periodo="últimas 4 semanas",
                sumanRiesgo=len(riesgos_list),
                jueganFavor=len(favorables_list),
                riesgos=riesgos_list,
                favorables=favorables_list,
                reflexionOpciones=[
                    "Organizar mejor mis horarios de estudio",
                    "Repasar con anticipación los módulos y temas complejos",
                    "Preguntar más al docente en las sesiones en vivo",
                    "Participar activamente en los foros del curso"
                ]
            )
        except Exception:
            factores_bundle = None

    pct = pred["porcentaje"] if pred else 85
    prob = pred["probabilidad"] if pred else 0.85
    nivel = pred["nivel_riesgo"] if pred else "CRITICO"
    r_min = pred["rango_min"] if pred else max(0, pct - 7)
    r_max = pred["rango_max"] if pred else min(100, pct + 7)

    return RiskDetailResponse(
        id_estudiante=id_estudiante,
        id_curso=id_curso,
        nombre_curso=curso["nombre"],
        codigo_curso=curso["codigo"] or id_curso,
        fecha_corte=metrica["fecha_corte"] if metrica else "2026-10-10",
        probabilidad_riesgo=prob,
        porcentaje_riesgo=pct,
        nivel_riesgo=nivel,
        alerta_titulo=pred["alerta_titulo"] if pred and pred["alerta_titulo"] else "Detectamos señales de riesgo.",
        alerta_mensaje=pred["alerta_mensaje"] if pred and pred["alerta_mensaje"] else "Tu actividad bajó en las últimas semanas.",
        accion_recomendada=pred["accion_recomendada"] if pred and pred["accion_recomendada"] else "Revisa las tareas pendientes en Moodle.",
        metricas=metricas_list,
        rango_min=r_min,
        rango_max=r_max,
        paso_titulo=pred["paso_titulo"] if pred and pred["paso_titulo"] else "Revisar contenidos pendientes",
        paso_subtitulo=pred["paso_subtitulo"] if pred and pred["paso_subtitulo"] else "En el aula virtual",
        paso_tipo=pred["paso_tipo"] if pred and pred["paso_tipo"] else "task",
        factores=factores_bundle
    )
