"""Application factory.

Builds the Flask app, initialises extensions, mounts the flask-restx
Api (which auto-generates Swagger at /api/v1/docs) and registers the
versioned namespaces.

Every namespace below carries real logic (auth, groups, categories,
lists, items, recipes, histories, trips, devices) except Instruction,
which has no user story yet (see app/models/__init__.py).
"""
from flask import Flask
from flask_restx import Api

from .config import get_config
from .extensions import celery_init_app, cors, db, socketio


def create_app(config_object=None):
    app = Flask(__name__)
    app.config.from_object(config_object or get_config())
    # Our own 404s are business-logic ("no account found"), not mistyped
    # routes — flask-restx's "did you mean ...?" URL-suggestion help is
    # misleading here, so turn it off.
    app.config["RESTX_ERROR_404_HELP"] = False
    # The groups collection route is "/groups/" (flask-restx's ns.route("/")
    # under prefix "/groups"). Without this, calling "/groups" (no trailing
    # slash — the natural way to write it, and what curl/most HTTP clients
    # send without following redirects on POST) 308-redirects instead of
    # hitting the view.
    app.url_map.strict_slashes = False

    # ── init extensions ──────────────────────────────────────
    db.init_app(app)
    cors.init_app(app, resources={r"/api/*": {"origins": app.config["CORS_ORIGINS"]}})
    # Registers app.extensions["celery"] — tasks import it from
    # make_celery.py, the entry point for `celery worker` / `celery beat`.
    celery_init_app(app)
    # async_mode="eventlet" requires gunicorn to run with
    # --worker-class eventlet in production (see Procfile) — with the
    # default sync worker, Socket.IO silently falls back to long-polling
    # instead of true websockets. message_queue is only needed once more
    # than one gunicorn worker is running (unset today).
    # flask-cors treats a list containing "*" as allow-all (line 34 above),
    # but flask-socketio's cors_allowed_origins does NOT special-case
    # that — a list containing "*" is instead one specific literal
    # allowed origin, so nothing else ever matches, silently rejecting
    # every WebSocket upgrade whose Origin header isn't the exact string
    # "*". Needs the bare string, not a single-item list, to actually
    # mean wildcard.
    socketio_cors_origins = (
        "*" if app.config["CORS_ORIGINS"] == ["*"] else app.config["CORS_ORIGINS"]
    )
    socketio.init_app(
        app,
        cors_allowed_origins=socketio_cors_origins,
        async_mode="eventlet",
        message_queue=app.config.get("SOCKETIO_MESSAGE_QUEUE_URL"),
    )

    # Importing the tasks module registers every @shared_task with Celery
    # (name -> function), which is what lets the beat_schedule's string
    # task name ("reminders.sweep_list_reminders") resolve at dispatch
    # time — otherwise beat would enqueue a task nothing picks up.
    from app import tasks  # noqa: F401

    # Registers @socketio.on("connect"/"disconnect") — import-for-side-
    # effects, same pattern as the tasks import above.
    from app import sockets  # noqa: F401

    # ── flask-restx Api → Swagger UI at /api/v1/docs ─────────
    authorizations = {
        "Bearer": {
            "type": "apiKey",
            "in": "header",
            "name": "Authorization",
            "description": "Zaytona session token (from /auth/otp/verify). Format: **Bearer &lt;token&gt;**",
        }
    }
    api = Api(
        app,
        version="1.0",
        title="Zaytona API",
        description="Shared grocery & recipe app — backend gateway to Supabase.",
        doc="/api/v1/docs",
        prefix="/api/v1",
        authorizations=authorizations,
        security="Bearer",
    )

    # ── namespaces ───────────────────────────────────────────
    from .api.v1.auth import ns as auth_ns
    from .api.v1.catalog import ns as catalog_ns
    from .api.v1.categories import ns as categories_ns
    from .api.v1.devices import ns as devices_ns
    from .api.v1.groups import ns as groups_ns
    from .api.v1.histories import ns as histories_ns
    from .api.v1.items import ns as items_ns
    from .api.v1.lists import ns as lists_ns
    from .api.v1.notifications import ns as notifications_ns
    from .api.v1.recipes import ns as recipes_ns
    from .api.v1.trips import ns as trips_ns
    from .api.v1.users import ns as users_ns

    api.add_namespace(auth_ns, path="/auth")
    api.add_namespace(groups_ns, path="/groups")
    api.add_namespace(categories_ns, path="/categories")
    api.add_namespace(lists_ns, path="/lists")
    api.add_namespace(items_ns, path="/lists")
    api.add_namespace(notifications_ns, path="/lists")
    api.add_namespace(recipes_ns, path="")
    api.add_namespace(histories_ns, path="/lists")
    api.add_namespace(trips_ns, path="/")
    api.add_namespace(devices_ns, path="/devices")
    api.add_namespace(users_ns, path="/users")
    api.add_namespace(catalog_ns, path="/catalog")

    # Model-level `@validates` methods (app/models/validators.py) raise
    # plain ValueError on bad input — map that to a clean 400 instead of
    # an unhandled 500, per validation.md's error-handling table.
    @api.errorhandler(ValueError)
    def _handle_value_error(error):
        return {"message": str(error)}, 400

    # Create tables for models that exist (profile mirror, etc.).
    # In real deployments prefer Alembic migrations over create_all.
    with app.app_context():
        db.create_all()

    # ── `flask shell` context: db + every active model pre-imported ──
    # Run with: FLASK_APP=run.py flask shell
    @app.shell_context_processor
    def _shell_context():
        from app.models.category import Category
        from app.models.group import Group
        from app.models.group_member import GroupMember
        from app.models.recipe import Recipe
        from app.models.shopping_list import ShoppingList
        from app.models.user import User

        return {
            "db": db,
            "User": User,
            "Group": Group,
            "GroupMember": GroupMember,
            "ShoppingList": ShoppingList,
            "Recipe": Recipe,
            "Category": Category,
        }

    return app
