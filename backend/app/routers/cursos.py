"""Router de cursos y matriculas. Requiere JWT valido."""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Curso, Matricula
from ..schemas import CourseOut, EnrollmentOut
from ..security import get_current_user

router = APIRouter(tags=["cursos"])


@router.get("/estudiantes/{id_estudiante}/cursos", response_model=list[EnrollmentOut])
def get_mis_cursos(
    id_estudiante: str,
    current_user: str = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> list[EnrollmentOut]:
    # Un estudiante solo puede ver sus propios cursos
    if id_estudiante != current_user:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="No autorizado a ver los cursos de otro estudiante.",
        )

    matriculas = (
        db.query(Matricula, Curso)
        .join(Curso, Matricula.id_curso == Curso.id_curso)
        .filter(Matricula.id_estudiante == id_estudiante)
        .all()
    )

    return [
        EnrollmentOut(
            course=CourseOut.model_validate(curso),
            estado=matricula.estado,
            progreso_porcentaje=matricula.progreso_porcentaje,
            tareas_pendientes=matricula.tareas_pendientes,
            ultima_actividad=matricula.ultima_actividad,
        )
        for matricula, curso in matriculas
    ]


@router.get("/cursos/{id_curso}", response_model=CourseOut)
def get_curso(
    id_curso: str,
    current_user: str = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> CourseOut:
    curso = db.query(Curso).filter(Curso.id_curso == id_curso).first()
    if curso is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Curso no encontrado: {id_curso}",
        )
    return CourseOut.model_validate(curso)
