import psycopg2
import psycopg2.extras
#Need to adapt to your database info.
def connect():
    try:
        conn = psycopg2.connect(
            dbname='armand_db',
            host='localhost',
            user='Armand',
            password='x',
            port=5432,
            cursor_factory=psycopg2.extras.NamedTupleCursor
        )
        conn.autocommit = True
        return conn
    except Exception as e:
        print("Erreur de connexion à PostgreSQL :", e)
        return None
