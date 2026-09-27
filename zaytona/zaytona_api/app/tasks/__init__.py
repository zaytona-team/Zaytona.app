"""Celery tasks. Importing this package (see app/__init__.py) registers
every @shared_task with Celery so beat_schedule's task names resolve."""
from app.tasks import reminders  # noqa: F401
from app.tasks import retention  # noqa: F401
