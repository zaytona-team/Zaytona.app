"""INSTRUCTION model — the ERD's INSTRUCTION entity (ordered recipe step).

Recipe.instructions currently stores the whole method as one free-text
blob. This table is the ERD's normalized alternative (one row per step);
it isn't wired up to create_recipe/update_recipe yet, so the two
representations aren't kept in sync — that reconciliation belongs to
whichever story actually adopts step-by-step instructions.
"""
from sqlalchemy.orm import validates

from app.extensions import db
from app.models.base_model import UUIDType, gen_uuid
from app.utils.validators import require_positive_int, require_text


class Instruction(db.Model):
    __tablename__ = "instructions"

    instruction_id = db.Column(UUIDType, primary_key=True, default=gen_uuid)
    recipe_id = db.Column(UUIDType, db.ForeignKey("recipes.recipe_id"), nullable=False, index=True)

    step_number = db.Column(db.Integer, nullable=False)
    description = db.Column(db.Text, nullable=False)

    @validates("step_number")
    def _validate_step_number(self, _key, value):
        return require_positive_int(value, "step_number", max_value=200)

    @validates("description")
    def _validate_description(self, _key, value):
        return require_text(value, "description", max_length=2000)

    def to_dict(self) -> dict:
        return {
            "instruction_id": self.instruction_id,
            "recipe_id": self.recipe_id,
            "step_number": self.step_number,
            "description": self.description,
        }
