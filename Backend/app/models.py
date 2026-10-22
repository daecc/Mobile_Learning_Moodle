from pydantic import BaseModel, Field
from typing import List, Optional, Dict

class LoginRequest(BaseModel):
    codigo: str = Field(..., example="EST-0001")
    password: str = Field(..., example="123456")

class StudentProfile(BaseModel):
    id_estudiante: str
    nombre: str
    carrera: str
    ciclo: str
    email: str

class LoginResponse(BaseModel):
    token: str
    estudiante: StudentProfile

class MetacognitiveStat(BaseModel):
    clave: str
    titulo: str
    valor: str
    unidad: Optional[str] = None
    estado: str  # "ok" (verde), "alerta" (amarillo), "critico" (rojo)
    descripcion: str

class CourseRiskSummary(BaseModel):
    id_curso: str
    nombre_curso: str
    codigo_curso: str
    creditos: int
    docente: str
    probabilidad_riesgo: float
    porcentaje_riesgo: int
    nivel_riesgo: str  # "BAJO", "MODERADO", "CRITICO", "SIN_ESTIMACION"
    fecha_estimacion: Optional[str] = None

class RiskDistributionSummary(BaseModel):
    bajo: int
    moderado: int
    critico: int
    sin_estimacion: int = 0

class StudentCoursesResponse(BaseModel):
    id_estudiante: str
    nombre_estudiante: str
    total_cursos: int
    resumen_riesgo: RiskDistributionSummary
    cursos: List[CourseRiskSummary]

class TaskItemModel(BaseModel):
    id: int
    nombre: str
    estado: str  # "entregada" | "pendiente" | "vencida"
    fecha_limite: Optional[str] = None
    calificacion: Optional[str] = None
    fecha_entrega: Optional[str] = None

class RiskFactorModel(BaseModel):
    clave: str
    titulo: str
    subtitulo: str
    impacto: str  # "aumenta" o "reduce"
    influencia: int = 1
    chartType: Optional[str] = None
    chartValues: List[float] = []
    tareas: List[TaskItemModel] = []

class FactoresBundleModel(BaseModel):
    periodo: str = "últimas semanas"
    sumanRiesgo: int = 0
    jueganFavor: int = 0
    riesgos: List[RiskFactorModel] = []
    favorables: List[RiskFactorModel] = []
    reflexionOpciones: List[str] = []

class RiskDetailResponse(BaseModel):
    id_estudiante: str
    id_curso: str
    nombre_curso: str
    codigo_curso: str
    fecha_corte: str
    probabilidad_riesgo: float
    porcentaje_riesgo: int
    nivel_riesgo: str  # "BAJO", "MODERADO", "CRITICO"
    alerta_titulo: str
    alerta_mensaje: str
    accion_recomendada: str
    metricas: List[MetacognitiveStat]
    rango_min: int = 0
    rango_max: int = 0
    paso_titulo: Optional[str] = None
    paso_subtitulo: Optional[str] = None
    paso_tipo: Optional[str] = None
    factores: Optional[FactoresBundleModel] = None

class CustomPredictionRequest(BaseModel):
    promedio_calificaciones: float = 14.0
    tendencia_calificaciones: float = 0.0
    dias_inactividad: float = 2.0
    tasa_tareas_pendientes: float = 0.2
    margen_entrega_horas: float = 12.0
    asistencia_formal_sesiones: float = 0.90
    asistencia_virtual_regularidad: float = 0.80

class CustomPredictionResponse(BaseModel):
    probabilidad_riesgo: float
    porcentaje_riesgo: int
    nivel_riesgo: str
    riesgo_confirmado: int

class ChatMessageModel(BaseModel):
    rol: str = "user"  # "user" o "assistant"
    contenido: str

class TutorChatRequest(BaseModel):
    id_estudiante: str
    id_curso: Optional[str] = None
    mensaje: str
    historial: List[ChatMessageModel] = []

class TutorChatResponse(BaseModel):
    respuesta: str
    sugerencias: List[str] = []
    curso_contexto: Optional[str] = None
    nivel_riesgo: Optional[str] = None
