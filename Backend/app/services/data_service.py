from pathlib import Path
from typing import Dict, List, Optional, Any
import pandas as pd

class DataRepository:
    """Repositorio auxiliar para perfiles demo y contingencia."""

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


data_repo = DataRepository()

