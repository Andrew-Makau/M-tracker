from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import db
from models import Budget, Transaction
from sqlalchemy import func
from datetime import datetime, date

budgets_bp = Blueprint('budgets', __name__)


def serialize_budget(b: Budget) -> dict:
    return {
        'id': b.id,
        'category_id': b.category_id,
        'amount': b.amount,
        'period': b.period,
    }


@budgets_bp.route('/budgets', methods=['GET'])
@jwt_required()
def list_budgets():
    user_id = int(get_jwt_identity())
    bgs = Budget.query.filter_by(user_id=user_id).all()
    return jsonify({'budgets': [serialize_budget(b) for b in bgs]}), 200


@budgets_bp.route('/budgets', methods=['POST'])
@jwt_required()
def create_budget():
    user_id = int(get_jwt_identity())
    data = request.get_json(silent=True) or {}
    category_id = data.get('category_id')
    amount = data.get('amount')
    period = data.get('period', 'monthly')

    if not category_id or amount is None:
        return jsonify({'error': "'category_id' and 'amount' are required"}), 400

    try:
        amount = float(amount)
        category_id = int(category_id)
    except Exception:
        return jsonify({'error': 'Invalid category_id or amount'}), 400
    # Validate period
    allowed_periods = {'daily', 'weekly', 'monthly', 'yearly'}
    if period not in allowed_periods:
        return jsonify({'error': f"'period' must be one of {sorted(list(allowed_periods))}"}), 400

    b = Budget(user_id=user_id, category_id=category_id, amount=amount, period=period) # type: ignore
    db.session.add(b)
    db.session.commit()
    return jsonify({'message': 'Budget created', 'budget': serialize_budget(b)}), 201


@budgets_bp.route('/budgets/<int:budget_id>', methods=['GET'])
@jwt_required()
def get_budget(budget_id: int):
    user_id = int(get_jwt_identity())
    b = Budget.query.filter_by(id=budget_id, user_id=user_id).first()
    if not b:
        return jsonify({'error': 'Budget not found'}), 404
    return jsonify({'budget': serialize_budget(b)}), 200


@budgets_bp.route('/budgets/<int:budget_id>', methods=['PUT', 'PATCH'])
@jwt_required()
def update_budget(budget_id: int):
    user_id = int(get_jwt_identity())
    b = Budget.query.filter_by(id=budget_id, user_id=user_id).first()
    if not b:
        return jsonify({'error': 'Budget not found'}), 404
    data = request.get_json(silent=True) or {}
    if 'amount' in data:
        try:
            b.amount = float(data['amount'])
        except Exception:
            return jsonify({'error': "'amount' must be a number"}), 400
    if 'period' in data:
        if data['period'] not in {'daily', 'weekly', 'monthly', 'yearly'}:
            return jsonify({'error': "'period' must be one of ['daily','weekly','monthly','yearly']"}), 400
        b.period = data['period']
    db.session.commit()
    return jsonify({'message': 'Budget updated', 'budget': serialize_budget(b)}), 200


@budgets_bp.route('/budgets/<int:budget_id>', methods=['DELETE'])
@jwt_required()
def delete_budget(budget_id: int):
    user_id = int(get_jwt_identity())
    b = Budget.query.filter_by(id=budget_id, user_id=user_id).first()
    if not b:
        return jsonify({'error': 'Budget not found'}), 404
    db.session.delete(b)
    db.session.commit()
    return jsonify({'message': 'Budget deleted'}), 200
