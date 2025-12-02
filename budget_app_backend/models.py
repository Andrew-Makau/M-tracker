from database import db
from datetime import date


# Ownership mixin for owned models
class OwnableMixin:
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False, index=True)

    @classmethod
    def for_user(cls, user_id):
        return cls.query.filter_by(user_id=user_id) # type: ignore


# User model
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(128), nullable=False)
    name = db.Column(db.String(50))  # ✅ Add this if you want to store names
    # user-specific settings stored as JSON (nullable for older rows)
    settings = db.Column(db.JSON, nullable=True)

    def __repr__(self):
        return f"<User {self.email}>"


# Category model (with parent-child relationship). Categories are now per-user.
class Category(db.Model, OwnableMixin):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    parent_id = db.Column(db.Integer, db.ForeignKey('category.id'), nullable=True)
    children = db.relationship('Category', backref=db.backref('parent', remote_side=[id]))

    def __repr__(self):
        return f"<Category {self.name}>"


# Transaction model
class Transaction(db.Model, OwnableMixin):
    id = db.Column(db.Integer, primary_key=True)
    # user_id provided by OwnableMixin
    amount = db.Column(db.Float, nullable=False)
    type = db.Column(db.String(10), nullable=False)  # "income" or "expense"
    category_id = db.Column(db.Integer, db.ForeignKey('category.id'))
    date = db.Column(db.Date, default=date.today)
    note = db.Column(db.String(200))

    # Relationships
    user = db.relationship('User', backref='transactions')
    category = db.relationship('Category', backref='transactions')

    def __repr__(self):
        return f"<Transaction {self.type} {self.amount}>"


# Budget model - per-user budgets tied to a category
class Budget(db.Model, OwnableMixin):
    id = db.Column(db.Integer, primary_key=True)
    category_id = db.Column(db.Integer, db.ForeignKey('category.id'), nullable=False)
    amount = db.Column(db.Float, nullable=False)
    period = db.Column(db.String(20), nullable=False, default='monthly')

    category = db.relationship('Category', backref='budgets')

    def __repr__(self):
        return f"<Budget {self.id} category={self.category_id} amount={self.amount} period={self.period}>"
