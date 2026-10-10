from fastapi import APIRouter, HTTPException, status
from typing import List
import json
from app.models import (
    StudentCoursesResponse,
    CourseRiskSummary,
    RiskDistributionSummary,
    RiskDetailResponse,
    MetacognitiveStat
)
from app.database import get_db_connection

router = APIRouter(prefix="/api/estudiantes", tags=["Cursos y Riesgo Académico"])

@router.get("/{id_estudiante}/cursos", response_model=StudentCoursesResponse)
def get_student_courses(id_estudiante: str):
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

        # Si no hay cursos para este estudiante, intentar buscar los cursos más recientes en BD
        if not rows:
            cur.execute("""
            SELECT 
                c.id_curso, c.nombre, c.codigo, c.creditos, c.docente, c.fecha_estimacion,
                p.probabilidad, p.porcentaje, p.nivel_riesgo
            FROM cursos c
            LEFT JOIN predicciones p ON c.id_curso = p.id_curso
            GROUP BY c.id_curso
            ORDER BY p.porcentaje DESC;
            """)
            rows = cur.fetchall()
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
def get_course_risk_detail(id_estudiante: str, id_curso: str):
    conn = get_db_connection()
    try:
        cur = conn.cursor()

        # 1. Consultar curso
        cur.execute("SELECT * FROM cursos WHERE id_curso = ? AND id_estudiante = ? LIMIT 1;", (id_curso, id_estudiante))
        curso = cur.fetchone()
        if not curso:
            cur.execute("SELECT * FROM cursos WHERE id_curso = ? LIMIT 1;", (id_curso,))
            curso = cur.fetchone()

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

    # Construir métricas metacognitivas
    metricas_list: List[MetacognitiveStat] = []
    if metrica:
        dias = metrica["dias_inactividad"]
        tareas_tot = metrica["tareas_totales"]
        tareas_pen = metrica["tareas_pendientes"]
        prom = metrica["promedio_historico"]

        metricas_list.append(MetacognitiveStat(
            clave="inactividad",
            titulo="Días sin entrar al sistema",
            valor=str(dias),
            unidad="días",
            estado="critico" if dias > 4 else ("alerta" if dias > 2 else "ok"),
            descripcion="Frecuencia de acceso al aula virtual."
        ))

        metricas_list.append(MetacognitiveStat(
            clave="promedio",
            titulo="Promedio acumulado",
            valor=f"{prom:.1f}",
            unidad="/ 20",
            estado="ok" if prom >= 13 else ("alerta" if prom >= 11 else "critico"),
            descripcion="Notas de evaluaciones y cuestionarios."
        ))

        metricas_list.append(MetacognitiveStat(
            clave="entregas",
            titulo="Tareas pendientes",
            valor=f"{tareas_pen} de {tareas_tot}",
            estado="alerta" if tareas_pen > 0 else "ok",
            descripcion="Entregas registradas en Moodle."
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
        paso_tipo=pred["paso_tipo"] if pred and pred["paso_tipo"] else "task"
    )
