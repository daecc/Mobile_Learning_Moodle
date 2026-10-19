import os
from pathlib import Path
from typing import Dict, Any, Tuple, List
import joblib
import numpy as np
from app.models import MetacognitiveStat

BASE_DIR = Path(__file__).resolve().parent.parent.parent
ML_DIR = BASE_DIR / "ml_models"

model_path = ML_DIR / "model.joblib"
scaler_path = ML_DIR / "scaler.joblib"
features_path = ML_DIR / "features.joblib"

if model_path.exists() and scaler_path.exists():
    model = joblib.load(model_path)
    scaler = joblib.load(scaler_path)
    features_list = joblib.load(features_path)
else:
    model = None
    scaler = None
    features_list = []

def calcular_nivel_riesgo(probabilidad: float) -> Tuple[str, str, str, str]:
    """
    Retorna (nivel, titulo_alerta, mensaje_alerta, accion_recomendada)
    acorde a los principios de diseño de Rumbo:
    - Verde (0 - 30%): Bajo
    - Amarillo (31 - 60%): Moderado
    - Rojo (61 - 100%): Crítico
    """
    pct = round(probabilidad * 100)
    if pct <= 30:
        return (
            "BAJO",
            "Vas por buen camino",
            "Tus indicadores de interacción y rendimiento se mantienen estables. Continúa con este ritmo de estudio para asegurar el ciclo.",
            "Mantén tu ritmo constante. Revisa las lecturas complementarias y participa en los foros para consolidar tus logros."
        )
    elif pct <= 60:
        return (
            "MODERADO",
            "Atención requerida",
            "Detectamos una leve disminución en tu frecuencia de ingresos y entregas recientes. Estás a tiempo de nivelar tu avance.",
            "Planifica tus próximas 48 horas: repasa el último módulo práctico, entrega los ejercicios pendientes y resuelve las dudas con el docente."
        )
    else:
        return (
            "CRITICO",
            "Alerta temprana de riesgo académico",
            "El modelo predictivo identificó una alta probabilidad de rezago debido a inactividad prolongada y evaluaciones recientes por debajo de la media.",
            "Paso prioritario: Conéctate hoy a Moodle, revisa las tareas vencidas con opción de prórroga y solicita una tutoría académica inmediata."
        )

