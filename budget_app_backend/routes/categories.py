from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import db
from models import Category, Transaction


categories_bp = Blueprint('categories', __name__)


def serialize_category(c: Category) -> dict:
    return {
        "id": c.id,
        "name": c.name,
        "parent_id": c.parent_id,
    }


@categories_bp.route('/categories', methods=['GET'])
@jwt_required()
def list_categories():
    user_id = int(get_jwt_identity())
    cats = Category.query.filter_by(user_id=user_id).order_by(Category.name.asc()).all()
    return jsonify({"categories": [serialize_category(c) for c in cats]}), 200


@categories_bp.route('/categories', methods=['POST'])
@jwt_required()
def create_category():
    data = request.get_json(silent=True) or {}
    name = (data.get('name') or '').strip()
    parent_id = data.get('parent_id')

    user_id = int(get_jwt_identity())

    if not name:
        return jsonify({"error": "'name' is required"}), 400

    if parent_id is not None:
        try:
            parent_id = int(parent_id)
        except (TypeError, ValueError):
            return jsonify({"error": "'parent_id' must be an integer"}), 400
        # Validate parent exists and belongs to the same user
        if parent_id:
            parent = Category.query.filter_by(id=parent_id, user_id=user_id).first()
            if not parent:
                return jsonify({"error": "Parent category not found"}), 404

    c = Category(name=name, parent_id=parent_id, user_id=user_id) # type: ignore
    db.session.add(c)
    db.session.commit()
    return jsonify({"message": "Category created", "category": serialize_category(c)}), 201


@categories_bp.route('/categories/<int:category_id>', methods=['GET'])
@jwt_required()
def get_category(category_id: int):
    c = Category.query.get(category_id)
    if not c:
        return jsonify({"error": "Category not found"}), 404
    return jsonify({"category": serialize_category(c)}), 200


@categories_bp.route('/categories/<int:category_id>', methods=['PUT', 'PATCH'])
@jwt_required()
def update_category(category_id: int):
    c = Category.query.get(category_id)
    if not c:
        return jsonify({"error": "Category not found"}), 404
    data = request.get_json(silent=True) or {}
    if 'name' in data:
        name = (data.get('name') or '').strip()
        if not name:
            return jsonify({"error": "'name' cannot be empty"}), 400
        c.name = name

    if 'parent_id' in data:
        parent_id = data.get('parent_id')
        if parent_id is not None:
            try:
                parent_id = int(parent_id)
            except (TypeError, ValueError):
                return jsonify({"error": "'parent_id' must be an integer"}), 400
            if parent_id == c.id:
                return jsonify({"error": "Category cannot be its own parent"}), 400
            if parent_id:
                parent = Category.query.get(parent_id)
                if not parent:
                    return jsonify({"error": "Parent category not found"}), 404
            c.parent_id = parent_id
        else:
            c.parent_id = None

    db.session.commit()
    return jsonify({"message": "Category updated", "category": serialize_category(c)}), 200


@categories_bp.route('/categories/<int:category_id>', methods=['DELETE'])
@jwt_required()
def delete_category(category_id: int):
    c = Category.query.get(category_id)
    if not c:
        return jsonify({"error": "Category not found"}), 404

    # Reassign children to None to avoid FK issues
    for child in Category.query.filter_by(parent_id=c.id).all():
        child.parent_id = None

    # Null out transactions that reference this category
    Transaction.query.filter_by(category_id=c.id).update({Transaction.category_id: None})

    db.session.delete(c)
    db.session.commit()
    return jsonify({"message": "Category deleted"}), 200
