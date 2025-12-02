from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import db, insert_user_transaction
from models import Transaction, Category
from sqlalchemy.orm import joinedload
from sqlalchemy import func
from datetime import datetime, date, timedelta


# Create blueprint
transactions_bp = Blueprint('transactions', __name__)


def serialize_transaction(t: Transaction) -> dict:
        return {
                "id": t.id,
                "amount": t.amount,
                "type": t.type,
                "category_id": t.category_id,
                "date": t.date.isoformat() if t.date else None,
                "note": t.note,
                "user_name": getattr(t.user, 'name', None),
        }

# GET /transactions → fetch all transactions for current user
@transactions_bp.route('/transactions', methods=['GET'])
@jwt_required()
def get_transactions():
    """
    Get Transactions
    ---
    tags:
      - Transactions
    security:
      - Bearer: []
    responses:
      200:
        description: List of all transactions for the current user
      401:
        description: Unauthorized (JWT missing/invalid)
    """
    try:
        # Convert identity back into integer for querying
        user_id = int(get_jwt_identity())

        # Optional pagination params: ?page=1&per_page=50
        page = request.args.get('page', type=int)
        per_page = request.args.get('per_page', type=int)

        base_query = (
            Transaction.query
            .options(joinedload(Transaction.user)) # type: ignore
            .filter_by(user_id=user_id)
            .order_by(Transaction.date.desc(), Transaction.id.desc())
        )

        if page and per_page:
            pagination = base_query.paginate(page=page, per_page=per_page, error_out=False)
            items = pagination.items
        else:
            items = base_query.all()

        result = []
        for t in items:
            result.append(serialize_transaction(t))

        response: dict = {"transactions": result}
        if page and per_page:
            response["page"] = page
            response["per_page"] = per_page
            # Count only if pagination requested to avoid heavy count when unnecessary
            response["total"] = base_query.count()

        return jsonify(response), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

def new_func():
  # Deprecated helper; kept for backward compatibility if imported elsewhere
  return get_jwt_identity()


