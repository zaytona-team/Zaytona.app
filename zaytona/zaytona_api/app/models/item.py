"""ITEM model — canonical catalog entry shared by lists & recipes.

This table stores known grocery items to enable:
  * Fast re-adding from history (US-17)
  * Barcode lookup (US-19)
  * Shared catalog across the group
"""
from sqlalchemy.orm import validates

from app.extensions import db
from app.models.base_model import TimestampMixin, UUIDType, gen_uuid
from app.utils.validators import require_text


class Item(db.Model, TimestampMixin):
    __tablename__ = "items"

    item_id = db.Column(UUIDType, primary_key=True, default=gen_uuid)
    
    # Optional link to a default category
    default_category_id = db.Column(
        UUIDType, db.ForeignKey("categories.category_id"), nullable=True, index=True
    )

    name = db.Column(db.String(120), nullable=False, index=True)
    brand = db.Column(db.String(80), nullable=True)
    barcode = db.Column(db.String(50), nullable=True, unique=True, index=True)
    image_url = db.Column(db.String(512), nullable=True)

    @validates("name")
    def _validate_name(self, _key, value):
        return require_text(value, "name", max_length=120)

    def to_dict(self) -> dict:
        return {
            "item_id": self.item_id,
            "default_category_id": self.default_category_id,
            "name": self.name,
            "brand": self.brand,
            "barcode": self.barcode,
            "image_url": self.image_url,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
