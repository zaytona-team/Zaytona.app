"""Seed scripts for the Zaytona database.

These commands populate reference data tables with their default values.
All commands are idempotent — safe to run multiple times; existing
records are skipped.

Usage (from the project root):
    flask seed-categories    # Seed the 16 default grocery categories

Each command runs within the Flask app context automatically thanks
to @with_appcontext, so we can use db.session directly.
"""
import click
from flask.cli import with_appcontext

from app.extensions import db
from app.models.category import Category


# ── Default grocery categories ─────────────────────────────
# 16 categories in standard store aisle sequence.
# `sort_order` matches the order a shopper would walk through
# a typical grocery store (produce first → frozen last → non-food aisles).
# Matches the ERD enum: Fresh Produce, Meat & Seafood, Dairy & Eggs,
# Bakery, Pantry, Cooking Essentials, Breakfast, Snacks, Beverages,
# Frozen, Ready-to-Eat, Baby, Personal Care, Health, Household, Pets.
DEFAULT_CATEGORIES = [
    ("Fresh Produce", 1),
    ("Meat & Seafood", 2),
    ("Dairy & Eggs", 3),
    ("Bakery", 4),
    ("Pantry", 5),
    ("Cooking Essentials", 6),
    ("Breakfast", 7),
    ("Snacks", 8),
    ("Beverages", 9),
    ("Frozen", 10),
    ("Ready-to-Eat", 11),
    ("Baby", 12),
    ("Personal Care", 13),
    ("Health", 14),
    ("Household", 15),
    ("Pets", 16),
]


@click.command("seed-categories")
@with_appcontext
def seed_categories():
    """Seed the 16 default grocery categories into the database.

    Idempotent — safe to run multiple times; existing categories
    (matched case-insensitively by name) are skipped.

    Design decisions (per documentation):
      * Categories are a fixed system enum (no free-text)
      * 16 default categories match the ERD comments
      * sort_order defines the standard store aisle sequence (US-26)
    """
    added = 0
    skipped = 0

    for name, order in DEFAULT_CATEGORIES:
        # Case-insensitive check to avoid duplicates like "Fresh Produce" vs "fresh produce"
        existing = (
            db.session.query(Category)
            .filter(db.func.lower(Category.name) == name.lower())
            .first()
        )
        if existing:
            skipped += 1
            continue

        db.session.add(Category(name=name, sort_order=order))
        added += 1

    db.session.commit()

    total = db.session.query(Category).count()
    click.echo(
        f"✅ Categories seed complete. "
        f"Added: {added}, Skipped: {skipped}, Total in DB: {total}"
    )