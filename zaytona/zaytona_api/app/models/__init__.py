"""Model registry.

Importing the models here ensures SQLAlchemy is aware of every table
when create_all() / Alembic autogenerate runs.

Active: User (US-01/02/36), Group + GroupMember (US-04..US-10),
ShoppingList + Item + ListItem (US-13..US-26), Recipe + RecipeIngredient
(US-33..US-37), Category (reference data), and History/LIST_ACTION
(activity log, written by the facade on every item create/update/
delete/purchase — see GET /lists/<id>/history).

UserDevice, Trip, and Instruction are ERD tables with real columns but
no repository/facade/API wiring yet — no story has landed for push
notifications, trip-locking, or step-by-step recipe instructions.
"""
from app.models.user import User  # noqa: F401
from app.models.group import Group  # noqa: F401
from app.models.group_member import GroupMember  # noqa: F401
from app.models.shopping_list import ShoppingList  # noqa: F401
from app.models.recipe import Recipe  # noqa: F401
from app.models.category import Category  # noqa: F401
from app.models.item import Item # noqa: F401
from app.models.list_item import ListItem # noqa: F401
from app.models.recipe import Recipe # noqa: F401
from app.models.recipe_ingredient import RecipeIngredient # noqa: F401
from app.models.user_device import UserDevice  # noqa: F401
from app.models.trip import Trip  # noqa: F401
from app.models.instruction import Instruction  # noqa: F401
from app.models.history import History  # noqa: F401
