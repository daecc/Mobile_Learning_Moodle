import sqlite3

conn = sqlite3.connect('Backend/rumbo.db')
cursor = conn.cursor()

cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
tables = [r[0] for r in cursor.fetchall()]
print("Tables:", tables)

for t in tables:
    cursor.execute(f"SELECT count(*) FROM {t}")
    cnt = cursor.fetchone()[0]
    cursor.execute(f"PRAGMA table_info({t})")
    cols = [f"{c[1]} ({c[2]})" for c in cursor.fetchall()]
    print(f"\n--- Table: {t} (Rows: {cnt}) ---")
    print("Columns:", ", ".join(cols))

