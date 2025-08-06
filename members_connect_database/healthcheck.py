"""
Simple MySQL healthcheck: connect and verify required tables.
"""
import os
import pymysql

REQUIRED_TABLES = [
    "users", "profiles", "connections", "referrals", "meetings", "notifications"
]

def get_env(var, default=None):
    return os.environ.get(var, default)

def check_mysql_connection():
    host = get_env("MYSQL_HOST", "localhost")
    port = int(get_env("MYSQL_PORT", "3306"))
    user = get_env("MYSQL_USER", "root")
    passwd = get_env("MYSQL_PASSWORD", "")
    db = get_env("MYSQL_DATABASE", "myapp")
    conn = pymysql.connect(host=host, port=port, user=user, password=passwd, database=db)
    try:
        with conn.cursor() as cur:
            cur.execute("SHOW TABLES;")
            tables = [row[0] for row in cur.fetchall()]
            missing = [table for table in REQUIRED_TABLES if table not in tables]
            if missing:
                print(f"FAIL: Missing tables {missing}")
                return False
            print("MySQL Healthcheck: All required tables present.")
            return True
    finally:
        conn.close()

if __name__ == "__main__":
    ok = check_mysql_connection()
    exit(0 if ok else 1)
