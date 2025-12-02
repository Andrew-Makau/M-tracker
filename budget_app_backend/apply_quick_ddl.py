"""
apply_quick_ddl.py

Development helper: inspect the current SQLite database and add missing
columns (using ALTER TABLE ... ADD COLUMN) for a subset of known schema
changes. This is a convenience for local development only; prefer
using Flask-Migrate / Alembic for real migrations.

Run:
  python apply_quick_ddl.py

"""
from sqlalchemy import inspect, text
from app import app
from database import db

CHECKS = [
    # (table_name, column_name, column_sql)
    ('user', 'settings', 'JSON'),
    ('category', 'user_id', 'INTEGER'),
    ('transaction', 'user_id', 'INTEGER'),
    ('budget', 'user_id', 'INTEGER'),
]


def column_exists(inspector, table, column):
    cols = [c['name'] for c in inspector.get_columns(table)]
    return column in cols


def run():
    with app.app_context():
        # db.engine is available when app context is pushed
        engine = db.engine
        inspector = inspect(engine)

        for table, col, coltype in CHECKS:
            try:
                if table not in inspector.get_table_names():
                    print(f"Table '{table}' not present; skipping")
                    continue
            except Exception:
                # Some SQLite file issues may cause inspector to error
                print(f"Could not inspect table list; aborting")
                return

            if column_exists(inspector, table, col):
                print(f"Column '{col}' already exists on '{table}'")
                continue

            # For SQLite the simplest supported change is ADD COLUMN with NULL/default
            alter_sql = f'ALTER TABLE "{table}" ADD COLUMN {col} {coltype} NULL'
            print(f"Applying: {alter_sql}")
            try:
                with engine.begin() as conn:
                    conn.execute(text(alter_sql))
                print(f"Added column '{col}' to '{table}' (dev)")
            except Exception as e:
                print(f"Failed to add column '{col}' to '{table}': {e}")


if __name__ == '__main__':
    print('Running quick DDL checks...')
    run()
    print('Done')