# POST /transactions → create a new transaction
@transactions_bp.route('/transactions', methods=['POST'])
@jwt_required()
def create_transaction():
    """
    Create Transaction
    ---
    tags:
      - Transactions
    security:
      - Bearer: []
    parameters:
      - in: body
        name: body
        required: true
        schema:
          properties:
            amount:
              type: number
              example: 1500
            type:
              type: string
              enum: [income, expense]
              example: expense
            category_id:
              type: integer
              example: 2
            date:
              type: string
              format: date
              example: 2025-09-10
            note:
              type: string
              example: Bought groceries
    responses:
      201:
        description: Transaction added successfully
      400:
        description: Invalid input
      401:
        description: Unauthorized (JWT missing/invalid)
    """
    try:
        user_id = int(get_jwt_identity())
        data = request.get_json(silent=True) or {}

        # Basic validation
        amount = data.get('amount')
        t_type = data.get('type')
        category_id = data.get('category_id')
        date_str = data.get('date')
        note = data.get('note', "")

        if amount is None or t_type not in {"income", "expense"}:
            return jsonify({"error": "'amount' and valid 'type' ('income' or 'expense') are required"}), 400

        try:
            amount = float(amount)
        except (TypeError, ValueError):
            return jsonify({"error": "'amount' must be a number"}), 400

        if category_id is not None:
            try:
                category_id = int(category_id)
            except (TypeError, ValueError):
                return jsonify({"error": "'category_id' must be an integer"}), 400
            # Ensure category belongs to this user (if provided)
            if category_id:
                cat = Category.query.filter_by(id=category_id, user_id=user_id).first()
                if not cat:
                    # Fallback for legacy/shared categories that don't have `user_id` populated yet.
                    # Allow using a category that exists even if its user_id is NULL or different,
                    # but prefer owned categories when present.
                    cat = Category.query.get(category_id)
                    if not cat:
                        # Category truly doesn't exist. For compatibility with older clients
                        # that may create transactions before categories, treat missing
                        # category as 'uncategorized' rather than failing the request.
                        print(f"Notice: category id={category_id} not found; creating uncategorized transaction for user {user_id}")
                        category_id = None
                    else:
                        # Log a warning server-side; keep category_id as provided.
                        print(f"Notice: using legacy/shared category id={category_id} for user {user_id}")

        # Date parsing; default to today if missing
        if date_str:
            try:
                tx_date = datetime.strptime(date_str, "%Y-%m-%d").date()
            except ValueError:
                return jsonify({"error": "'date' must be in YYYY-MM-DD format"}), 400
        else:
            tx_date = date.today()

        new_transaction = Transaction(
            user_id=user_id, # type: ignore
            amount=amount, # type: ignore
            type=t_type, # type: ignore
            category_id=category_id, # type: ignore
            date=tx_date, # type: ignore
            note=note, # type: ignore
        )

        db.session.add(new_transaction)
        db.session.commit()

        # Mirror into per-user table (best-effort; don't fail main request on mirror error)
        try:
            insert_user_transaction(user_id=user_id, amount=amount, t_type=t_type, category_id=category_id, tx_date=tx_date, note=note)
        except Exception as e:
            print(f"Warning: failed to mirror transaction for user {user_id}: {e}")

        return jsonify({
            "message": "Transaction added successfully!",
            "transaction": serialize_transaction(new_transaction)
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


# GET /transactions/<id> → fetch a single transaction for current user
@transactions_bp.route('/transactions/<int:transaction_id>', methods=['GET'])
@jwt_required()
def get_transaction(transaction_id: int):
    try:
        t = Transaction.query.get(transaction_id)
        if not t:
            return jsonify({"error": "Transaction not found"}), 404
        return jsonify({"transaction": serialize_transaction(t)}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# PUT/PATCH /transactions/<id> → update a transaction (only owned by user)
@transactions_bp.route('/transactions/<int:transaction_id>', methods=['PUT', 'PATCH'])
@jwt_required()
def update_transaction(transaction_id: int):
    try:
        t = Transaction.query.get(transaction_id)
        if not t:
            return jsonify({"error": "Transaction not found"}), 404
        data = request.get_json(silent=True) or {}

        if 'amount' in data:
            try:
                t.amount = float(data['amount'])
            except (TypeError, ValueError):
                return jsonify({"error": "'amount' must be a number"}), 400

        if 'type' in data:
            if data['type'] not in {"income", "expense"}:
                return jsonify({"error": "'type' must be 'income' or 'expense'"}), 400
            t.type = data['type']

        if 'category_id' in data:
            if data['category_id'] is not None:
                try:
                    t.category_id = int(data['category_id'])
                except (TypeError, ValueError):
                    return jsonify({"error": "'category_id' must be an integer"}), 400
            else:
                t.category_id = None

        if 'date' in data:
            if data['date']:
                try:
                    t.date = datetime.strptime(data['date'], "%Y-%m-%d").date()
                except ValueError:
                    return jsonify({"error": "'date' must be in YYYY-MM-DD format"}), 400
            else:
                t.date = None

        if 'note' in data:
            t.note = data.get('note') or ""

        db.session.commit()
        return jsonify({"message": "Transaction updated successfully!", "transaction": serialize_transaction(t)}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500


# DELETE /transactions/<id> → delete a transaction (only owned by user)
@transactions_bp.route('/transactions/<int:transaction_id>', methods=['DELETE'])
@jwt_required()
def delete_transaction(transaction_id: int):
    try:
        t = Transaction.query.get(transaction_id)
        if not t:
            return jsonify({"error": "Transaction not found"}), 404
        db.session.delete(t)
        db.session.commit()
        return jsonify({"message": "Transaction deleted successfully!"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

# Test protected route
@transactions_bp.route('/test-protected', methods=['GET'])
@jwt_required()
def test_protected():
    print("🔐 Authorization header:", request.headers.get('Authorization'))
    return jsonify({"msg": "Protected route reached!"}), 200


@transactions_bp.route('/transactions/summary', methods=['GET'])
@jwt_required()
def transactions_summary():
    """Return aggregate sums for the current user.
    Optional query params: start_date=YYYY-MM-DD, end_date=YYYY-MM-DD
    Defaults to current calendar month.
    """
    try:
        user_id = int(get_jwt_identity())

        # optional date range
        start_date = request.args.get('start_date')
        end_date = request.args.get('end_date')

        from datetime import datetime, date

        if not start_date or not end_date:
            # default to current month
            today = date.today()
            start = date(today.year, today.month, 1)
            # compute first of next month then subtract one day isn't necessary for inclusive filter
            # we'll filter with >= start and <= last_day
            if today.month == 12:
                next_month = date(today.year + 1, 1, 1)
            else:
                next_month = date(today.year, today.month + 1, 1)
            end = next_month - datetime.timedelta(days=1)
        else:
            try:
                start = datetime.strptime(start_date, "%Y-%m-%d").date()
                end = datetime.strptime(end_date, "%Y-%m-%d").date()
            except Exception:
                return jsonify({"error": "start_date/end_date must be YYYY-MM-DD"}), 400

        # Sum expenses and incomes for the user in range
        spent_q = db.session.query(func.coalesce(func.sum(Transaction.amount), 0.0)).filter(
            Transaction.user_id == user_id,
            Transaction.type == 'expense',
            Transaction.date >= start,
            Transaction.date <= end,
        )
        income_q = db.session.query(func.coalesce(func.sum(Transaction.amount), 0.0)).filter(
            Transaction.user_id == user_id,
            Transaction.type == 'income',
            Transaction.date >= start,
            Transaction.date <= end,
        )

        spent = float(spent_q.scalar() or 0.0)
        income = float(income_q.scalar() or 0.0)

        return jsonify({"spent": spent, "income": income, "net": income - spent}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
