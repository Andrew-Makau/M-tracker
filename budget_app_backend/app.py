from flask import Flask  # type: ignore
import os
from flask_jwt_extended import JWTManager, create_access_token
from flasgger import Swagger
from flask_cors import CORS
from flask_migrate import Migrate   # ✅ for migrations

from database import db   # import db from database.py
from models import User, Category, Transaction  # import your models

# -----------------------------
# App Initialization
# -----------------------------
app = Flask(__name__)

# ✅ Enable CORS (allow frontend access)
CORS(app, resources={r"/*": {"origins": "*"}})

# -----------------------------
# Configurations
# -----------------------------
# Security (JWT)
app.config['JWT_SECRET_KEY'] = '9512'  # ⚠️ TODO: move to environment variable for production
app.config['JWT_IDENTITY_CLAIM'] = 'sub'

# Database (SQLite for development, swap to PostgreSQL/MySQL later)
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///budget.db"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

# -----------------------------
# Extensions
# -----------------------------
db.init_app(app)                 # bind SQLAlchemy
jwt = JWTManager(app)            # setup JWT auth
migrate = Migrate(app, db)       # ✅ enable migrations

# NOTE: Schema management is handled via Flask-Migrate (Alembic).
# Do not rely on runtime `db.create_all()` for schema changes in
# collaborative or production environments. To create/upgrade the
# database schema run the migration commands described in README.md
# (or use the development convenience script `apply_quick_ddl.py`).

# Swagger (API docs)
swagger_template = {
    "swagger": "2.0",
    "info": {
        "title": "Budget App API",
        "description": "API documentation for the Budget App",
        "version": "1.0.0"
    },
    "securityDefinitions": {
        "Bearer": {
            "type": "apiKey",
            "name": "Authorization",
            "in": "header",
            "description": (
                "JWT Authorization header using the Bearer scheme. "
                "Example: 'Bearer {token}'"
            )
        }
    },
    "security": [{"Bearer": []}]
}
swagger = Swagger(app, template=swagger_template)

# -----------------------------
# Blueprints (routes)
# -----------------------------
from routes.auth import auth_bp
from routes.transactions import transactions_bp
from routes.categories import categories_bp
from routes.budgets import budgets_bp

app.register_blueprint(auth_bp)
app.register_blueprint(transactions_bp)
app.register_blueprint(categories_bp)
app.register_blueprint(budgets_bp)

# -----------------------------
# Test Route
# -----------------------------
@app.route('/')
def home():
    return '✅ Budget App Backend is running !!!\nmade by Andru the Multi-Billionaire!'

# -----------------------------
# Main Entry Point
# -----------------------------
if __name__ == '__main__':
    # Faster dev boot: disable reloader to avoid double-start and slow restarts
    debug = os.getenv('FLASK_DEBUG', '1') == '1'
    use_reloader = os.getenv('USE_RELOADER', '0') == '1'
    app.run(debug=debug, use_reloader=use_reloader)
