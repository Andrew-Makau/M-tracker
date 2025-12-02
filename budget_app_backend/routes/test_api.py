import requests

BASE_URL = "http://127.0.0.1:5000"  # change to /api if you added url_prefix="/api"

def run_http_flow():
    # -------------------------
    # 1️⃣ Signup (create a user)
    # -------------------------
    signup_payload = {
        "email": "testuser@example.com",
        "password": "password123",
        "name": "Test User"
    }

    signup_res = requests.post(f"{BASE_URL}/signup", json=signup_payload, timeout=5)
    print("🔹 Signup:", signup_res.status_code, safe_json(signup_res))

    # -------------------------
    # 2️⃣ Login (get JWT token)
    # -------------------------
    login_payload = {
        "email": "testuser@example.com",
        "password": "password123"
    }

    login_res = requests.post(f"{BASE_URL}/login", json=login_payload, timeout=5)
    print("🔹 Login:", login_res.status_code, safe_json(login_res))

    if login_res.status_code != 200:
        print("❌ Login failed, stopping test.")
        return

    token = login_res.json().get("access_token")
    headers = {"Authorization": f"Bearer {token}"}

    # -------------------------
    # 3️⃣ Test protected route
    # -------------------------
    protected_res = requests.get(f"{BASE_URL}/test-protected", headers=headers, timeout=5)
    print("🔹 Protected route:", protected_res.status_code, safe_json(protected_res))

    # -------------------------
    # 4️⃣ Add a transaction
    # -------------------------
    transaction_payload = {
        "amount": 1500,
        "type": "expense",
        "category_id": 1,
        "date": "2025-10-18",
        "note": "Bought groceries"
    }

    create_res = requests.post(f"{BASE_URL}/transactions", json=transaction_payload, headers=headers, timeout=5)
    create_json = safe_json(create_res)
    print("🔹 Create transaction:", create_res.status_code, create_json)
    tx_id = (create_json.get("transaction") or {}).get("id") if isinstance(create_json, dict) else None

    if tx_id:
        # 4b) Get one
        one_res = requests.get(f"{BASE_URL}/transactions/{tx_id}", headers=headers, timeout=5)
        print("🔹 Get one:", one_res.status_code, safe_json(one_res))

        # 4c) Update
        upd_res = requests.patch(f"{BASE_URL}/transactions/{tx_id}", json={"amount": 1700.5, "note": "Updated"}, headers=headers, timeout=5)
        print("🔹 Update transaction:", upd_res.status_code, safe_json(upd_res))

    # -------------------------
    # 5️⃣ Get all transactions
    # -------------------------
    get_res = requests.get(f"{BASE_URL}/transactions", headers=headers, timeout=5)
    print("🔹 Get transactions:", get_res.status_code, safe_json(get_res))

    # -------------------------
    # 6️⃣ Categories CRUD
    # -------------------------
    cat_create = requests.post(f"{BASE_URL}/categories", headers=headers, json={"name": "Groceries"}, timeout=5)
    print("🔹 Create category:", cat_create.status_code, safe_json(cat_create))
    cat_id = None
    try:
        cat_id = cat_create.json().get('category', {}).get('id')
    except Exception:
        pass

    if cat_id:
        cat_get = requests.get(f"{BASE_URL}/categories/{cat_id}", headers=headers, timeout=5)
        print("🔹 Get category:", cat_get.status_code, safe_json(cat_get))

        cat_upd = requests.patch(f"{BASE_URL}/categories/{cat_id}", headers=headers, json={"name": "Food"}, timeout=5)
        print("🔹 Update category:", cat_upd.status_code, safe_json(cat_upd))

    cat_list = requests.get(f"{BASE_URL}/categories", headers=headers, timeout=5)
    print("🔹 List categories:", cat_list.status_code, safe_json(cat_list))

    # If categories endpoints are 404 (server not restarted), try in-process categories tests
    if cat_create.status_code == 404 or cat_list.status_code == 404:
        print("⚠️ Categories endpoints not found on server; running categories tests in-process...")
        try:
            run_categories_inprocess(headers)
        except Exception as e:
            print("Categories in-process test failed:", e)

    if cat_id:
        cat_del = requests.delete(f"{BASE_URL}/categories/{cat_id}", headers=headers, timeout=5)
        print("🔹 Delete category:", cat_del.status_code, safe_json(cat_del))
        cat_after = requests.get(f"{BASE_URL}/categories/{cat_id}", headers=headers, timeout=5)
        print("🔹 Get after delete should 404 (category):", cat_after.status_code)

    # -------------------------
    # 8️⃣ Budgets CRUD
    # -------------------------
    budget_id = None
    daily_id = None
    if cat_id:
        bud_payload = {"category_id": cat_id, "amount": 500.0, "period": "monthly"}
        bud_res = requests.post(f"{BASE_URL}/budgets", headers=headers, json=bud_payload, timeout=5)
        print("🔹 Create budget:", bud_res.status_code, safe_json(bud_res))
        try:
            budget_id = bud_res.json().get('budget', {}).get('id')
        except Exception:
            budget_id = None
        # Create a daily budget as well
        daily_payload = {"category_id": cat_id, "amount": 20.0, "period": "daily"}
        daily_res = requests.post(f"{BASE_URL}/budgets", headers=headers, json=daily_payload, timeout=5)
        print("🔹 Create daily budget:", daily_res.status_code, safe_json(daily_res))
        try:
            daily_id = daily_res.json().get('budget', {}).get('id')
        except Exception:
            daily_id = None

    # List budgets
    bud_list = requests.get(f"{BASE_URL}/budgets", headers=headers, timeout=5)
    print("🔹 List budgets:", bud_list.status_code, safe_json(bud_list))

    if budget_id:
        bud_get = requests.get(f"{BASE_URL}/budgets/{budget_id}", headers=headers, timeout=5)
        print("🔹 Get budget:", bud_get.status_code, safe_json(bud_get))

        bud_upd = requests.patch(f"{BASE_URL}/budgets/{budget_id}", headers=headers, json={"amount": 600.0}, timeout=5)
        print("🔹 Update budget:", bud_upd.status_code, safe_json(bud_upd))

        bud_del = requests.delete(f"{BASE_URL}/budgets/{budget_id}", headers=headers, timeout=5)
        print("🔹 Delete budget:", bud_del.status_code, safe_json(bud_del))
        try:
            if daily_id:
                ddel = requests.delete(f"{BASE_URL}/budgets/{daily_id}", headers=headers, timeout=5)
                print("🔹 Delete daily budget:", ddel.status_code, safe_json(ddel))
        except NameError:
            pass

    # -------------------------
    # 6️⃣ Cross-user isolation test
    # -------------------------
    su_payload = {"email": "second@example.com", "password": "password123", "name": "Second User"}
    requests.post(f"{BASE_URL}/signup", json=su_payload, timeout=5)
    login2 = requests.post(f"{BASE_URL}/login", json={"email": "second@example.com", "password": "password123"}, timeout=5)
    token2 = (login2.json() or {}).get("access_token")
    headers2 = {"Authorization": f"Bearer {token2}"}

    if tx_id and token2:
        iso_res = requests.get(f"{BASE_URL}/transactions/{tx_id}", headers=headers2, timeout=5)
        print("🔹 Cross-user get should 404:", iso_res.status_code)

    # -------------------------
    # 7️⃣ Delete original transaction
    # -------------------------
    if tx_id:
        del_res = requests.delete(f"{BASE_URL}/transactions/{tx_id}", headers=headers, timeout=5)
        print("🔹 Delete transaction:", del_res.status_code, safe_json(del_res))
        after_del = requests.get(f"{BASE_URL}/transactions/{tx_id}", headers=headers, timeout=5)
        print("🔹 Get after delete should 404:", after_del.status_code)


