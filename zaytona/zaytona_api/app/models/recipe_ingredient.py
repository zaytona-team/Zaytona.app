"""RECIPE_INGREDIENT model — ingredients list for a specific recipe."""
from sqlalchemy.orm import validates

from app.extensions import db
from app.models.base_model import UUIDType, gen_uuid
from app.models.list_item import ALLOWED_UNITS # Reuse the same units
from app.utils.validators import require_allowed_unit, require_positive_quantity, require_text

class RecipeIngredient(db.Model):
    __tablename__ = "recipe_ingredients"
    __table_args__ = (
        db.CheckConstraint("quantity > 0", name="ck_recipe_ingredients_quantity_positive"),
    )

    ingredient_id = db.Column(UUIDType, primary_key=True, default=gen_uuid)
    recipe_id = db.Column(UUIDType, db.ForeignKey("recipes.recipe_id"), nullable=False, index=True)
    
    # Optional link to canonical item catalog
    item_id = db.Column(UUIDType, db.ForeignKey("items.item_id"), nullable=True)
    
    name = db.Column(db.String(120), nullable=False)
    quantity = db.Column(db.Float, nullable=False, default=1.0)
    unit = db.Column(db.String(20), nullable=False, default="pcs")

    @validates("name")
    def _validate_name(self, _key, value):
        return require_text(value, "name", max_length=120)

    @validates("quantity")
    def _validate_quantity(self, _key, value):
        return require_positive_quantity(value)

    @validates("unit")
    def _validate_unit(self, _key, value):
        return require_allowed_unit(value, ALLOWED_UNITS)

    def to_dict(self) -> dict:
        return {
            "ingredient_id": self.ingredient_id,
            "recipe_id": self.recipe_id,
            "item_id": self.item_id,
            "name": self.name,
            "quantity": self.quantity,
            "unit": self.unit,
        }
