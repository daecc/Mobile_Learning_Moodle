"""Configuracion de la aplicacion (variables de entorno)."""
import os

from dotenv import load_dotenv

load_dotenv()

# URL de conexion a PostgreSQL (SQLAlchemy). Ajustar en .env
DATABASE_URL: str = os.getenv(
    "DATABASE_URL",
    "postgresql+psycopg2://postgres:postgres@localhost:5432/mlearning",
)

# JWT
JWT_SECRET: str = os.getenv("JWT_SECRET", "mlearning-demo-secret-change-me")
JWT_ALGORITHM: str = os.getenv("JWT_ALGORITHM", "HS256")
ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "120"))

# CORS
_cors = os.getenv("CORS_ORIGINS", "*")
CORS_ORIGINS: list[str] = [o.strip() for o in _cors.split(",") if o.strip()]

# API
API_PREFIX: str = "/api/v1"
