"""LIST_ITEM model — one entry per item added to a shopping list.

Supports:
  * US-16: Manual addition with name, quantity, unit, notes.
  * US-21: Custom image_url for the specific list item.
  * US-22: is_urgent flag.
  * US-26: is_bought flag and bought_by tracker.
"""
from sqlalchemy.orm import validates

from app.extensions import db
from app.models.base_model import TimestampMixin, UUIDType, gen_uuid
from app.utils.validators import (
    require_allowed_unit,
    require_optional_text,
    require_positive_quantity,
    require_text,
)

# Per documentation: Allowed units
ALLOWED_UNITS = ["pcs", "kg", "g", "L", "ml", "pack", "box", "bottle"]

MAX_NOTES_LENGTH = 1000


class ListItem(db.Model, TimestampMixin):
    __tablename__ = "list_items"
    __table_args__ = (db.CheckConstraint("quantity > 0", name="ck_list_items_quantity_positive"),)

    list_item_id = db.Column(UUIDType, primary_key=True, default=gen_uuid)
    
    # Foreign Keys
    list_id = db.Column(UUIDType, db.ForeignKey("shopping_lists.list_id"), nullable=False, index=True)
    item_id = db.Column(UUIDType, db.ForeignKey("items.item_id"), nullable=True, index=True) # Null if custom item
    category_id = db.Column(UUIDType, db.ForeignKey("categories.category_id"), nullable=True, index=True)
    
    # Also covered by the composite ix_list_items_added_by_name_created
    # (added_by, lower(name), created_at desc) that list_distinct_by_user
    # needs — added here too so a fresh dev DB (db.create_all(), no
    # composite functional index) still isn't doing a full table scan
    # on GET /users/me/items while it's small.
    added_by = db.Column(UUIDType, db.ForeignKey("users.user_id"), nullable=False, index=True)
    bought_by = db.Column(UUIDType, db.ForeignKey("users.user_id"), nullable=True)

    # Which trip bought this item, if any — set when a trip closes and
    # claims every bought-but-unclaimed item on the list (see
    # ListFacadeMixin.complete_list). The list itself is reused
    # indefinitely across many trips, so this is what lets a trip's
    # "what did we buy" view (list_list_trips) pick out only its own
    # items instead of every bought item the list has ever had. SET NULL
    # (not CASCADE) so an item is never implicitly mass-deleted by a
    # trip going away — the retention sweep (app/tasks/retention.py)
    # deletes claimed items explicitly, before it deletes the trip.
    trip_id = db.Column(UUIDType, db.ForeignKey("trips.trip_id", ondelete="SET NULL"), nullable=True, index=True)

    # Item details
    name = db.Column(db.String(120), nullable=False)
    brand = db.Column(db.String(80), nullable=True)
    quantity = db.Column(db.Float, nullable=False, default=1.0)
    unit = db.Column(db.String(20), nullable=False, default="pcs")
    notes = db.Column(db.Text, nullable=True)

    # State flags
    is_urgent = db.Column(db.Boolean, default=False, nullable=False)
    is_bought = db.Column(db.Boolean, default=False, nullable=False)

    # US-21: Specific image for this list item
    image_url = db.Column(db.String(512), nullable=True)

    @validates("name")
    def _validate_name(self, _key, value):
        return require_text(value, "name", max_length=120)

    @validates("quantity")
    def _validate_quantity(self, _key, value):
        return require_positive_quantity(value)

    @validates("unit")
    def _validate_unit(self, _key, value):
        return require_allowed_unit(value, ALLOWED_UNITS)

    @validates("notes")
    def _validate_notes(self, _key, value):
        return require_optional_text(value, "notes", max_length=MAX_NOTES_LENGTH)

    def to_dict(self) -> dict:
       data = {
            "list_item_id": str(self.list_item_id),
            "list_id": str(self.list_id),
            "item_id": str(self.item_id) if self.item_id else None,
            "category_id": str(self.category_id) if self.category_id else None,
            "name": self.name,
            "brand": self.brand,
            "quantity": self.quantity,
            "unit": self.unit,
            "notes": self.notes,
            "is_urgent": self.is_urgent,
            "is_bought": self.is_bought,
            "added_by": str(self.added_by),
            "bought_by": str(self.bought_by) if self.bought_by else None,
            "trip_id": str(self.trip_id) if self.trip_id else None,
            "image_url": self.image_url,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
       # Add catalog data if item_id exists
       if self.item_id:
        try:
            from app.extensions import db
            from app.models.item import Item
        
            catalog_item = db.session.get(Item, self.item_id)
            if catalog_item:
                data["catalog"] = {
                        "item_id": str(catalog_item.item_id),
                        "name": catalog_item.name,
                        "brand": catalog_item.brand,
                        "image_url": catalog_item.image_url,
                        "barcode": catalog_item.barcode,
                        "default_category_id": str(catalog_item.default_category_id) if catalog_item.default_category_id else None,
                }
            else:
                    data["catalog"] = None
        except Exception:
                data["catalog"] = None
    
       return data
