"""RECIPE model.

Fleshed out early (ahead of the Recipes story) only so that Group
Management's US-12 ("admin removes a recipe from the group") has a real
table to delete from. Creating/editing recipes belongs to the Recipes
story (US-33+); this model intentionally stays minimal until then.
"""
from sqlalchemy.orm import validates

from app.extensions import db
from app.models.base_model import TimestampMixin, UUIDType, gen_uuid
from app.utils.validators import require_text

class Recipe(db.Model, TimestampMixin):
    __tablename__ = "recipes"

    recipe_id = db.Column(UUIDType, primary_key=True, default=gen_uuid)
    group_id = db.Column(UUIDType, db.ForeignKey("groups.group_id"), nullable=False, index=True)
    created_by = db.Column(UUIDType, db.ForeignKey("users.user_id"), nullable=False) # Recipe Owner

    # Set when this row is a group's own customized copy of a recipe-book
    # recipe — "add to a group" forks a copy here rather than mutating
    # the original, so editing the group's copy never touches the recipe
    # it was imported from.
    source_recipe_id = db.Column(UUIDType, db.ForeignKey("recipes.recipe_id"), nullable=True, index=True)

    name = db.Column(db.String(120), nullable=False)
    image_url = db.Column(db.String(512), nullable=True)
    instructions = db.Column(db.Text, nullable=True)

    @validates("name")
    def _validate_name(self, _key, value):
        return require_text(value, "name", max_length=120)

    def to_dict(self) -> dict:
        return {
            "recipe_id": self.recipe_id,
            "group_id": self.group_id,
            "created_by": self.created_by,
            "source_recipe_id": self.source_recipe_id,
            "name": self.name,
            "image_url": self.image_url,
            "instructions": self.instructions,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
