"""
Pipeline de generación de dataset y entrenamiento de Regresión Logística (7 variables reales).
Exporta directamente a Backend/ml_models/:
- features.joblib
- scaler.joblib
- model.joblib
"""
import numpy as np
import pandas as pd
from pathlib import Path
import joblib
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, roc_auc_score

SEED = 42
rng = np.random.default_rng(SEED)

BASE_DIR = Path(__file__).resolve().parent
ML_MODELS_DIR = BASE_DIR.parent.parent / "Backend" / "ml_models"
ML_MODELS_DIR.mkdir(parents=True, exist_ok=True)

N_REGISTROS = 7500

# 1. Generación de las 7 variables sintéticas basadas en distribuciones reales de Moodle
# Variables latentes de base para mantener coherencia entre notas y comportamiento
habilidad = rng.beta(a=4, b=3, size=N_REGISTROS)
compromiso = np.clip(0.6 * habilidad + 0.4 * rng.beta(a=3, b=3, size=N_REGISTROS), 0, 1)

# 1. promedio_calificaciones (0.0 a 20.0)
promedio_calificaciones = np.clip(rng.normal(loc=habilidad * 16 + 2, scale=1.8), 0.0, 20.0).round(2)

# 2. tendencia_calificaciones (pendiente en pts/corte: -3.0 a +3.0)
tendencia_calificaciones = np.clip(rng.normal(loc=(habilidad - 0.5) * 2.0, scale=0.8), -3.0, 3.0).round(3)

# 3. dias_inactividad (0 a 30 días)
dias_inactividad = np.clip(rng.exponential(scale=(1.0 - compromiso) * 8 + 1), 0, 30).astype(int)

# 4. tasa_tareas_pendientes (0.0 a 1.0)
tasa_tareas_pendientes = np.clip(rng.beta(a=(1.0 - compromiso) * 4 + 1, b=compromiso * 4 + 1), 0.0, 1.0).round(3)

# 5. margen_entrega_horas (horas antes de duedate; negativo si tarde, penalización -48 para no entregados)
# Para estudiantes comprometidos: entregan con +12 a +72 horas de anticipación
# Para estudiantes con bajo compromiso: entregan al filo (+0.1 a +2 horas) o retrasados/no entregados (-48)
margen_raw = rng.normal(loc=(compromiso * 48) - 10, scale=18)
# Inyectar penalización de -48 para alumnos que deben tareas altas
margen_entrega_horas = np.where(
    tasa_tareas_pendientes > 0.6,
    -48.0,
    np.clip(margen_raw, -48.0, 72.0)
).round(1)

# 6. asistencia_formal_sesiones (0.0 a 1.0)
asistencia_formal_sesiones = np.clip(rng.beta(a=compromiso * 8 + 2, b=(1.0 - compromiso) * 3 + 1), 0.0, 1.0).round(3)

# 7. asistencia_virtual_regularidad (0.0 a 1.0)
asistencia_virtual_regularidad = np.clip(rng.beta(a=compromiso * 6 + 2, b=(1.0 - compromiso) * 4 + 1), 0.0, 1.0).round(3)

df = pd.DataFrame({
    "promedio_calificaciones": promedio_calificaciones,
    "tendencia_calificaciones": tendencia_calificaciones,
    "dias_inactividad": dias_inactividad,
    "tasa_tareas_pendientes": tasa_tareas_pendientes,
    "margen_entrega_horas": margen_entrega_horas,
    "asistencia_formal_sesiones": asistencia_formal_sesiones,
    "asistencia_virtual_regularidad": asistencia_virtual_regularidad,
})

# Estandarización interna para construir la probabilidad de riesgo de referencia
def std(s):
    return (s - s.mean()) / s.std()

# Criterio Académico Oficial UNMSM (Escala 0 - 20):
# 1. Menor a 9.5: Crítico (Desaprobado severo, rezago confirmado)
# 2. De 9.5 a 10.4: Desaprobado moderado (en riesgo si no recupera en sustitutorio)
# 3. De 10.5 a 13.4: Aprobado moderado (en observación, vulnerable si descuida conducta)
# 4. De 13.5 a más: Aprobado con solvencia (colchón seguro)
riesgo_base_unmsm = np.where(df["promedio_calificaciones"] < 9.5, 3.5,
                    np.where(df["promedio_calificaciones"] < 10.5, 1.8,
                    np.where(df["promedio_calificaciones"] < 13.5, -0.8, -3.2)))

# Factores de riesgo: promedio base UNMSM (+/-), inactividad (+), tareas pendientes (+)
# Factores protectores: tendencia (-), margen anticipado (-), asistencia formal e virtual (-)
z = (
    riesgo_base_unmsm
    - 0.8 * std(df["tendencia_calificaciones"])
    + 0.9 * std(df["dias_inactividad"])
    + 0.9 * std(df["tasa_tareas_pendientes"])
    - 0.6 * std(df["margen_entrega_horas"])
    - 0.5 * std(df["asistencia_formal_sesiones"])
    - 0.4 * std(df["asistencia_virtual_regularidad"])
    + rng.normal(0, 0.4, size=len(df))
)

prob = 1.0 / (1.0 + np.exp(-z))
df["riesgo_confirmado"] = rng.binomial(1, prob)

print("Distribución de la etiqueta de riesgo:")
print(df["riesgo_confirmado"].value_counts(normalize=True).round(3))

feature_cols = [
    "promedio_calificaciones",
    "tendencia_calificaciones",
    "dias_inactividad",
    "tasa_tareas_pendientes",
    "margen_entrega_horas",
    "asistencia_formal_sesiones",
    "asistencia_virtual_regularidad",
]

X = df[feature_cols]
y = df["riesgo_confirmado"]

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.25, random_state=SEED, stratify=y)

scaler = StandardScaler()
X_train_esc = scaler.fit_transform(X_train)
X_test_esc = scaler.transform(X_test)

modelo = LogisticRegression(max_iter=1000, random_state=SEED, C=1.0)
modelo.fit(X_train_esc, y_train)

# Evaluación
y_pred = modelo.predict(X_test_esc)
y_prob = modelo.predict_proba(X_test_esc)[:, 1]

print("\n--- Métricas del Modelo con 7 Variables ---")
print(f"Accuracy : {accuracy_score(y_test, y_pred):.4f}")
print(f"Precision: {precision_score(y_test, y_pred):.4f}")
print(f"Recall   : {recall_score(y_test, y_pred):.4f}")
print(f"F1-Score : {f1_score(y_test, y_pred):.4f}")
print(f"AUC-ROC  : {roc_auc_score(y_test, y_prob):.4f}")

# Reentrenar sobre todo el dataset para exportación a producción
X_completo_esc = scaler.fit_transform(X)
modelo.fit(X_completo_esc, y)

# Exportar a Backend/ml_models/
joblib.dump(modelo, ML_MODELS_DIR / "model.joblib")
joblib.dump(scaler, ML_MODELS_DIR / "scaler.joblib")
joblib.dump(feature_cols, ML_MODELS_DIR / "features.joblib")

# Guardar dataset actualizado
df.to_csv(BASE_DIR / "dataset_7_variables.csv", index=False)

print(f"\n[OK] Artefactos exportados exitosamente a {ML_MODELS_DIR.resolve()}:")
print(f"   - model.joblib (Pesos coeficientes: {modelo.coef_[0].round(3)})")
print(f"   - scaler.joblib")
print(f"   - features.joblib: {feature_cols}")