def safe_json(res):
    try:
        return res.json()
    except Exception:
        return res.text


def run_inprocess_flow():
    print("⚙️ Server not reachable; running in-process tests via Flask test client...")
    import sys, os
    sys.path.append(os.path.dirname(os.path.dirname(__file__)))
    from app import app
    from database import db
    from sqlalchemy import text
    from models import Transaction

    client = app.test_client()
    with app.app_context():
        db.create_all()

    # Signup
    signup_payload = {"email": "testuser@example.com", "password": "password123", "name": "Test User"}
    res = client.post('/signup', json=signup_payload)
    signup_json = res.get_json() or {}
    user_id = (signup_json.get('user') or {}).get('id')
    print('🔹 Signup (in-proc):', res.status_code, signup_json)

    # Verify per-user tables were created for this user
    if user_id:
        with app.app_context():
            # Look for user_{id}_transactions table in sqlite_master
            tbls = db.session.execute(text("SELECT name FROM sqlite_master WHERE type='table' AND name LIKE :pattern"), {"pattern": f"user_{user_id}_transactions"}).fetchall()
            print('🔹 Per-user transaction table exists:', bool(tbls))
    else:
        print('⚠️ Could not determine signup user_id; skipping per-user table check')

    # Login
    login_payload = {"email": "testuser@example.com", "password": "password123"}
    res = client.post('/login', json=login_payload)
    print('🔹 Login (in-proc):', res.status_code, list((res.get_json() or {}).keys()))
    token = (res.get_json() or {}).get('access_token')
    # If signup didn't return user_id (user existed), pull it from login response
    if not user_id:
        login_json = res.get_json() or {}
        user_id = (login_json.get('user') or {}).get('id')
    if not token:
        print('❌ No token, stopping.')
        return

    headers = {"Authorization": f"Bearer {token}"}

    # Create transaction
    transaction_payload = {
        "amount": 1500,
        "type": "expense",
        "category_id": 1,
        "date": "2025-10-18",
        "note": "Bought groceries",
    }
    res = client.post('/transactions', json=transaction_payload, headers=headers)
    cj = res.get_json() or {}
    print('🔹 Create transaction (in-proc):', res.status_code, cj)
    tx_id = (cj.get('transaction') or {}).get('id')

    # After creating transaction, verify mirrored entry exists in per-user table
    if user_id:
        with app.app_context():
            try:
                cnt_shared = Transaction.query.filter_by(user_id=user_id).count()
            except Exception:
                cnt_shared = None
            try:
                per_table = f'user_{user_id}_transactions'
                per_cnt = db.session.execute(text(f"SELECT COUNT(*) FROM \"{per_table}\""))
                row = per_cnt.fetchone()
                per_count = row[0] if row and len(row) > 0 else 0
            except Exception as e:
                per_count = None
            print(f'🔹 Shared table count for user {user_id}:', cnt_shared)
            print(f'🔹 Per-user mirrored table count for user_{user_id}:', per_count)
    else:
        print('⚠️ Skipping mirror verification; missing user_id')

    # Get transactions
    res = client.get('/transactions', headers=headers)
    j = res.get_json() or {}
    print('🔹 Get transactions (in-proc):', res.status_code, len(j.get('transactions', [])))

    # Categories CRUD (in-proc)
    cat_res = client.post('/categories', headers=headers, json={"name": "Groceries"})
    print('🔹 Create category (in-proc):', cat_res.status_code, cat_res.get_json())
    cat_json = cat_res.get_json() or {}
    cat_id = (cat_json.get('category') or {}).get('id')

    if cat_id:
        res = client.get(f'/categories/{cat_id}', headers=headers)
        print('🔹 Get category (in-proc):', res.status_code, res.get_json())

        res = client.patch(f'/categories/{cat_id}', headers=headers, json={"name": "Food"})
        print('🔹 Update category (in-proc):', res.status_code, res.get_json())

    res = client.get('/categories', headers=headers)
    print('🔹 List categories (in-proc):', res.status_code, res.get_json())

    if cat_id:
        res = client.delete(f'/categories/{cat_id}', headers=headers)
        print('🔹 Delete category (in-proc):', res.status_code, res.get_json())
        res = client.get(f'/categories/{cat_id}', headers=headers)
        print('🔹 Get after delete should 404 (category, in-proc):', res.status_code)

    # Budgets CRUD (in-proc)
    budget_id = None
    if cat_id:
        res = client.post('/budgets', headers=headers, json={"category_id": cat_id, "amount": 250.0, "period": "monthly"})
        print('🔹 Create budget (in-proc):', res.status_code, res.get_json())
        try:
            budget_id = res.get_json().get('budget', {}).get('id')
        except Exception:
            budget_id = None

    res = client.get('/budgets', headers=headers)
    print('🔹 List budgets (in-proc):', res.status_code, res.get_json())

    if budget_id:
        res = client.get(f'/budgets/{budget_id}', headers=headers)
        print('🔹 Get budget (in-proc):', res.status_code, res.get_json())
        res = client.patch(f'/budgets/{budget_id}', headers=headers, json={"amount": 300.0})
        print('🔹 Update budget (in-proc):', res.status_code, res.get_json())
        res = client.delete(f'/budgets/{budget_id}', headers=headers)
        print('🔹 Delete budget (in-proc):', res.status_code, res.get_json())


