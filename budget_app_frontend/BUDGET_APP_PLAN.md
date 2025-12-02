
# 📋 Budget App 7-Day Project Plan (Flutter + Flask)

## **Day 1 – Setup & Architecture**
- Define requirements:  
  - ✅ Features: signup/login, add expenses/income, categorize, monthly summary, export (CSV/PDF).  
  - ❌ Skip for MVP: bank API, AI recommendations.  
- Tech setup:  
  - Backend: Flask (or FastAPI).  
  - Database: SQLite (upgrade later to PostgreSQL).  
  - Frontend: Flutter (with Provider/Riverpod).  
- DevOps: GitHub repo, CI/CD (GitHub Actions + deploy to Render/Heroku).  

---

## **Day 2 – Backend MVP**
- User authentication (JWT-based).  
- Models: User, Transaction, Category.  
- REST API endpoints:  
  - `POST /auth/signup`  
  - `POST /auth/login`  
  - `GET /transactions`  
  - `POST /transactions`  
- Tools: Flask-JWT-Extended, SQLAlchemy, Swagger/OpenAPI docs.  

---

## **Day 3 – Flutter UI Basics**
- Pages: Login, Signup, Dashboard, Add Transaction.  
- Tools: dio (API calls), flutter_secure_storage (JWT), Riverpod/Provider.  
- Build mock UI with static data first.  

---

## **Day 4 – Connect Backend & Frontend**
- Integrate Flutter with Flask API.  
- Test signup/login and persist JWT.  
- Display user transactions in Dashboard.  
- Add new transaction → POST to backend.  
- Debug CORS (Flask-CORS).  

---

## **Day 5 – Analytics & Extras**
- Backend: monthly summary endpoint (group by category/date).  
- Frontend:  
  - Use charts_flutter or Syncfusion charts for expenses.  
  - Add filter by month/year.  

---

## **Day 6 – Polish & Export**
- Backend: add export endpoint (`/export/csv`, optional PDF).  
- Frontend:  
  - Improve UI (icons, colors).  
  - Input validation & error handling.  

---

## **Day 7 – Testing & Deployment**
- Write tests (pytest for Flask, flutter_test for Flutter).  
- Deploy Flask to Render/Heroku.  
- Deploy Flutter app (APK or TestFlight).  
- Final demo run with dummy users & transactions.  

---

# 🚀 Tools & Techniques Recommendations
- Backend: Flask (simple), FastAPI (alternative).  
- Database: SQLite (MVP), PostgreSQL (production).  
- Frontend: Flutter with Riverpod + Dio.  
- Design prototyping: **Lovable.dev** (UI mockups), **Bolt.new** (auto-generate logic in TypeScript).  
- Deployment: Render/Railway/Heroku for backend, Play Store/TestFlight for frontend.  

---

## 🔗 Backend Integration Plan (Flutter ↔ Flask)

This plan connects the existing Flutter app to the attached Flask backend incrementally. It includes API contracts, platform URLs, and the exact order to wire features with validation after each step.

### 0) Backend readiness
- Run the backend at http://127.0.0.1:5000 (CORS is already enabled in `app.py`).
- Database: SQLite. Use Flask-Migrate for schema if needed (optional for MVP).

### 1) Platform base URLs (Frontend)
- Web: `http://127.0.0.1:5000`
- Android emulator: `http://10.0.2.2:5000`
- Already implemented in:
  - `lib/services/auth_service.dart`
  - `lib/services/transaction_service.dart`

### 2) API contracts (from Flask)
- POST `/signup`
  - Request: `{ email: string, password: string, name?: string }`
  - Responses: 201 `{ message }` | 400 `{ error }`
- POST `/login`
  - Request: `{ email: string, password: string }`
  - 200: `{ message, access_token, user: { id, email, name } }` | 401 `{ error }`
- GET `/transactions` (JWT required)
  - Header: `Authorization: Bearer <token>`
  - 200: `{ transactions: Array<{ id, amount, type, category_id, date(ISO), note }> }`
- POST `/transactions` (JWT required)
  - Request: `{ amount: number, type: "income"|"expense", category_id: number, date: "YYYY-MM-DD", note?: string }`
  - 201: `{ message: "Transaction added successfully!" }`

### 3) Integration order and validation
1. Login
  - Wire Login screen to `AuthService.login`. On success, token is stored (secure storage + interceptor) and navigate to Dashboard. Show server errors.
2. Signup (optional)
  - Hook Sign Up to `AuthService.signup`; on 201, inform and route to Login.
3. Route protection
  - On app launch, use `AuthService.isLoggedIn()` to route to Dashboard or Login. Add Logout to clear token.
4. Fetch transactions (Dashboard)
  - Use `TransactionService.fetchTransactions()` to replace mock list or behind a toggle. Handle errors and optionally fall back to mock.
5. Add transaction (Add Expense)
  - POST `/transactions` using amount/type/category_id/date(note). Date format `YYYY-MM-DD`. On success, toast + refresh Dashboard list.
6. Categories (short-term)
  - Keep using static categories for selection (IDs) until a `/categories` endpoint is added.
7. Error handling & UX
  - Standardize service error messages to UI. Add loading indicators for login/fetch/post flows.
8. Environment & security
  - Keep `JWT_SECRET_KEY` in env for prod; HTTPS for deployed environments.
9. Tests
  - Backend: use `routes/test_api.py`. Frontend: mock Dio to test services and a widget that renders live transactions.

### 4) Concrete frontend tasks
- [ ] Login screen → call `AuthService.login`, navigate on success, show errors.
- [ ] Dashboard → fetch and render live transactions via `TransactionService.fetchTransactions`.
- [ ] Add Expense → POST `/transactions`; on success, refresh Dashboard.
- [ ] Logout flow → clear token via `AuthService.logout` and return to Login.
- [ ] (Optional) Sign Up → wire to `AuthService.signup`.

### 5) Quick references
- Authorization: `Authorization: Bearer <access_token>`
- POST date format: `YYYY-MM-DD`
- Transaction (backend → frontend): `{ id, amount, type, category_id, date(ISO), note }`

### 6) Known pitfalls
- Localhost mapping: Web uses `127.0.0.1`, Android emulator uses `10.0.2.2`.
- CORS: Enabled in backend (`CORS(app, resources={r"/*": {"origins": "*"}})`).
- JWT: Backend returns `access_token`; `AuthService` already extracts it.
- Dates: Convert to `YYYY-MM-DD` for POST; parse ISO from GET.

