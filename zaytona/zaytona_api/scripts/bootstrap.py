"""One-shot setup for a brand-new Supabase project.

Point .env at the new project first (DATABASE_URL, SUPABASE_URL,
SUPABASE_SERVICE_KEY), then from the project root:
    flask --app run bootstrap-supabase --avatars-dir <folder with av-*.png>

Idempotent — safe to re-run. By the time this runs, create_app() has
already called db.create_all(), so every table/enum from the models
exists. On top of that it:
  * seeds the 16 default categories (same as `flask seed-categories`)
  * enables row-level security on every public table. This backend
    connects as the postgres role (the table owner), which bypasses
    RLS — so nothing changes for the API, but the anon key can no
    longer read/write the tables through Supabase's auto REST API.
  * creates the public `avatars` and `item-images` storage buckets and
    uploads the preset avatars (av-*.jpg/png/webp) if --avatars-dir
    is given.
"""
import mimetypes
from pathlib import Path

import click
from flask import current_app
from flask.cli import with_appcontext
from sqlalchemy import text
from supabase import create_client

from app.extensions import db
from app.services.providers.supabase_storage_provider import ITEM_IMAGES_BUCKET
from scripts.seed import seed_categories

AVATARS_BUCKET = "avatars"
AVATAR_EXTENSIONS = (".jpg", ".jpeg", ".png", ".webp")


@click.command("bootstrap-supabase")
@click.option(
    "--avatars-dir",
    type=click.Path(exists=True, file_okay=False, path_type=Path),
    help="Folder holding the preset avatar images (av-*.png etc).",
)
@click.pass_context
@with_appcontext
def bootstrap_supabase(ctx, avatars_dir):
    """Set up a fresh Supabase project: seed data, RLS, storage buckets."""
    ctx.invoke(seed_categories)

    tables = db.session.execute(
        text("select tablename from pg_tables where schemaname = 'public'")
    ).scalars().all()
    for table in tables:
        db.session.execute(text(f'alter table public."{table}" enable row level security'))
    db.session.commit()
    click.echo(f"✅ RLS enabled on {len(tables)} tables: {', '.join(sorted(tables))}")

    url = current_app.config.get("SUPABASE_URL")
    key = current_app.config.get("SUPABASE_SERVICE_KEY")
    if not url or not key:
        raise click.ClickException("SUPABASE_URL / SUPABASE_SERVICE_KEY are not set")
    storage = create_client(url, key).storage

    existing = {b.name for b in storage.list_buckets()}
    for bucket in (AVATARS_BUCKET, ITEM_IMAGES_BUCKET):
        if bucket in existing:
            click.echo(f"• bucket '{bucket}' already exists")
        else:
            storage.create_bucket(bucket, options={"public": True})
            click.echo(f"✅ created public bucket '{bucket}'")

    if avatars_dir is None:
        click.echo("• no --avatars-dir given, skipped avatar upload")
        return

    uploaded = {f["name"] for f in storage.from_(AVATARS_BUCKET).list()}
    avatars = sorted(
        p for p in avatars_dir.iterdir()
        if p.name.startswith("av-") and p.suffix.lower() in AVATAR_EXTENSIONS
    )
    for path in avatars:
        if path.name in uploaded:
            click.echo(f"• avatar {path.name} already uploaded")
            continue
        content_type = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
        storage.from_(AVATARS_BUCKET).upload(
            path.name, path.read_bytes(), {"content-type": content_type}
        )
        click.echo(f"✅ uploaded avatar {path.name}")
