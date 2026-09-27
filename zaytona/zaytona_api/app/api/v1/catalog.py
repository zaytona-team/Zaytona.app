"""Catalog API namespace — searching product catalog.

Endpoints:
  GET /search?q=<query>  Search for products and brands
  GET /<item_id>         Get product details
"""
from flask import request
from flask_restx import Namespace, Resource

from app.api.v1.security import jwt_required
from app.services.facade import get_facade

ns = Namespace("catalog", description="Product catalog search")


@ns.route("/search")
class CatalogSearch(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.param("q", "Search query (product name or brand)", required=True, _in="query")
    @ns.param("limit", "Max results to return", _in="query", default=20)
    @ns.response(200, "List of matching products")
    def get(self):
        """Search the product catalog."""
        query = request.args.get("q", "").strip()
        limit = int(request.args.get("limit", 20))
        
        if not query:
            return {"error": "Query parameter 'q' is required"}, 400
        
        facade = get_facade()
        results = facade.search_catalog(query=query, limit=limit)
        
        return {"results": results, "count": len(results)}, 200


@ns.route("/<string:item_id>")
@ns.param("item_id", "The catalog item UUID")
class CatalogItemDetail(Resource):
    @ns.doc(security="Bearer")
    @jwt_required
    @ns.response(200, "Product details")
    @ns.response(404, "Product not found")
    def get(self, item_id):
        """Get catalog item details by ID."""
        facade = get_facade()
        result = facade.get_catalog_by_id(item_id=item_id)
        
        if not result:
            return {"error": "Product not found"}, 404
        
        return result, 200
