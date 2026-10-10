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
    Traduce las variables predictoras del estudiante en tarjetas visuales
    claras para la pantalla de control metacognitivo.
    """
    metricas = []

    # 1. Días de inactividad
    dias_inact = float(row.get("dias_inactividad_consecutivos", 0))
    if dias_inact <= 3:
        estado_inact = "ok"
        desc_inact = "Excelente frecuencia de acceso a la plataforma."
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

    # 2. Calificación histórica promedio
    prom = float(row.get("calificacion_historica_promedio", 12))
    if prom >= 14:
        estado_prom = "ok"
        desc_prom = "Rendimiento aprobatorio sólido en evaluaciones."
    elif prom >= 11:
        estado_prom = "alerta"
        desc_prom = "Promedio en rango límite aprobatorio (escala 0-20)."
    else:
        estado_prom = "critico"
        desc_prom = "Promedio desaprobatorio. Requiere reforzamiento inmediato."

    metricas.append(MetacognitiveStat(
        clave="promedio",
        titulo="Promedio acumulado",
        valor=f"{prom:.1f}",
        unidad="/ 20",
        estado=estado_prom,
        descripcion=desc_prom
    ))

    # 3. Tendencia de calificaciones
    tend = float(row.get("tendencia_calificaciones", 0))
    if tend > 0.1:
        estado_tend = "ok"
        valor_tend = f"+{tend:.2f}"
        desc_tend = "Tus notas van en ascenso en los últimos cortes."
    elif tend >= -0.2:
        estado_tend = "alerta"
        valor_tend = f"{tend:.2f}"
        desc_tend = "Tus notas se mantienen estables respecto a inicios del ciclo."
    else:
        estado_tend = "critico"
        valor_tend = f"{tend:.2f}"
        desc_tend = "Tendencia descendente en tus últimas calificaciones."

    metricas.append(MetacognitiveStat(
        clave="tendencia",
        titulo="Tendencia de notas",
        valor=valor_tend,
        unidad="pts/corte",
        estado=estado_tend,
        descripcion=desc_tend
    ))

    # 4. Tasa de entregas tardías
    entregas_tardias = float(row.get("tasa_entregas_tardias", 0)) * 100
    if entregas_tardias <= 20:
        estado_ent = "ok"
        desc_ent = "Puntualidad óptima en entrega de tareas y talleres."
    elif entregas_tardias <= 50:
        estado_ent = "alerta"
        desc_ent = "Algunas tareas fueron enviadas fuera del plazo establecido."
    else:
        estado_ent = "critico"
        desc_ent = "Alto porcentaje de entregas fuera de fecha o no presentadas."

    metricas.append(MetacognitiveStat(
        clave="entregas",
        titulo="Entregas fuera de fecha",
        valor=f"{int(entregas_tardias)}%",
        unidad=None,
        estado=estado_ent,
        descripcion=desc_ent
    ))

    # 5. Visualización de materiales
    vis_mat = float(row.get("tasa_visualizacion_materiales", 0)) * 100
    if vis_mat >= 70:
        estado_vis = "ok"
        desc_vis = "Has revisado la mayoría de recursos y diapositivas."
    elif vis_mat >= 40:
        estado_vis = "alerta"
        desc_vis = "Te faltan materiales clave por revisar en esta unidad."
    else:
        estado_vis = "critico"
        desc_vis = "Baja interacción con lecturas y recursos del curso."

    metricas.append(MetacognitiveStat(
        clave="materiales",
        titulo="Materiales revisados",
        valor=f"{int(vis_mat)}%",
        unidad=None,
        estado=estado_vis,
        descripcion=desc_vis
    ))

    return metricas

def predecir_vector(vector_dict: Dict[str, float]) -> Tuple[float, int, str]:
    if model is None or scaler is None:
        raise RuntimeError("El modelo no está cargado")
    
    vec = [float(vector_dict.get(feat, 0.0)) for feat in features_list]
    vec_scaled = scaler.transform([vec])
    proba = float(model.predict_proba(vec_scaled)[0, 1])
    pct = round(proba * 100)
    nivel, _, _, _ = calcular_nivel_riesgo(proba)
    return proba, pct, nivel
