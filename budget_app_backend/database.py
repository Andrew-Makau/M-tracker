from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text

# create the database object here
db = SQLAlchemy() # ✅ define once here


def create_user_tables(user_id: int):
	"""Create per-user mirrored tables for transactions and budgets.

	Tables are named `user_{id}_transactions` and `user_{id}_budgets`.
	This mirrors shared tables for easier per-user exports and isolation.
	"""
	tx_table = f'user_{user_id}_transactions'
	bud_table = f'user_{user_id}_budgets'

	tx_sql = f'''
	CREATE TABLE IF NOT EXISTS "{tx_table}" (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		amount REAL NOT NULL,
		type TEXT NOT NULL,
		category_id INTEGER,
		date TEXT,
		note TEXT
	);
	'''

	bud_sql = f'''
	CREATE TABLE IF NOT EXISTS "{bud_table}" (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT NOT NULL,
		amount REAL,
		start_date TEXT,
		end_date TEXT
	);
	'''

	# Execute DDL statements in the current app context/connection
	db.session.execute(text(tx_sql))
	db.session.execute(text(bud_sql))
	db.session.commit()


def insert_user_transaction(user_id: int, amount: float, t_type: str, category_id, tx_date, note: str):
	tx_table = f'user_{user_id}_transactions'
	insert_sql = text(f'INSERT INTO "{tx_table}" (amount, type, category_id, date, note) VALUES (:amount, :type, :category_id, :date, :note)')
	params = {
		'amount': float(amount),
		'type': t_type,
		'category_id': int(category_id) if category_id is not None else None,
		'date': tx_date.isoformat() if hasattr(tx_date, 'isoformat') else (str(tx_date) if tx_date is not None else None),
		'note': note,
	}
	db.session.execute(insert_sql, params)
	db.session.commit()
        