import sys
from app.services.moodle_service import MoodleRestClient, moodle_service
from app.database import get_db_connection

def test_moodle_client_structure():
    client = MoodleRestClient("https://rumbo-mobile-learning.moodlecloud.com")
    assert client.token_url == "https://rumbo-mobile-learning.moodlecloud.com/login/token.php"
    assert client.server_url == "https://rumbo-mobile-learning.moodlecloud.com/webservice/rest/server.php"
    print("test_moodle_client_structure PASSED")

def test_moodle_guillermo_login():
    res = moodle_service.sync_and_predict("guillermo1234", "Base22SW42")
    assert "token" in res
    assert "estudiante" in res
    assert res["estudiante"]["id_estudiante"] == "EST-GUILLERMO1234"
    assert "Guillermo" in res["estudiante"]["nombre"]
    assert res["total_cursos"] == 3
    print(f"Guillermo login passed! Cursos matriculados: {res['total_cursos']}")

    # Verify that cursos, metricas and predicciones were saved in SQLite
    conn = get_db_connection()
    cur = conn.cursor()
    cursos = cur.execute("SELECT * FROM cursos WHERE id_estudiante = 'EST-GUILLERMO1234';").fetchall()
    preds = cur.execute("SELECT * FROM predicciones WHERE id_estudiante = 'EST-GUILLERMO1234';").fetchall()
    conn.close()

    assert len(cursos) == 3
    assert len(preds) == 3
    print(f"SQLite verified! Found {len(cursos)} courses and {len(preds)} predictions for Guillermo.")

def test_moodle_joseph_login():
    res = moodle_service.sync_and_predict("josephr.c27", "Base22SW41")
    assert "token" in res
    assert "estudiante" in res
    assert res["estudiante"]["id_estudiante"] == "EST-JOSEPHR.C27"
    assert "Joseph" in res["estudiante"]["nombre"]
    assert res["total_cursos"] >= 2
    print(f"Joseph login passed! Cursos matriculados: {res['total_cursos']}")

if __name__ == "__main__":
    test_moodle_client_structure()
    test_moodle_guillermo_login()
    test_moodle_joseph_login()
    print(">>> ALL MOODLE OFFICIAL SERVICE TESTS PASSED SUCCESSFULLY! <<<")
