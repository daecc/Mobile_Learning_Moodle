from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_api():
    print("--- Test 1: Root endpoint ---")
    r = client.get("/")
    print("Status:", r.status_code, r.json())
    assert r.status_code == 200

    print("\n--- Test 2: Login ---")
    r = client.post("/api/auth/login", json={"codigo": "admin", "password": "AdminMoodle2026!"})
    print("Status:", r.status_code, r.json())
    assert r.status_code == 200

    print("\n--- Test 3: Cursos del estudiante EST-ADMIN ---")
    r = client.get("/api/estudiantes/EST-ADMIN/cursos")
    data = r.json()
    print("Status:", r.status_code)
    print("Estudiante:", data.get("nombre_estudiante"))
    print("Resumen:", data.get("resumen_riesgo"))
    for c in data.get("cursos", []):
        print(f"  - [{c['codigo_curso']}] {c['nombre_curso']}: {c['porcentaje_riesgo']}% ({c['nivel_riesgo']})")
    assert r.status_code == 200
    assert len(data.get("cursos", [])) > 0

    first_course = data.get("cursos")[0]["id_curso"]
    print(f"\n--- Test 4: Detalle de riesgo para {first_course} ---")
    r = client.get(f"/api/estudiantes/EST-ADMIN/cursos/{first_course}/riesgo")
    detail = r.json()
    print("Status:", r.status_code)
    print(f"Curso: {detail.get('nombre_curso')} | Nivel: {detail.get('nivel_riesgo')} ({detail.get('porcentaje_riesgo')}%)")
    print(f"Alerta: {detail.get('alerta_titulo')} -> {detail.get('alerta_mensaje')}")
    print(f"Recomendación: {detail.get('accion_recomendada')}")
    print("Métricas:")
    for m in detail.get("metricas", []):
        unidad = m.get("unidad") or ""
        print(f"  * {m['titulo']}: {m['valor']} {unidad} [{m['estado']}]")
    assert r.status_code == 200

    print("\n--- Test 5: Inferencia ML directa ---")
    r = client.post("/api/predict", json={
        "carga_academica_actual": 5,
        "calificacion_historica_promedio": 8.0,
        "tendencia_calificaciones": -0.8,
        "tasa_acierto_primer_intento": 0.25,
        "duracion_intento_minutos": 30,
        "indice_friccion_cognitiva": 5.0,
        "dias_inactividad_consecutivos": 14,
        "tasa_entregas_tardias": 0.8,
        "nivel_interaccion_social": 0.1,
        "tasa_visualizacion_materiales": 0.15
    })
    pred = r.json()
    print("Status:", r.status_code, pred)
    assert r.status_code == 200
    assert pred["nivel_riesgo"] == "CRITICO"

    print("\nTODAS LAS PRUEBAS DEL BACKEND PASARON EXITOSAMENTE (5/5)")

if __name__ == "__main__":
    test_api()
