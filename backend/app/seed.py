"""Script de sembrado (seed) de la base de datos.

- Crea la base de datos `mlearning` si no existe.
- Crea las tablas.
- Inserta estudiantes, cursos y matriculas (desde datos coherentes con el mock).
- Inserta predicciones de riesgo desde `riesgo_academico.csv` (ultimo corte).

Uso (desde la carpeta `backend`, con el venv activado):
    python -m app.seed
"""
from __future__ import annotations

import csv
import os
from datetime import datetime

import psycopg2
from sqlalchemy.engine.url import make_url

from .config import DATABASE_URL
from .database import Base, SessionLocal, engine
from .models import Curso, Estudiante, Matricula, RiesgoPrediccion
from .security import hash_password

# Ruta por defecto al CSV del modelo entrenado
DEFAULT_CSV = os.path.normpath(
    os.path.join(
        os.path.dirname(__file__),
        "..",
        "..",
        "Entrenamiento",
        "MobileLearning",
        "riesgo_academico.csv",
    )
)
RIESGO_CSV_PATH = os.getenv("RIESGO_CSV_PATH", DEFAULT_CSV)

PASSWORD_DEMO = "123456"

ESTUDIANTES = [
    {
        "id_estudiante": "EST-0001",
        "codigo_universitario": "20210001",
        "nombres": "Juan Carlos",
        "apellidos": "Perez Gonzalez",
        "email": "juan.perez@universidad.edu.pe",
        "programa_estudios": "Ingenieria de Sistemas",
        "ciclo_actual": 7,
        "facultad": "Facultad de Ingenieria",
    },
    {
        "id_estudiante": "EST-0002",
        "codigo_universitario": "20210002",
        "nombres": "Maria Fernanda",
        "apellidos": "Lopez Ruiz",
        "email": "maria.lopez@universidad.edu.pe",
        "programa_estudios": "Ingenieria de Software",
        "ciclo_actual": 6,
        "facultad": "Facultad de Ingenieria",
    },
    {
        "id_estudiante": "EST-0003",
        "codigo_universitario": "20210003",
        "nombres": "Carlos Alberto",
        "apellidos": "Martinez Silva",
        "email": "carlos.martinez@universidad.edu.pe",
        "programa_estudios": "Ingenieria de Sistemas",
        "ciclo_actual": 8,
        "facultad": "Facultad de Ingenieria",
    },
]

CURSOS = [
    ("CUR-001", "SI-301", "Patrones de Diseno de Software",
     "Patrones creacionales, estructurales y de comportamiento. Aplicacion en Java/Python.",
     4, "Dr. Carlos Ramirez", "c.ramirez@universidad.edu.pe", "#1976D2", 0xE3AF),
    ("CUR-002", "SI-302", "Arquitectura de Software",
     "Estilos arquitectonicos, microservicios, patrones de integracion, calidad de atributos.",
     4, "Mg. Patricia Vargas", "p.vargas@universidad.edu.pe", "#7B1FA2", 0xE072),
    ("CUR-003", "SI-303", "Base de Datos Avanzadas",
     "Optimizacion, particionamiento, NoSQL, Data Warehousing, Big Data.",
     4, "Dr. Roberto Chen", "r.chen@universidad.edu.pe", "#388E3C", 0xE2C4),
    ("CUR-004", "SI-304", "Ingenieria de Requerimientos",
     "Elicitacion, analisis, especificacion y validacion de requerimientos. Casos de uso.",
     3, "Mg. Ana Torres", "a.torres@universidad.edu.pe", "#F57C00", 0xE8B0),
    ("CUR-005", "SI-305", "Pruebas y Calidad de Software",
     "Testing unitario, integracion, automatizacion, TDD, metricas de calidad.",
     3, "Dr. Luis Herrera", "l.herrera@universidad.edu.pe", "#C62828", 0xE873),
    ("CUR-006", "SI-306", "Desarrollo Movil Avanzado",
     "Flutter/React Native, arquitectura limpia, CI/CD, publicacion en stores.",
     4, "Mg. Sandra Morales", "s.morales@universidad.edu.pe", "#0097A7", 0xE32B),
    ("CUR-007", "SI-307", "Inteligencia Artificial Aplicada",
     "ML supervisado/no supervisado, despliegue de modelos, etica en IA.",
     4, "Dr. Fernando Soto", "f.soto@universidad.edu.pe", "#6A1B9A", 0xE3AE),
    ("CUR-008", "SI-308", "Gestion de Proyectos Agiles",
     "Scrum, Kanban, escalamiento, metricas agiles, herramientas Jira/GitLab.",
     3, "Mg. Gabriela Ruiz", "g.ruiz@universidad.edu.pe", "#2E7D32", 0xE8D2),
]

# (estudiante, curso, progreso, tareas_pendientes, ultima_actividad)
MATRICULAS = [
    ("EST-0001", "CUR-001", 65, 2, "2026-06-05"),
    ("EST-0001", "CUR-002", 72, 1, "2026-06-07"),
    ("EST-0001", "CUR-003", 45, 3, "2026-06-03"),
    ("EST-0001", "CUR-007", 38, 4, "2026-06-08"),
    ("EST-0001", "CUR-008", 55, 2, "2026-06-06"),
    ("EST-0002", "CUR-001", 88, 0, "2026-06-08"),
    ("EST-0002", "CUR-002", 91, 1, "2026-06-08"),
    ("EST-0002", "CUR-006", 79, 2, "2026-06-07"),
    ("EST-0002", "CUR-007", 82, 1, "2026-06-08"),
    ("EST-0003", "CUR-001", 95, 0, "2026-06-08"),
    ("EST-0003", "CUR-002", 93, 0, "2026-06-08"),
    ("EST-0003", "CUR-003", 89, 1, "2026-06-08"),
    ("EST-0003", "CUR-006", 92, 0, "2026-06-08"),
    ("EST-0003", "CUR-007", 87, 1, "2026-06-08"),
]

