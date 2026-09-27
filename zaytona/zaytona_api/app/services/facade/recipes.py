"""Recipe Management mixin — US-33, US-34, US-35, US-37.

Requires `self.lists` (ListRepository), `self.recipes` (RecipeRepository),
and `self.items` (ItemRepository) from the composed facade, plus
GuardsMixin's `_require_membership`.
"""
from app.extensions import db
from app.models.group_member import GroupMember
from app.services.facade.errors import FacadeError


class RecipeFacadeMixin:
    def _require_recipe_owner_or_admin(self, user_id: str, recipe):
        """US-37: Only the recipe creator or group admin can edit/delete."""
        if recipe.created_by == user_id:
            return  # Owner

        # Fallback: Check if user is group admin using direct query
        member = db.session.query(GroupMember).filter_by(
            group_id=recipe.group_id,
            user_id=user_id,
            role="admin"
        ).first()

        if not member:
            raise FacadeError("Forbidden: Only recipe owner or group admin can modify this", status=403)

    def create_recipe(self, *, user_id, group_id, name, instructions, ingredients,
                       image_url=None, source_recipe_id=None):
        """US-33: Create a recipe with ingredients.

        source_recipe_id (optional): marks this as a group's customized
        copy of another recipe — e.g. "add to a group" forking a
        recipe-book recipe. Editing this copy never touches the source.
        """
        self._require_membership(user_id=user_id, group_id=group_id)

        if not name or not name.strip():
            raise FacadeError("Recipe name is required", status=400)

        if source_recipe_id is not None and not self.recipes.get_by_id(source_recipe_id):
            raise FacadeError("Source recipe not found", status=404)

        recipe = self.recipes.create_recipe(
            group_id=group_id, created_by=user_id, name=name.strip(),
            instructions=instructions, image_url=image_url,
            source_recipe_id=source_recipe_id,
        )

        for ing in ingredients:
            item_id = ing.get("item_id")
            if not item_id:
                # Same match-or-create as add_list_item — every typed
                # ingredient name resolves into the shared Item catalog
                # instead of leaving item_id null.
                catalog_item = self.items.get_or_create_catalog_item(
                    name=ing["name"].strip(), brand=ing.get("brand")
                )
                item_id = catalog_item.item_id
            self.recipes.add_ingredient(
                recipe_id=recipe.recipe_id,
                item_id=item_id,
                name=ing["name"].strip(),
                quantity=float(ing.get("quantity", 1.0)),
                unit=ing.get("unit", "pcs")
            )
        db.session.commit()

        # Return recipe with ingredients
        result = recipe.to_dict()
        result["ingredients"] = [i.to_dict() for i in self.recipes.get_ingredients(recipe.recipe_id)]
        self._emit_group(
            "recipe.created",
            {"group_id": group_id, "actor_user_id": user_id, "recipe": result},
            group_id=group_id,
        )
        return result

    def update_recipe(self, *, user_id, recipe_id, name=None, instructions=None, image_url=None):
        """US-37: Update recipe (Owner/Admin only)."""
        recipe = self.recipes.get_by_id(recipe_id)
        if not recipe: raise FacadeError("Recipe not found", status=404)

        self._require_recipe_owner_or_admin(user_id, recipe)

        updated = self.recipes.update(recipe_id, name=name, instructions=instructions, image_url=image_url)
        result = updated.to_dict()
        self._emit_group(
            "recipe.updated",
            {"group_id": recipe.group_id, "actor_user_id": user_id, "recipe": result},
            group_id=recipe.group_id,
        )
        return result

    def delete_recipe(self, *, user_id, recipe_id):
        """US-37: Delete recipe (Owner/Admin only)."""
        recipe = self.recipes.get_by_id(recipe_id)
        if not recipe: raise FacadeError("Recipe not found", status=404)

        self._require_recipe_owner_or_admin(user_id, recipe)
        self.recipes.delete(recipe_id)
        self._emit_group(
            "recipe.deleted",
            {"group_id": recipe.group_id, "actor_user_id": user_id, "recipe_id": recipe_id},
            group_id=recipe.group_id,
        )
        return {"message": "Recipe deleted"}

    def import_recipe_to_list(self, *, user_id, list_id, recipe_id):
        """US-34: Import all ingredients from a recipe into a shopping list."""
        # 1. Verify list access
        shopping_list = self.lists.get_by_id(list_id)
        if not shopping_list: raise FacadeError("List not found", status=404)
        self._require_membership(user_id=user_id, group_id=shopping_list.group_id)

        # 2. Get recipe
        recipe = self.recipes.get_by_id(recipe_id)
        if not recipe: raise FacadeError("Recipe not found", status=404)

        # 3. Verify recipe belongs to the same group (or user has access)
        if recipe.group_id != shopping_list.group_id:
            raise FacadeError("Recipe does not belong to this group", status=403)

        # 4. Import ingredients as ListItems
        ingredients = self.recipes.get_ingredients(recipe_id)
        imported_count = 0
        for ing in ingredients:
            item_id = ing.item_id
            if not item_id:
                # Ingredients created before catalog-matching existed (or
                # any future gap) still shouldn't produce a null item_id
                # on the imported ListItem.
                catalog_item = self.items.get_or_create_catalog_item(name=ing.name)
                item_id = catalog_item.item_id
            new_item = self.items.create(
                list_id=list_id,
                item_id=item_id,
                name=ing.name,
                quantity=ing.quantity,
                unit=ing.unit,
                added_by=user_id,
                is_urgent=False
            )
            self.history.create(
                list_id=list_id,
                list_item_id=new_item.list_item_id,
                user_id=user_id,
                action="created",
                metadata={"source_recipe": recipe.name},
            )
            imported_count += 1

        if imported_count:
            self._emit_group(
                "list.items_imported",
                {"group_id": shopping_list.group_id, "list_id": list_id, "actor_user_id": user_id,
                 "recipe_id": recipe_id, "imported_count": imported_count},
                group_id=shopping_list.group_id,
            )
        return {"message": f"Successfully imported {imported_count} items to the list"}
