"""Modelos ORM (tablas PostgreSQL)."""
from __future__ import annotations

from sqlalchemy import (
    Boolean,
    Column,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    UniqueConstraint,
)

from .database import Base


class Estudiante(Base):
    __tablename__ = "estudiantes"

    id_estudiante = Column(String, primary_key=True)
    codigo_universitario = Column(String, unique=True, index=True, nullable=False)
    nombres = Column(String, nullable=False)
    apellidos = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    programa_estudios = Column(String, nullable=False)
    ciclo_actual = Column(Integer, nullable=False)
    facultad = Column(String, nullable=False)
    password_hash = Column(String, nullable=False)


class Curso(Base):
    __tablename__ = "cursos"

    id_curso = Column(String, primary_key=True)
    codigo = Column(String, nullable=False)
    nombre = Column(String, nullable=False)
    descripcion = Column(String, nullable=True)
    creditos = Column(Integer, nullable=False)
    docente = Column(String, nullable=False)
    docente_email = Column(String, nullable=True)
    semestre = Column(String, nullable=False)
    facultad = Column(String, nullable=False)
    color_hex = Column(String, nullable=False, default="#1976D2")
    icon_code = Column(Integer, nullable=False, default=0xE80B)
    activo = Column(Boolean, nullable=False, default=True)
    fecha_inicio = Column(DateTime, nullable=True)
    fecha_fin = Column(DateTime, nullable=True)
    moodle_url = Column(String, nullable=True)


class Matricula(Base):
    __tablename__ = "matriculas"
    __table_args__ = (
        UniqueConstraint("id_estudiante", "id_curso", name="uq_matricula"),
    )

    id = Column(Integer, primary_key=True, autoincrement=True)
    id_estudiante = Column(String, ForeignKey("estudiantes.id_estudiante"), index=True)
    id_curso = Column(String, ForeignKey("cursos.id_curso"), index=True)
    estado = Column(String, nullable=False, default="activo")
    progreso_porcentaje = Column(Float, nullable=True)
    tareas_pendientes = Column(Integer, nullable=True)
    ultima_actividad = Column(DateTime, nullable=True)


class RiesgoPrediccion(Base):
    __tablename__ = "riesgo_predicciones"

    id = Column(Integer, primary_key=True, autoincrement=True)
    id_estudiante = Column(String, index=True, nullable=False)
    id_curso = Column(String, index=True, nullable=False)
    fecha_corte = Column(String, nullable=False)
    calificacion_historica_promedio = Column(Float, nullable=False)
    dias_inactividad_consecutivos = Column(Integer, nullable=False)
    probabilidad_riesgo = Column(Float, nullable=False)
    riesgo_academico_confirmado = Column(Integer, nullable=False, default=0)
