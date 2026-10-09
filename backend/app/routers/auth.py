"""Router de autenticacion: login que emite JWT."""
from __future__ import annotations

from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import or_
from sqlalchemy.orm import Session

from ..config import ACCESS_TOKEN_EXPIRE_MINUTES
from ..database import get_db
from ..models import Estudiante
from ..schemas import LoginRequest, LoginResponse, UserOut
from ..security import (
    create_access_token,
    create_refresh_token,
    verify_password,
)

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login", response_model=LoginResponse)
def login(body: LoginRequest, db: Session = Depends(get_db)) -> LoginResponse:
    estate = (
        db.query(Estudiante)
        .filter(
            or_(
                Estudiante.codigo_universitario == body.username,
                Estudiante.email == body.username,
            )
        )
        .first()
    )

    if estate is None or not verify_password(body.password, estate.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciales incorrectas. Verifica tu codigo universitario y contrasena.",
        )

    access_token = create_access_token(estate.id_estudiante)
    refresh_token = create_refresh_token(estate.id_estudiante)
    expires_in = ACCESS_TOKEN_EXPIRE_MINUTES * 60
    token_expiry = datetime.now(timezone.utc) + timedelta(seconds=expires_in)

    user = UserOut(
        id_estudiante=estate.id_estudiante,
        codigo_universitario=estate.codigo_universitario,
        nombres=estate.nombres,
        apellidos=estate.apellidos,
        email=estate.email,
        programa_estudios=estate.programa_estudios,
        ciclo_actual=estate.ciclo_actual,
        facultad=estate.facultad,
        token=access_token,
        token_expiry=token_expiry.isoformat(),
    )

    return LoginResponse(
        user=user,
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=expires_in,
    )
