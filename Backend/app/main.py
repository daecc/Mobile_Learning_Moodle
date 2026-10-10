from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import auth, cursos, predict

app = FastAPI(
    title="Rumbo API · Mobile Learning Moodle",
    description="Backend REST con Inteligencia Artificial para la predicción temprana de riesgo académico y analítica metacognitiva.",
    version="1.0.0"
)

# CORS abierto para Flutter (web, emulador Android, iOS y desktop)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Registrar rutas
app.include_router(auth.router)
app.include_router(cursos.router)
app.include_router(predict.router)

@app.get("/", tags=["Estado"])
def root():
    return {
        "sistema": "Rumbo API · Mobile Learning Moodle",
        "version": "1.0.0",
        "estado": "operativo",
        "documentacion": "/docs",
        "arquitectura": "FastAPI + Scikit-learn + Moodle Logs"
    }

@app.get("/health", tags=["Estado"])
def health_check():
    return {"status": "ok"}