def generar_metricas_metacognitivas(row: Dict[str, Any]) -> List[MetacognitiveStat]:
    """
    Traduce las 7 variables predictoras del estudiante en tarjetas visuales
    claras para la pantalla de control metacognitivo.
    """
    metricas = []

    # 1. Días de inactividad
    dias_inact = float(row.get("dias_inactividad", row.get("dias_inactividad_consecutivos", 0)))
    if dias_inact <= 3:
        estado_inact = "ok"
        desc_inact = "Frecuencia constante de acceso a la plataforma."
    elif dias_inact <= 7:
        estado_inact = "alerta"
        desc_inact = "Llevas varios días sin consultar los contenidos del curso."
    else:
        estado_inact = "critico"
        desc_inact = "Inactividad prolongada que impacta negativamente tu aprendizaje."

    metricas.append(MetacognitiveStat(
        clave="inactividad",
        titulo="Días sin entrar al sistema",
        valor=f"{int(dias_inact)}",
        unidad="días",
        estado=estado_inact,
        descripcion=desc_inact
    ))

    # 2. Calificación promedio
    prom = float(row.get("promedio_calificaciones", row.get("calificacion_historica_promedio", 12)))
    if prom >= 14:
        estado_prom = "ok"
        desc_prom = "Rendimiento aprobatorio sólido en evaluaciones."
    elif prom >= 10.5:
        estado_prom = "alerta"
        desc_prom = "Promedio en rango límite aprobatorio (escala 0-20)."
    else:
        estado_prom = "critico"
        desc_prom = "Promedio desaprobatorio. Requiere reforzamiento urgente."

    metricas.append(MetacognitiveStat(
        clave="promedio",
        titulo="Promedio acumulado",
        valor=f"{prom:.1f}",
        unidad="/ 20",
        estado=estado_prom,
        descripcion=desc_prom
    ))

    # 3. Tendencia de calificaciones (Pendiente / Slope)
    tend = float(row.get("tendencia_calificaciones", 0))
    if tend > 0.05:
        estado_tend = "ok"
        valor_tend = f"+{tend:.2f}"
        desc_tend = "Tus notas van en ascenso positivo en las últimas entregas."
    elif tend >= -0.2:
        estado_tend = "alerta"
        valor_tend = f"{tend:.2f}"
        desc_tend = "Tus notas se mantienen estables respecto al inicio del curso."
    else:
        estado_tend = "critico"
        valor_tend = f"{tend:.2f}"
        desc_tend = "Tendencia descendente en tus últimas calificaciones."

    metricas.append(MetacognitiveStat(
        clave="tendencia",
        titulo="Tendencia de notas (Pendiente)",
        valor=valor_tend,
        unidad="pts/corte",
        estado=estado_tend,
        descripcion=desc_tend
    ))

    # 4. Tasa de tareas pendientes
    tareas_pend = float(row.get("tasa_tareas_pendientes", 0)) * 100
    if tareas_pend <= 10:
        estado_pend = "ok"
        desc_pend = "Al día con todos los talleres y entregas de Moodle."
    elif tareas_pend <= 40:
        estado_pend = "alerta"
        desc_pend = "Tienes tareas pendientes por entregar en la plataforma."
    else:
        estado_pend = "critico"
        desc_pend = "Alto porcentaje de tareas adeudadas o sin entregar."

    metricas.append(MetacognitiveStat(
        clave="entregas",
        titulo="Tareas pendientes",
        valor=f"{int(tareas_pend)}%",
        unidad=None,
        estado=estado_pend,
        descripcion=desc_pend
    ))

    # 5. Margen de entrega (Procrastinación)
    margen_h = float(row.get("margen_entrega_horas", 12))
    if margen_h >= 24:
        estado_mrg = "ok"
        valor_mrg = f"+{int(margen_h)}h"
        desc_mrg = "Excelente disciplina: entregas con más de 24h de anticipación."
    elif margen_h >= 0:
        estado_mrg = "alerta"
        valor_mrg = f"+{int(margen_h)}h"
        desc_mrg = "Entregas muy cerca del cierre de plazo (riesgo de procrastinación)."
    else:
        estado_mrg = "critico"
        valor_mrg = f"{int(margen_h)}h"
        desc_mrg = "Entregas fuera de fecha o tareas vencidas sin enviar."

    metricas.append(MetacognitiveStat(
        clave="procrastinacion",
        titulo="Margen de entrega",
        valor=valor_mrg,
        unidad=None,
        estado=estado_mrg,
        descripcion=desc_mrg
    ))

    # 6. Asistencia formal a sesiones (Tipo 1)
    asist_formal = float(row.get("asistencia_formal_sesiones", 0.85)) * 100
    if asist_formal >= 80:
        estado_af = "ok"
        desc_af = "Asistencia regular a clases y sesiones sincrónicas."
    elif asist_formal >= 70:
        estado_af = "alerta"
        desc_af = "Asistencia en el umbral límite reglamentario (cuidado con el DPI)."
    else:
        estado_af = "critico"
        desc_af = "Inasistencias acumuladas en zona de riesgo de inhabilitación."

    metricas.append(MetacognitiveStat(
        clave="asistencia_formal",
        titulo="Asistencia a sesiones",
        valor=f"{int(asist_formal)}%",
        unidad=None,
        estado=estado_af,
        descripcion=desc_af
    ))

    # 7. Asistencia virtual a la plataforma (Tipo 2)
    asist_virt = float(row.get("asistencia_virtual_regularidad", 0.75)) * 100
    if asist_virt >= 70:
        estado_av = "ok"
        desc_av = "Ingresos regulares y estudio autónomo semanal en el aula virtual."
    elif asist_virt >= 40:
        estado_av = "alerta"
        desc_av = "Frecuencia de visita semanal irregular en la plataforma."
    else:
        estado_av = "critico"
        desc_av = "Muy escasa presencia virtual en el curso."

    metricas.append(MetacognitiveStat(
        clave="asistencia_virtual",
        titulo="Presencia virtual semanal",
        valor=f"{int(asist_virt)}%",
        unidad=None,
        estado=estado_av,
        descripcion=desc_av
    ))

    return metricas

import pandas as pd

def predecir_vector(vector_dict: Dict[str, float]) -> Tuple[float, int, str]:
    if model is None or scaler is None:
        raise RuntimeError("El modelo no está cargado")
    
    row_values = [float(vector_dict.get(feat, 0.0)) for feat in features_list]
    df_vec = pd.DataFrame([row_values], columns=features_list)
    vec_scaled = scaler.transform(df_vec)
    proba = float(model.predict_proba(vec_scaled)[0, 1])
    pct = round(proba * 100)
    nivel, _, _, _ = calcular_nivel_riesgo(proba)
    return proba, pct, nivel

