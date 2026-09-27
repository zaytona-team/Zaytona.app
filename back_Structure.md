```
├── zaytona_api/                                # ── BACKEND branch ── Flask API (layered + facade, HBnB-style)
│   ├── README.md                               # backend guide: endpoints, Swagger, .env, Supabase, run steps
│   ├── run.py                                  # ✅ entrypoint: creates app, serves on :5000
│   ├── requirements.txt                        # Python deps: flask, flask-restx, SQLAlchemy, PyJWT, requests…
│   ├── .env.example                            # template for secrets (copy → .env, then fill in)
│   ├── app/                                     # application package
│   │   ├── __init__.py                          # ✅ app factory: init extensions, mount flask-restx Api + Swagger
│   │   ├── config.py                            # ✅ config: DATABASE_URL, Supabase keys, JWT secret, OTP order
│   │   ├── extensions.py                        # ✅ shared singletons: db (SQLAlchemy), cors
│   │   │
│   │   ├── api/                                 # HTTP layer (controllers)
│   │   │   └── v1/                              # version 1 of the API
│   │   │       ├── __init__.py                  # marks the package
│   │   │       ├── security.py                  # ✅ @jwt_required decorator: verifies Supabase-issued JWT
│   │   │       ├── auth.py                       # ✅ US-01/02/36 endpoints + flask-restx Swagger models
│   │   │       ├── groups.py                     # ⬜ placeholder namespace (no endpoints yet)
│   │   │       ├── lists.py                       # ⬜ placeholder namespace
│   │   │       ├── items.py                       # ⬜ placeholder namespace
│   │   │       ├── categories.py                  # ⬜ placeholder namespace
│   │   │       └── histories.py                   # ⬜ placeholder namespace
│   │   │
│   │   ├── models/                              # SQLAlchemy ORM models (one per ERD entity)
│   │   │   ├── __init__.py                       # ✅ model registry (imports User; others commented until built)
│   │   │   ├── base_model.py                     # ✅ shared UUID PK helper + created/updated TimestampMixin
│   │   │   ├── user.py                            # ✅ USER — public profile mirror (user_id == Supabase auth uid)
│   │   │   ├── user_device.py                     # ⬜ ERD stub (push tokens) — fields in docstring
│   │   │   ├── group.py                            # ⬜ ERD stub (GROUP: individual|household, invite_code)
│   │   │   ├── group_member.py                     # ⬜ ERD stub (user↔group join + role)
│   │   │   ├── category.py                          # ⬜ ERD stub (16 system categories enum)
│   │   │   ├── item.py                               # ⬜ ERD stub (canonical catalog entry)
│   │   │   ├── shopping_list.py                       # ⬜ ERD stub (SHOPPING_LIST)
│   │   │   ├── list_item.py                            # ⬜ ERD stub (one item added to a list)
│   │   │   ├── history.py                               # ⬜ ERD stub (LIST_ACTION — activity log + undo)
│   │   │   ├── trip.py                                   # ⬜ ERD stub (locks a list for a shopping session)
│   │   │   ├── recipe.py                                  # ⬜ ERD stub (RECIPE)
│   │   │   ├── recipe_ingredient.py                        # ⬜ ERD stub (recipe↔item junction)
│   │   │   └── instruction.py                               # ⬜ ERD stub (ordered recipe step)
│   │   │
│   │   ├── services/                            # business / orchestration layer
│   │   │   ├── __init__.py                       # marks the package
│   │   │   ├── facade.py                          # ✅ ZaytonaFacade — the ONLY thing the API layer calls
│   │   │   └── providers/                         # external-service adapters (behind the facade)
│   │   │       ├── __init__.py                    # marks the package
│   │   │       ├── supabase_provider.py           # ✅ calls Supabase Auth (GoTrue): signup/token/otp/verify
│   │   │       └── channels.py                     # ✅ US-36 fallback: SMS(real) → WhatsApp(mock) → Email(real)
│   │   │
│   │   └── persistence/                         # data-access layer (DB only — no business logic)
│   │       ├── __init__.py                       # marks the package
│   │       └── repositories/                     # one repository per aggregate
│   │           ├── __init__.py                   # ✅ repo registry (UserRepository active)
│   │           ├── user_repository.py            # ✅ profile CRUD via SQLAlchemy (create/get/update)
│   │           ├── group_repository.py           # ⬜ stub
│   │           ├── list_repository.py             # ⬜ stub
│   │           ├── item_repository.py             # ⬜ stub
│   │           └── history_repository.py          # ⬜ stub
│   │
│   ├── migrations/                              # Alembic database migrations
│   │   └── README.md                            # how to init Alembic & autogenerate the users table
│   └── tests/                                    # backend tests
│       ├── __init__.py                          # marks the package
│       └── test_auth.py                          # ✅ validation smoke tests (run without live Supabase)
│
└── supabase/                                    # ── BACKEND branch ── DB scripts (Supabase Postgres)
    ├── schema.sql                                # ✅ public.users profile mirror + trigger auto-creating it on signup
    └── seed.sql                                  # ⬜ placeholder (system categories & sample recipes later)
```