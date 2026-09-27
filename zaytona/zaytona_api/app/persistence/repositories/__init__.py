"""Repository registry. Only UserRepository is active (US-01/02/36)."""
from app.persistence.repositories.user_repository import UserRepository  # noqa: F401
from app.persistence.repositories.category_repository import CategoryRepository  # noqa: F401
from app.persistence.repositories.list_repository import ListRepository  # noqa: F401
from app.persistence.repositories.item_repository import ItemRepository # noqa: F401
from app.persistence.repositories.recipe_repository import RecipeRepository # noqa: F401