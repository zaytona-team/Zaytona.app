"""Shared extension singletons, initialised in the app factory.

Kept separate from __init__.py to avoid circular imports between
models / services and the application object.
"""
from celery import Celery, Task
from flask_cors import CORS
from flask_socketio import SocketIO
from flask_sqlalchemy import SQLAlchemy

# SQLAlchemy ORM handle. Models import `db` from here.
db = SQLAlchemy()

# CORS so the Flutter web build (and tooling) can call the API.
cors = CORS()

# Real-time transport for group/list/trip sync. cors_allowed_origins and
# async_mode need app.config, so they're set in socketio.init_app(app, ...)
# inside the factory, not here — same reason db/cors are only init_app'd
# there too.
socketio = SocketIO()


def celery_init_app(app) -> Celery:
    """Build the Celery app bound to this Flask app's context, so every
    task (e.g. the 12h list-reminder sweep) can use `db`/`current_app`
    exactly like a request would. Standard Flask 3 + Celery 5 factory
    pattern — see make_celery.py for the worker/beat entry point."""

    class FlaskTask(Task):
        def __call__(self, *args, **kwargs):
            with app.app_context():
                return self.run(*args, **kwargs)

    celery_app = Celery(app.name, task_cls=FlaskTask)
    celery_app.config_from_object(app.config["CELERY"])
    celery_app.set_default()
    app.extensions["celery"] = celery_app
    return celery_app