FECHA_INICIO = datetime(2026, 3, 16)
FECHA_FIN = datetime(2026, 7, 15)


def ensure_database() -> None:
    """Crea la base de datos objetivo si no existe (conectando a 'postgres')."""
    url = make_url(DATABASE_URL)
    if not url.drivername.startswith("postgresql"):
        print("[seed] Datos no PostgreSQL; se omite creacion de base.")
        return

    dbname = url.database
    try:
        conn = psycopg2.connect(
            host=url.host or "localhost",
            port=url.port or 5432,
            user=url.username,
            password=url.password,
            dbname="postgres",
        )
    except Exception as exc:  # noqa: BLE001
        raise SystemExit(
            f"[seed] No se pudo conectar a PostgreSQL: {exc}\n"
            "Verifica DATABASE_URL en tu archivo .env"
        ) from exc

    conn.autocommit = True
    with conn.cursor() as cur:
        cur.execute("SELECT 1 FROM pg_database WHERE datname = %s", (dbname,))
        if cur.fetchone() is None:
            cur.execute(f'CREATE DATABASE "{dbname}"')
            print(f"[seed] Base de datos '{dbname}' creada.")
        else:
            print(f"[seed] Base de datos '{dbname}' ya existe.")
    conn.close()


def seed() -> None:
    ensure_database()

    print("[seed] Creando tablas...")
    Base.metadata.create_all(bind=engine)

    db = SessionLocal()
    try:
        # Evitar duplicados: limpiar y repoblar (demo)
        db.query(RiesgoPrediccion).delete()
        db.query(Matricula).delete()
        db.query(Curso).delete()
        db.query(Estudiante).delete()
        db.commit()

        print("[seed] Insertando estudiantes...")
        for est in ESTUDIANTES:
            db.add(
                Estudiante(
                    **est,
                    password_hash=hash_password(PASSWORD_DEMO),
                )
            )

        print("[seed] Insertando cursos...")
        for (idc, cod, nom, desc, cred, doc, de, color, icon) in CURSOS:
            db.add(
                Curso(
                    id_curso=idc,
                    codigo=cod,
                    nombre=nom,
                    descripcion=desc,
                    creditos=cred,
                    docente=doc,
                    docente_email=de,
                    semestre="2026-1",
                    facultad="Facultad de Ingenieria",
                    color_hex=color,
                    icon_code=icon,
                    activo=True,
                    fecha_inicio=FECHA_INICIO,
                    fecha_fin=FECHA_FIN,
                    moodle_url=f"https://moodle.universidad.edu.pe/course/view.php?id={idc[-3:]}",
                )
            )

        db.flush()

        print("[seed] Insertando matriculas...")
        for (est, cur, prog, tareas, fecha) in MATRICULAS:
            db.add(
                Matricula(
                    id_estudiante=est,
                    id_curso=cur,
                    estado="activo",
                    progreso_porcentaje=float(prog),
                    tareas_pendientes=tareas,
                    ultima_actividad=datetime.strptime(fecha, "%Y-%m-%d"),
                )
            )

        print(f"[seed] Leyendo predicciones de riesgo: {RIESGO_CSV_PATH}")
        if not os.path.exists(RIESGO_CSV_PATH):
            print(f"[seed] ADVERTENCIA: no existe el CSV en {RIESGO_CSV_PATH}. Se omite.")
        else:
            # Quedarse con el ultimo corte por (estudiante, curso)
            latest: dict[tuple[str, str], dict] = {}
            with open(RIESGO_CSV_PATH, newline="", encoding="utf-8-sig") as fh:
                reader = csv.DictReader(fh)
                for row in reader:
                    key = (row["id_estudiante"], row["id_curso"])
                    if key not in latest or row["fecha_corte"] > latest[key]["fecha_corte"]:
                        latest[key] = row

            for (est, cur), row in latest.items():
                db.add(
                    RiesgoPrediccion(
                        id_estudiante=est,
                        id_curso=cur,
                        fecha_corte=row["fecha_corte"],
                        calificacion_historica_promedio=float(
                            row["calificacion_historica_promedio"]
                        ),
                        dias_inactividad_consecutivos=int(
                            row["dias_inactividad_consecutivos"]
                        ),
                        probabilidad_riesgo=float(row["probabilidad_riesgo"]),
                        riesgo_academico_confirmado=int(
                            row["riesgo_academico_confirmado"]
                        ),
                    )
                )
            print(f"[seed] {len(latest)} predicciones insertadas.")

        db.commit()
        print("[seed] OK - Base de datos sembrada correctamente.")
        print(f"[seed] Usuarios demo: 20210001 / 20210002 / 20210003  (password: {PASSWORD_DEMO})")
    finally:
        db.close()


if __name__ == "__main__":
    seed()
