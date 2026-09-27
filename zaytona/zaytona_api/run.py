#!/usr/bin/env python3
"""Application entrypoint for the Zaytona API.

Run with:  python run.py
or:        flask --app run run --debug

.env is loaded by app.config on import, so no explicit load here.
"""
import eventlet

# Must happen before any other import that touches sockets/threading
# (Flask, SQLAlchemy/psycopg2, requests, ...) — eventlet's async_mode
# relies on the stdlib being patched to cooperatively yield. Skipping
# this doesn't fail loudly: a single client mostly still works, but the
# moment there's real concurrency (two clients at once) one blocking
# call (e.g. a synchronous psycopg2 query) can freeze eventlet's single
# event loop entirely — every connection hangs, not just that request.
# `gunicorn --worker-class eventlet` (Procfile) patches this itself, but
# `python run.py` -> socketio.run() does not, so it has to happen here.
eventlet.monkey_patch()

import logging

from app import create_app
from app.extensions import socketio

# So the "→ Authentica POST ..." / "← Authentica ..." lines in
# authentica_provider.py actually show up (INFO is below the logging
# module's default WARNING level otherwise).
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(name)s %(levelname)s %(message)s")

app = create_app()

# ── Register custom CLI commands ───────────────────────────
# Each command is defined in scripts/ and registered here so it's
# available via `flask <command>` from the project root.
from scripts.seed import seed_categories

app.cli.add_command(seed_categories)

if __name__ == "__main__":
    # host=0.0.0.0 so an emulator / physical phone on the LAN can reach it.
    # socketio.run (not app.run) so local dev gets a real websocket
    # transport too — Werkzeug's plain dev server doesn't support one.
    socketio.run(app, host="0.0.0.0", port=5000, debug=app.config.get("DEBUG", False))
