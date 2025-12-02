from app import app
from database import db
from models import Category, User


def seed_categories(system_user_email: str = 'system@local'):
    """Seed a set of default categories owned by a system user.

    The function ensures a system user exists and assigns all seeded
    categories to that user's `user_id` so they conform to the current
    `OwnableMixin` constraints.
    """

    categories = {
        "Foods & Drinks": [
            "Fast Food",
            "Restaurant, fast-food",
            "Groceries"
        ],
        "Shopping": [
            "Drug-store, chemist",
            "Free time",
            "Stationery, tools",
            "Gifts, joy",
            "Electronics, accessories",
            "Pets, animals",
            "Home, garden",
            "Toilertries",
            "Kitchen",
            "Kids",
            "Health and beauty",
            "Jewels, accessories",
            "Men's",
            "Fragrances",
            "Footwear",
            "Clothes"
        ],
        "Housing": [
            "Energy and Utilities"
        ],
        "Transport": [],
        "Vehicle": [],
        "Life & Entertainment": [
            "TV, Streaming",
            "Activeness sport and fitness",
            "Holiday and trips"
        ],
        "Communication and PC": [
            "Internet",
            "Airtime",
            "Bundles"
        ],
        "Financial Expenses": [
            "Charges & fees",
            "Loans & interests"
        ],
        "Investments": [
            "Trade",
            "MMF",
            "Savings"
        ],
        "Income": [],
        "Others": []
    }
    with app.app_context():
        # Ensure a system user exists to own seeded categories
        system_user = User.query.filter_by(email=system_user_email).first()
        if not system_user:
            system_user = User(email=system_user_email, password_hash='', name='System')
            db.session.add(system_user)
            db.session.commit()

        for parent_name, subcats in categories.items():
            # Create parent category with system user ownership
            parent = Category(name=parent_name, user_id=system_user.id)
            db.session.add(parent)
            db.session.commit()

            # Create subcategories linked to parent and assigned to system user
            for sub in subcats:
                child = Category(name=sub, parent_id=parent.id, user_id=system_user.id)
                db.session.add(child)

        db.session.commit()
        print("Categories seeded successfully!")


if __name__ == "__main__":
    seed_categories()
