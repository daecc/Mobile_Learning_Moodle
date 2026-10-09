"""Esquemas Pydantic. Las claves JSON coinciden EXACTAMENTE con los
modelos Dart (`fromJson`) del frontend Flutter.
"""
from __future__ import annotations

from datetime import datetime
from typing import Optional

from pydantic import BaseModel


# ---------- Auth ----------
class LoginRequest(BaseModel):
    username: str
    password: str


class UserOut(BaseModel):
    id_estudiante: str
    codigo_universitario: str
    nombres: str
    apellidos: str
    email: str
    programa_estudios: str
    ciclo_actual: int
    facultad: str
    token: Optional[str] = None
    token_expiry: Optional[str] = None


class LoginResponse(BaseModel):
    user: UserOut
    access_token: str
    refresh_token: str
    expires_in: int


# ---------- Cursos ----------
class CourseOut(BaseModel):
    id_curso: str
    codigo: str
    nombre: str
    descripcion: Optional[str] = None
    creditos: int
    docente: str
    docente_email: Optional[str] = None
    semestre: str
    facultad: str
    color_hex: str
    icon_code: int
    activo: bool
    fecha_inicio: Optional[datetime] = None
    fecha_fin: Optional[datetime] = None
    moodle_url: Optional[str] = None

    model_config = {"from_attributes": True}


class EnrollmentOut(BaseModel):
    course: CourseOut
    estado: str
    progreso_porcentaje: Optional[float] = None
    tareas_pendientes: Optional[int] = None
    ultima_actividad: Optional[datetime] = None


# ---------- Riesgo ----------
class RiesgoOut(BaseModel):
    id_estudiante: str
    id_curso: str
    fecha_corte: str
    calificacion_historica_promedio: float
    dias_inactividad_consecutivos: int
    probabilidad_riesgo: float
    riesgo_academico_confirmado: int

    model_config = {"from_attributes": True}
