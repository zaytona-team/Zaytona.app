"""Recipes API namespace (US-33, US-34, US-35, US-37)."""
from flask import g
from flask_restx import Namespace, Resource, fields

from app.api.v1.security import jwt_required
from app.services.facade import get_facade, FacadeError
from app.models.list_item import ALLOWED_UNITS

ns = Namespace("recipes", description="Group recipes management")

recipe_ingredient_model = ns.model("RecipeIngredient", {
    "name": fields.String(required=True, example="Flour"),
    "quantity": fields.Float(required=True, example=2.0),
    "unit": fields.String(required=True, enum=ALLOWED_UNITS, example="kg"),
    "item_id": fields.String(required=False, description="Optional catalog item ID")
})

create_recipe_model = ns.model("CreateRecipeRequest", {
    "name": fields.String(required=True, example="Pancakes"),
    "instructions": fields.String(required=False, example="Mix and fry"),
    "image_url": fields.String(required=False),
    "ingredients": fields.List(fields.Nested(recipe_ingredient_model), required=True),
    "source_recipe_id": fields.String(
        required=False,
        description="Recipe this is a customized copy of (e.g. forked from the recipe book into this group)",
    ),
})

def _handle(fn):
    try: return fn()
    except FacadeError as e: ns.abort(e.status, e.message)

@ns.route("/groups/<string:group_id>/recipes")
@ns.param("group_id", "The group UUID")
class GroupRecipes(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.expect(create_recipe_model, validate=True)
    @ns.response(201, "Recipe created")
    def post(self, group_id):
        """US-33: Create a new recipe in the group."""
        data = ns.payload
        facade = get_facade()
        return _handle(lambda: facade.create_recipe(
            user_id=g.user_id, group_id=group_id, name=data["name"],
            instructions=data.get("instructions"), image_url=data.get("image_url"),
            ingredients=data["ingredients"], source_recipe_id=data.get("source_recipe_id"),
        )), 201

    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "List of group recipes")
    def get(self, group_id):
        """US-35: List all recipes in the group."""
        facade = get_facade()
        facade._require_membership(user_id=g.user_id, group_id=group_id)
        recipes = facade.recipes.list_by_group(group_id)
        return [r.to_dict() for r in recipes], 200

@ns.route("/<string:recipe_id>")
@ns.param("recipe_id", "The recipe UUID")
class RecipeDetail(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Recipe details with ingredients")
    def get(self, recipe_id):
        facade = get_facade()
        recipe = facade.recipes.get_by_id(recipe_id)
        if not recipe: ns.abort(404, "Recipe not found")
        
        # Check membership to view
        facade._require_membership(user_id=g.user_id, group_id=recipe.group_id)
        
        result = recipe.to_dict()
        result["ingredients"] = [i.to_dict() for i in facade.recipes.get_ingredients(recipe_id)]
        return result, 200

    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Recipe updated")
    def patch(self, recipe_id):
        """US-37: Update recipe (Owner/Admin only)."""
        data = ns.payload
        facade = get_facade()
        return _handle(lambda: facade.update_recipe(
            user_id=g.user_id, recipe_id=recipe_id, 
            name=data.get("name"), instructions=data.get("instructions"), image_url=data.get("image_url")
        ))

    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Recipe deleted")
    def delete(self, recipe_id):
        """US-37: Delete recipe (Owner/Admin only)."""
        facade = get_facade()
        return _handle(lambda: facade.delete_recipe(user_id=g.user_id, recipe_id=recipe_id))

@ns.route("/lists/<string:list_id>/items/from-recipe/<string:recipe_id>")
@ns.param("list_id", "The shopping list UUID")
@ns.param("recipe_id", "The recipe UUID")
class ImportRecipeToList(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(201, "Ingredients imported to list")
    def post(self, list_id, recipe_id):
        """US-34: Import all recipe ingredients into a shopping list."""
        facade = get_facade()
        return _handle(lambda: facade.import_recipe_to_list(
            user_id=g.user_id, list_id=list_id, recipe_id=recipe_id
        )), 201
