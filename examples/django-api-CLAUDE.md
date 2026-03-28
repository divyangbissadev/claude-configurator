# CLAUDE.md — Django REST API

## Project

Django REST Framework API with Celery workers and PostgreSQL.

- **Repo**: GitHub — `myorg/api-service`
- **Stack**: Python 3.12, Django 5, DRF, Celery, PostgreSQL, Redis
- **Team**: Backend Engineering

## Commands

```bash
make run              # Development server (port 8000)
make test             # pytest with coverage
make lint             # ruff + mypy
make format           # black + ruff --fix
make migrate          # Run Django migrations
make celery           # Start Celery worker
make shell            # Django shell_plus
```

## Verification

- After ANY code change: run `make test`
- Before committing: run `make lint && make test`
- Commit format: `feat|fix|chore: <summary>`

## Critical Anti-Patterns

- **No raw SQL without parameterization** — use Django ORM or `params=[]`
- **No N+1 queries** — use `select_related()` and `prefetch_related()`
- **No business logic in views** — views delegate to services
- **No `Model.objects.all()` without pagination** — unbounded queries are dangerous
- **No hardcoded secrets** — use `django-environ`
- **No `DEBUG = True` in production** — always check `settings.DEBUG`
- **No synchronous external calls in request cycle** — use Celery tasks

## Architecture

```
apps/
├── users/              # User management
├── orders/             # Order domain
│   ├── models.py       # Django models
│   ├── serializers.py  # DRF serializers
│   ├── views.py        # DRF viewsets (thin)
│   ├── services.py     # Business logic
│   ├── tasks.py        # Celery tasks
│   └── tests/          # Per-app tests
├── payments/           # Payment integration
└── notifications/      # Email/SMS via Celery
config/
├── settings/           # Split settings (base, dev, prod)
├── urls.py
└── celery.py
```
