from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from database import db
from models import User
from database import create_user_tables
from flask_jwt_extended import jwt_required, get_jwt_identity
import json

# Create blueprint
auth_bp = Blueprint('auth', __name__)

# Signup endpoint
@auth_bp.route('/signup', methods=['POST'])
def signup():
    """
    User Signup
    ---
    tags:
      - Authentication
    parameters:
      - in: body
        name: body
        required: true
        schema:
          properties:
            email:
              type: string
            password:
              type: string
    responses:
      200:
        description: User successfully created
      400:
        description: User already exists
    """
    try:
        data = request.get_json() or {}
        email = (data.get('email') or '').strip().lower()
        password = data.get('password')
        # Accept both 'name' and legacy 'names' for compatibility with older frontends
        name = (data.get('name') or data.get('names'))  # Optional

        if not email or not password:
            return jsonify({"error": "'email' and 'password' are required"}), 400

        if User.query.filter_by(email=email).first():
            return jsonify({"error": "Email already exists"}), 400

        # Use provided name, or fallback to the part before '@'
        if not name:
            name = (email.split('@')[0] or 'User').title()
        else:
            name = str(name).strip()

        new_user = User(
            email=email, # type: ignore
            password_hash=generate_password_hash(password), # type: ignore
            name=name # type: ignore
        )
        db.session.add(new_user)
        db.session.commit()

        # Create per-user mirrored tables (low-risk mirror approach)
        try:
          create_user_tables(new_user.id)
        except Exception as e:
          # Non-fatal: warn and continue
          print(f"Warning: failed to create per-user tables for user {new_user.id}: {e}")

        return jsonify({
            "message": "User created successfully",
            "user": {"id": new_user.id, "email": new_user.email, "name": new_user.name}
        }), 201
    except Exception as e:
        print("❌ Signup Error:", str(e))   # shows in terminal
        return jsonify({"error": "Internal Server Error", "details": str(e)}), 500
  
# LOGIN Endpoint
@auth_bp.route('/login', methods=['POST'])
def login():
    """
    User Login
    ---
    tags:
      - Authentication
    parameters:
      - in: body
        name: body
        required: true
        schema:
          properties:
            email:
              type: string
              example: test@example.com
            password: 
              type: string
              example: Pass@123
    responses:
      200:
        description: Returns a JWT token if login successful
      401:
        description: Invalid credentials
    """
    data = request.get_json(silent=True) or {}
    email = (data.get("email") or "").strip().lower()
    password = data.get("password")

    if not email or not password:
        return jsonify({"error": "'email' and 'password' are required"}), 400

    # Fetch user from DB
    user = User.query.filter_by(email=email).first()

    if not user or not check_password_hash(user.password_hash, password):
        return jsonify({"error": "Invalid credentials"}), 401

    # Generate JWT
    access_token = create_access_token(identity=str(user.id))  
    return jsonify({
        "message": "Login successful",
        "access_token": access_token,
        "user": {
            "id": user.id,
            "email": user.email,
            "name": user.name
        }
    }), 200


# Simple profile endpoint for debugging/logged-in user info
@auth_bp.route('/me', methods=['GET'])
@jwt_required()
def me():
    try:
        user_id = int(get_jwt_identity())
        user = User.query.get(user_id)
        if not user:
            return jsonify({"error": "User not found"}), 404
        return jsonify({
            "user": {"id": user.id, "email": user.email, "name": user.name}
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# List users (for Swagger UI/testing)
@auth_bp.route('/users', methods=['GET'])
@jwt_required()
def list_users():
    """
    List Users
    ---
    tags:
      - Authentication
    security:
      - Bearer: []
    responses:
      200:
        description: List of users
      401:
        description: Unauthorized
    """
    try:
        users = User.query.order_by(User.id.asc()).all()
        out = []
        for u in users:
            out.append({"id": u.id, "email": u.email, "name": u.name})
        return jsonify({"users": out}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


    # Get current user's settings
    @auth_bp.route('/me/settings', methods=['GET'])
    @jwt_required()
    def get_settings():
      try:
        user_id = int(get_jwt_identity())
        user = User.query.get(user_id)
        if not user:
          return jsonify({"error": "User not found"}), 404
        return jsonify({"settings": user.settings or {}}), 200
      except Exception as e:
        return jsonify({"error": str(e)}), 500


    @auth_bp.route('/me/settings', methods=['PUT'])
    @jwt_required()
    def put_settings():
      try:
        user_id = int(get_jwt_identity())
        user = User.query.get(user_id)
        if not user:
          return jsonify({"error": "User not found"}), 404
        data = request.get_json(silent=True) or {}
        # Only allow a settings dict
        if not isinstance(data, dict):
          return jsonify({"error": "Settings must be a JSON object"}), 400
        user.settings = (user.settings or {})
        # Merge provided keys
        user.settings.update(data)
        db.session.commit()
        return jsonify({"message": "Settings updated", "settings": user.settings}), 200
      except Exception as e:
        return jsonify({"error": str(e)}), 500

