"""Repository for the USER profile-mirror table.

Encapsulates all SQLAlchemy access for users so the facade/service layer
never builds queries inline. Mirrors the HBnB persistence-repository split.
"""
from app.extensions import db
from app.models.user import User


class UserRepository:
    def create(self, *, first_name, last_name, email, phone, phone_verified=False, commit=True) -> User:
        user = User(
            first_name=first_name,
            last_name=last_name,
            email=email,
            phone=phone,
            phone_verified=phone_verified,
        )
        db.session.add(user)
        if commit:
            db.session.commit()
        else:
            db.session.flush()
        return user

    def get_by_id(self, user_id: str) -> User | None:
        return db.session.get(User, user_id)

    def get_by_email(self, email: str) -> User | None:
        return db.session.query(User).filter_by(email=email).first()

    def get_by_phone(self, phone: str) -> User | None:
        return db.session.query(User).filter_by(phone=phone).first()

    def get_by_ids(self, user_ids: list[str]) -> list[User]:
        if not user_ids:
            return []
        return db.session.query(User).filter(User.user_id.in_(user_ids)).all()

    def update_profile(self, user_id: str, **fields) -> User | None:
        user = self.get_by_id(user_id)
        if not user:
            return None
        for key, value in fields.items():
            if hasattr(user, key) and value is not None:
                setattr(user, key, value)
        db.session.commit()
        return user

    def mark_phone_verified(self, *, phone) -> User | None:
        """US-36: flip phone_verified once Authentica confirms the OTP."""
        user = self.get_by_phone(phone)
        if not user:
            return None
        user.phone_verified = True
        db.session.commit()
        return user
