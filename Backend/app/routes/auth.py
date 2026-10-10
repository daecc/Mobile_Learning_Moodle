from fastapi import APIRouter, HTTPException, status
import logging
from app.models import LoginRequest, LoginResponse, StudentProfile
from app.services.moodle_service import moodle_service, MOODLE_BASE_URL
from app.services.data_service import data_repo
from app.database import get_db_connection

logger = logging.getLogger("auth_route")

router = APIRouter(prefix="/api/auth", tags=["Autenticación"])

@router.post("/login", response_model=LoginResponse)
def login(payload: LoginRequest):
    codigo = payload.codigo.strip()
    password = payload.password.strip()

    if not codigo:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Debe ingresar su usuario institucional de Moodle."
        )

    if not password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Debe ingresar su contraseña."
        )

    # Modo DEMO universitario sin servidor externo
    id_upper = codigo.upper()
    if id_upper in ["DEMO"]:
        profile_dict = data_repo.get_student_profile(codigo)
        profile = StudentProfile(**profile_dict)
        _seed_demo_to_sqlite(profile.id_estudiante)
        return LoginResponse(
            token=f"token_demo_{profile.id_estudiante.lower()}",
            estudiante=profile
        )

    # Autenticación oficial con Moodle LMS mediante Web Services REST
    try:
        res = moodle_service.sync_and_predict(codigo, password)

        profile = StudentProfile(
            id_estudiante=res["estudiante"]["id_estudiante"],
            nombre=res["estudiante"]["nombre"],
            carrera=res["estudiante"]["carrera"],
            ciclo=res["estudiante"]["ciclo"],
            email=res["estudiante"]["email"]
        )

        return LoginResponse(
            token=res["token"],
            estudiante=profile
        )

    except ValueError as moodle_err:
        logger.warning(f"Error de credenciales en Moodle para {codigo}: {moodle_err}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(moodle_err)
        )

    except ConnectionError as conn_err:
        logger.error(f"Error de conexión con Aula Virtual FISI ({MOODLE_BASE_URL}): {conn_err}")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"No se pudo conectar con el Aula Virtual en {MOODLE_BASE_URL}. Revisa tu conexión a internet."
        )

def _seed_demo_to_sqlite(id_estudiante: str):
    """Sincroniza el estudiante en SQLite."""
    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
    INSERT INTO estudiantes (id_estudiante, username, nombre, correo, carrera, ciclo)
    VALUES (?, 'cesar.alberto', 'CESAR ALBERTO', 'cesar.alberto@unmsm.edu.pe', 'Ingeniería de Sistemas (FISI - UNMSM)', 'Pregrado')
    ON CONFLICT(id_estudiante) DO NOTHING;
    """, (id_estudiante,))

    conn.commit()
    conn.close()
