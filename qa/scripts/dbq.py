"""Read-only SQL helper for QA: runs one query inside a READ ONLY
transaction against the DATABASE_URL in zaytona_api/.env and prints rows.

usage: python dbq.py "select ..."   (or --json for JSON output)
"""
import json
import sys
from pathlib import Path

import psycopg2
from dotenv import dotenv_values

ENV = Path(r"C:\Users\mmhd7\Downloads\Zaytona.app\zaytona\zaytona_api\.env")


def dsn():
    url = dotenv_values(ENV, interpolate=False)["DATABASE_URL"]
    return url.replace("postgresql+psycopg2://", "postgresql://", 1)


def query(sql, params=None):
    conn = psycopg2.connect(dsn(), connect_timeout=15)
    try:
        conn.set_session(readonly=True, autocommit=False)
        with conn.cursor() as cur:
            cur.execute(sql, params)
            cols = [d[0] for d in cur.description]
            rows = cur.fetchall()
        conn.rollback()
        return cols, rows
    finally:
        conn.close()


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    as_json = "--json" in sys.argv
    sql = [a for a in sys.argv[1:] if a != "--json"][0]
    cols, rows = query(sql)
    if as_json:
        print(json.dumps([dict(zip(cols, r)) for r in rows], default=str, ensure_ascii=False, indent=1))
    else:
        print(" | ".join(cols))
        for r in rows:
            print(" | ".join("" if v is None else str(v) for v in r))
        print(f"({len(rows)} rows)")
