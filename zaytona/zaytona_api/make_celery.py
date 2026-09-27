"""Entry point for the Celery worker and beat processes.

The Flask app factory registers the Celery app at app.extensions["celery"]
(see app/extensions.py::celery_init_app) so it's bound to the same Flask
app context every request uses — this module just builds the Flask app
and hands that Celery app back out for the CLI to find.

Run (two separate processes, from zaytona_api/):
  celery -A make_celery worker --loglevel=info
  celery -A make_celery beat    --loglevel=info
"""
from app import create_app

flask_app = create_app()
celery_app = flask_app.extensions["celery"]
