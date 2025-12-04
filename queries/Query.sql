-- Queries for user_id = 1 (SQLite / DB Browser friendly)
-- Copy & paste any of the SQL blocks below into DB Browser (Execute SQL tab)
-- Or run them with the sqlite3 CLI against `budget.db` in `budget_app_backend`.

-- 1) Recent transactions (last 10) for user 1
SELECT id, amount, type, category_id, date, note
FROM "transaction"
WHERE user_id = 1
ORDER BY date DESC
LIMIT 10;

-- 2) All transactions for user 1 (newest first)
SELECT id, amount, type, category_id, date, note
FROM "transaction"
WHERE user_id = 1
ORDER BY date DESC;

-- 3) Totals by category for the current month
SELECT
	c.id AS category_id,
	c.name AS category_name,
	COALESCE(SUM(CASE WHEN t.type = 'expense' THEN t.amount END), 0) AS total_expense,
	COALESCE(SUM(CASE WHEN t.type = 'income' THEN t.amount END), 0) AS total_income
FROM "transaction" t
JOIN category c ON t.category_id = c.id
WHERE t.user_id = 1
	AND strftime('%Y-%m', t.date) = strftime('%Y-%m', 'now')
GROUP BY c.id, c.name
ORDER BY total_expense DESC;

-- 4) Monthly income / expense (last 6 months)
SELECT
	strftime('%Y-%m', t.date) AS month,
	SUM(CASE WHEN t.type = 'expense' THEN t.amount ELSE 0 END) AS total_expense,
	SUM(CASE WHEN t.type = 'income' THEN t.amount ELSE 0 END) AS total_income
FROM "transaction" t
WHERE t.user_id = 1
	AND date(t.date) >= date('now', '-6 months')
GROUP BY month
ORDER BY month DESC;

-- 5) Budgets vs spent (current month) for user 1
SELECT
	b.id AS budget_id,
	c.name AS category_name,
	b.amount AS budget_amount,
	COALESCE(SUM(CASE WHEN t.type = 'expense' AND strftime('%Y-%m', t.date) = strftime('%Y-%m', 'now') THEN t.amount END), 0) AS spent_this_month
FROM budget b
JOIN category c ON b.category_id = c.id
LEFT JOIN "transaction" t ON t.category_id = b.category_id AND t.user_id = b.user_id
WHERE b.user_id = 1
	AND b.period = 'monthly'
GROUP BY b.id, c.name, b.amount
ORDER BY spent_this_month DESC;

-- 6) Lookup a single transaction (example id = 123)
SELECT *
FROM "transaction"
WHERE id = 123
	AND user_id = 1;

