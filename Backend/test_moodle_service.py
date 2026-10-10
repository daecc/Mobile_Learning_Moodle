from app.services.moodle_service import MoodleScraperClient, moodle_service
from app.database import get_db_connection

def test_moodle_client_structure():
    client = MoodleScraperClient("https://aulavirtualsistemas.unmsm.edu.pe/pregrado")
    assert client.login_url == "https://aulavirtualsistemas.unmsm.edu.pe/pregrado/login/index.php"
    assert client.my_url == "https://aulavirtualsistemas.unmsm.edu.pe/pregrado/my/"

def test_moodle_service_sync_and_predict():
    res = moodle_service.sync_and_predict("cesar.alberto", "ClaveTest123!")
    assert "token" in res
    assert "estudiante" in res
    assert res["estudiante"]["id_estudiante"] == "EST-CESAR.ALBERTO"
    assert res["total_cursos"] > 0

    # Verify that cursos, metricas and predicciones were saved in SQLite
    conn = get_db_connection()
    cur = conn.cursor()
    cursos = cur.execute("SELECT * FROM cursos WHERE id_estudiante = 'EST-DOCENTE.TEST';").fetchall()
    preds = cur.execute("SELECT * FROM predicciones WHERE id_estudiante = 'EST-DOCENTE.TEST';").fetchall()
    conn.close()

    assert len(cursos) > 0
    assert len(preds) > 0
    print(f"Test passed! Created {len(cursos)} courses and {len(preds)} predictions.")

if __name__ == "__main__":
    test_moodle_client_structure()
    test_moodle_service_sync_and_predict()
    print("ALL MOODLE OFFICIAL SERVICE TESTS PASSED!")
