# Backend M-Learning Early Warning (FastAPI + PostgreSQL)

API REST que consume la app Flutter (patrón MVVM). Expone login con JWT,
cursos matriculados y predicción de riesgo académico.

## Requisitos
- Python 3.10+
- PostgreSQL instalado y corriendo (pgAdmin)

## Configuración
1. Copia `.env.example` a `.env` y ajusta tus credenciales de PostgreSQL:
   ```
   DATABASE_URL=postgresql+psycopg2://postgres:TU_PASSWORD@localhost:5432/mlearning
   ```
   La base de datos `mlearning` se crea automáticamente al ejecutar el seed.

## Instalación y ejecución
```powershell
# Desde la carpeta backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Sembrar la base de datos (estudiantes, cursos, matrículas, riesgo)
python -m app.seed

# Levantar el servidor
uvicorn app.main:app --reload --port 8000
```

- API: http://127.0.0.1:8000
- Docs (Swagger): http://127.0.0.1:8000/docs
- Health: http://127.0.0.1:8000/api/v1/health

## Endpoints
| Método | Ruta | Auth | Descripción |
|--------|------|------|-------------|
| POST | `/api/v1/auth/login` | No | Login (código o email + password) |
| GET | `/api/v1/estudiantes/{id}/cursos` | JWT | Cursos matriculados |
| GET | `/api/v1/riesgo?id_estudiante=&id_curso=` | JWT | Predicción de riesgo |
| GET | `/api/v1/cursos/{id}` | JWT | Detalle de curso |

## Usuarios demo
| Código | Password |
|--------|----------|
| 20210001 | 123456 |
| 20210002 | 123456 |
| 20210003 | 123456 |

## Notas
- El endpoint de riesgo sirve las probabilidades ya calculadas del
  `riesgo_academico.csv` (no re-ejecuta el modelo en vivo).
- Los endpoints protegidos requieren header `Authorization: Bearer <token>`,
  donde `<token>` es el `access_token` devuelto por el login.
