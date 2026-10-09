"""Punto de entrada FastAPI - M-Learning Early Warning API.

Ejecutar:
    uvicorn app.main:app --reload --port 8000

Docs interactivas: http://127.0.0.1:8000/docs
"""
from __future__ import annotations

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import API_PREFIX, CORS_ORIGINS
from .database import Base, engine
from .routers import auth, cursos, riesgo

# Crea las tablas si no existen
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="M-Learning Early Warning API",
    description="Backend del Sistema de Alerta Temprana Academica (MVVM Flutter)",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS if CORS_ORIGINS else ["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix=API_PREFIX)
app.include_router(cursos.router, prefix=API_PREFIX)
app.include_router(riesgo.router, prefix=API_PREFIX)


@app.get("/", tags=["root"])
def root() -> dict:
    return {
        "name": "M-Learning Early Warning API",
        "version": "1.0.0",
        "docs": "/docs",
        "api_prefix": API_PREFIX,
    }


@app.get(f"{API_PREFIX}/health", tags=["root"])
def health() -> dict:
    return {"status": "ok"}