def run_categories_inprocess(headers):
    import sys, os
    sys.path.append(os.path.dirname(os.path.dirname(__file__)))
    from app import app
    client = app.test_client()
    # Create
    res = client.post('/categories', headers=headers, json={"name": "Groceries"})
    print('🔹 Create category (in-proc direct):', res.status_code, res.get_json())
    j = res.get_json() or {}
    cid = (j.get('category') or {}).get('id')
    # Get
    if cid:
        res = client.get(f'/categories/{cid}', headers=headers)
        print('🔹 Get category (in-proc direct):', res.status_code, res.get_json())
        # Update
        res = client.patch(f'/categories/{cid}', headers=headers, json={"name": "Food"})
        print('🔹 Update category (in-proc direct):', res.status_code, res.get_json())
    # List
    res = client.get('/categories', headers=headers)
    print('🔹 List categories (in-proc direct):', res.status_code, res.get_json())
    # Delete
    if cid:
        res = client.delete(f'/categories/{cid}', headers=headers)
        print('🔹 Delete category (in-proc direct):', res.status_code, res.get_json())
        res = client.get(f'/categories/{cid}', headers=headers)
        print('🔹 Get after delete should 404 (in-proc direct):', res.status_code)



if __name__ == "__main__":
    try:
        # Quick probe to see if server is up
        requests.get(BASE_URL + "/", timeout=1)
        run_http_flow()
    except Exception:
        run_inprocess_flow()
        
