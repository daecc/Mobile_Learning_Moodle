from fastapi import APIRouter, HTTPException
from app.models import CustomPredictionRequest, CustomPredictionResponse
from app.services.ml_service import predecir_vector

router = APIRouter(prefix="/api/predict", tags=["Inferencia Directa de ML"])

@router.post("", response_model=CustomPredictionResponse)
def predict_risk(payload: CustomPredictionRequest):
    try:
        vector = payload.model_dump()
        proba, pct, nivel = predecir_vector(vector)
        confirmado = 1 if pct >= 50 else 0
        return CustomPredictionResponse(
            probabilidad_riesgo=round(proba, 4),
            porcentaje_riesgo=pct,
            nivel_riesgo=nivel,
            riesgo_confirmado=confirmado
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
