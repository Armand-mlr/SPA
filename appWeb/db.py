import psycopg2
import psycopg2.extras

def connect():
    try:
        conn = psycopg2.connect(
            dbname='armandmlr',
            host='localhost',
            user='armandmlr',
            password='xxxxx',
            port=5432,
            cursor_factory=psycopg2.extras.NamedTupleCursor
        )
        conn.autocommit = True
        return conn
    except Exception as e:
        print("Erreur de connexion à PostgreSQL :", e)
        return None
