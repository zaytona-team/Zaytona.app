"""Repository for Recipe and RecipeIngredient operations."""
from app.extensions import db
from app.models.recipe import Recipe
from app.models.recipe_ingredient import RecipeIngredient

class RecipeRepository:
    def create_recipe(self, **kwargs) -> Recipe:
        recipe = Recipe(**kwargs)
        db.session.add(recipe)
        db.session.commit()
        return recipe

    def add_ingredient(self, **kwargs) -> RecipeIngredient:
        ing = RecipeIngredient(**kwargs)
        db.session.add(ing)
        return ing # Commit will be done after loop

    def get_by_id(self, recipe_id: str) -> Recipe | None:
        return db.session.get(Recipe, recipe_id)

    def list_by_group(self, group_id: str) -> list[Recipe]:
        return db.session.query(Recipe).filter(Recipe.group_id == group_id).all()

    def get_ingredients(self, recipe_id: str) -> list[RecipeIngredient]:
        return db.session.query(RecipeIngredient).filter(RecipeIngredient.recipe_id == recipe_id).all()

    def update(self, recipe_id: str, **fields) -> Recipe | None:
        recipe = self.get_by_id(recipe_id)
        if not recipe: return None
        for key, value in fields.items():
            if hasattr(recipe, key) and value is not None:
                setattr(recipe, key, value)
        db.session.commit()
        return recipe

    def delete(self, recipe_id: str) -> bool:
        recipe = self.get_by_id(recipe_id)
        if not recipe: return False
        # Cascade delete or manual delete of ingredients
        db.session.query(RecipeIngredient).filter(RecipeIngredient.recipe_id == recipe_id).delete()
        db.session.delete(recipe)
        db.session.commit()
        return True
