from pathlib import Path
from typing import Dict, List, Optional, Any
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent.parent.parent
CSV_PATH = BASE_DIR.parent / "Entrenamiento" / "MobileLearning" / "riesgo_academico.csv"

# Catálogo descriptivo de cursos según la dimensión de Ingeniería de Software
CATALOGO_CURSOS = {
    "CUR-001": {"nombre": "Patrones de Diseño de Software", "codigo": "IS-401", "creditos": 4, "docente": "Mg. Carlos Mendoza"},
    "CUR-002": {"nombre": "Ingeniería de Requisitos", "codigo": "IS-402", "creditos": 4, "docente": "Ing. Renzo Huamán"},
    "CUR-003": {"nombre": "Arquitectura de Software", "codigo": "IS-403", "creditos": 3, "docente": "Dr. Fernando Quispe"},
    "CUR-004": {"nombre": "Base de Datos II", "codigo": "IS-404", "creditos": 4, "docente": "Mg. Patricia Morales"},
    "CUR-005": {"nombre": "Gestión de Proyectos de Software", "codigo": "IS-405", "creditos": 3, "docente": "Ing. Jorge Alarcón", "fecha_estimacion": "Desde el 19 de oct."},
    "CUR-006": {"nombre": "Algoritmos y Estructura de Datos", "codigo": "IS-406", "creditos": 4, "docente": "Dr. Alberto Soto"},
    "CUR-007": {"nombre": "Redes y Comunicaciones", "codigo": "IS-407", "creditos": 3, "docente": "Ing. Diana Paredes"},
    "CUR-008": {"nombre": "Inteligencia Artificial Aplicada", "codigo": "IS-408", "creditos": 4, "docente": "Dr. David Cisneros"},
}

class DataRepository:
    def __init__(self):
        self.df: Optional[pd.DataFrame] = None
        self._load_data()

    def _load_data(self):
        if CSV_PATH.exists():
            self.df = pd.read_csv(CSV_PATH)
        else:
            self.df = pd.DataFrame()

    def get_student_profile(self, id_estudiante: str) -> Dict[str, str]:
        id_norm = id_estudiante.strip().upper()
        if id_norm in ["ADMIN", "EST-ADMIN", "DEMO"]:
            return {
                "id_estudiante": "EST-ADMIN",
                "nombre": "Admin User",
                "carrera": "Ingeniería de Software",
                "ciclo": "Pregrado",
                "email": "admin@universidad.edu.pe"
            }
        else:
            return {
                "id_estudiante": id_norm,
                "nombre": f"Estudiante {id_norm}",
                "carrera": "Ingeniería de Software",
                "ciclo": "Pregrado",
                "email": f"{id_norm.lower()}@universidad.edu.pe"
            }

    def get_student_courses_latest(self, id_estudiante: str) -> List[Dict[str, Any]]:
        id_norm = id_estudiante.strip().upper()
        if self.df is None or self.df.empty:
            return []

        sub = self.df[self.df["id_estudiante"] == id_norm]
        if sub.empty:
            # Si no existe, tomar por defecto las del primer estudiante
            sub = self.df[self.df["id_estudiante"] == "EST-0001"]

        # Tomar el corte temporal más reciente para cada curso
        latest_corte = sub["fecha_corte"].max()
        sub_latest = sub[sub["fecha_corte"] == latest_corte]

        courses_data = []
        for _, row in sub_latest.iterrows():
            cid = row["id_curso"]
            cat = CATALOGO_CURSOS.get(cid, {
                "nombre": f"Curso {cid}",
                "codigo": cid,
                "creditos": 3,
                "docente": "Docente Asignado"
            })
            item = dict(row)
            item.update(cat)
            courses_data.append(item)

        return courses_data

    def get_course_detail(self, id_estudiante: str, id_curso: str) -> Optional[Dict[str, Any]]:
        id_norm = id_estudiante.strip().upper()
        cid_norm = id_curso.strip().upper()
        
        if self.df is None or self.df.empty:
            return None

        sub = self.df[(self.df["id_estudiante"] == id_norm) & (self.df["id_curso"] == cid_norm)]
        if sub.empty:
            # Fallback
            sub = self.df[(self.df["id_estudiante"] == "EST-0001") & (self.df["id_curso"] == cid_norm)]
            if sub.empty:
                return None

        # Tomar el corte temporal más reciente
        row = sub.sort_values("fecha_corte", ascending=False).iloc[0]
        cat = CATALOGO_CURSOS.get(cid_norm, {
            "nombre": f"Curso {cid_norm}",
            "codigo": cid_norm,
            "creditos": 3,
            "docente": "Docente Asignado"
        })
        item = dict(row)
        item.update(cat)
        return item

data_repo = DataRepository()
