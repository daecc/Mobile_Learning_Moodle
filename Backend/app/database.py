import sqlite3
import json
from pathlib import Path
from typing import Dict, Any, List, Optional
from datetime import datetime

DB_PATH = Path(__file__).resolve().parent.parent / "rumbo.db"

def get_db_connection() -> sqlite3.Connection:
    conn = sqlite3.connect(DB_PATH, timeout=20.0)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA journal_mode=WAL;")
    return conn

def init_db():
    conn = get_db_connection()
    cursor = conn.cursor()

    # 1. Tabla Estudiantes
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS estudiantes (
        id_estudiante TEXT PRIMARY KEY,
        username TEXT UNIQUE,
        nombre TEXT NOT NULL,
        correo TEXT,
        carrera TEXT DEFAULT 'Ingeniería de Sistemas',
        ciclo TEXT DEFAULT 'Pregrado',
        token_moodle TEXT,
        moodle_userid INTEGER,
        last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """)

    # 2. Tabla Cursos
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS cursos (
        id_curso TEXT NOT NULL,
        moodle_id INTEGER,
        nombre TEXT NOT NULL,
        codigo TEXT,
        docente TEXT,
        creditos INTEGER DEFAULT 3,
        id_estudiante TEXT NOT NULL,
        fecha_estimacion TEXT,
        PRIMARY KEY (id_curso, id_estudiante),
        FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante)
    );
    """)

    # 3. Tabla Metricas de Actividad (extraídas de Moodle)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS metricas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_curso TEXT NOT NULL,
        id_estudiante TEXT NOT NULL,
        dias_inactividad INTEGER DEFAULT 0,
        tareas_totales INTEGER DEFAULT 0,
        tareas_pendientes INTEGER DEFAULT 0,
        promedio_quizzes REAL DEFAULT 0.0,
        accesos_esta_semana INTEGER DEFAULT 1,
        promedio_historico REAL DEFAULT 12.0,
        tendencia_calificaciones REAL DEFAULT 0.0,
        margen_entrega_horas REAL DEFAULT 24.0,
        asistencia_formal REAL DEFAULT 0.85,
        asistencia_virtual REAL DEFAULT 0.75,
        fecha_corte TEXT,
        FOREIGN KEY (id_curso) REFERENCES cursos(id_curso),
        FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante)
    );
    """)

    # Migración no destructiva de columnas para bases de datos existentes
    cursor.execute("PRAGMA table_info(metricas);")
    existing_cols = [row[1] for row in cursor.fetchall()]
    nuevas_columnas = [
        ("tendencia_calificaciones", "REAL DEFAULT 0.0"),
        ("margen_entrega_horas", "REAL DEFAULT 24.0"),
        ("asistencia_formal", "REAL DEFAULT 0.85"),
        ("asistencia_virtual", "REAL DEFAULT 0.75")
    ]
    for col_name, col_type in nuevas_columnas:
        if col_name not in existing_cols:
            cursor.execute(f"ALTER TABLE metricas ADD COLUMN {col_name} {col_type};")

    # 4. Tabla Predicciones de Riesgo (calculadas por la IA)
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS predicciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_curso TEXT NOT NULL,
        id_estudiante TEXT NOT NULL,
        probabilidad REAL NOT NULL,
        porcentaje INTEGER NOT NULL,
        nivel_riesgo TEXT NOT NULL,
        rango_min INTEGER DEFAULT 0,
        rango_max INTEGER DEFAULT 0,
        alerta_titulo TEXT,
        alerta_mensaje TEXT,
        accion_recomendada TEXT,
        paso_titulo TEXT,
        paso_subtitulo TEXT,
        paso_tipo TEXT,
        is_sin_estimacion INTEGER DEFAULT 0,
        factores_json TEXT,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (id_curso) REFERENCES cursos(id_curso),
        FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante)
    );
    """)

    # 5. Tabla Historial de Accesos por curso
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS historial_accesos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_estudiante TEXT NOT NULL,
        id_curso TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        UNIQUE(id_estudiante, id_curso, timestamp)
    );
    """)

    conn.commit()
    conn.close()

# Inicializar al importar
init_db()
