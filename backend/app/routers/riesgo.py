"""Router de prediccion de riesgo academico. Requiere JWT valido."""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import RiesgoPrediccion
from ..schemas import RiesgoOut
from ..security import get_current_user

router = APIRouter(tags=["riesgo"])


@router.get("/riesgo", response_model=RiesgoOut)
def get_riesgo(
    id_estudiante: str = Query(...),
    id_curso: str = Query(...),
    current_user: str = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> RiesgoOut:
    if id_estudiante != current_user:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="No autorizado a ver el riesgo de otro estudiante.",
        )

    prediccion = (
        db.query(RiesgoPrediccion)
        .filter(
            RiesgoPrediccion.id_estudiante == id_estudiante,
            RiesgoPrediccion.id_curso == id_curso,
        )
        .order_by(RiesgoPrediccion.fecha_corte.desc())
        .first()
    )

    if prediccion is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No hay prediccion para {id_estudiante}/{id_curso}.",
        )

    return RiesgoOut.model_validate(prediccion)
