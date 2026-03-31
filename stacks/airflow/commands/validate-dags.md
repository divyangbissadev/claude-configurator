---
description: Validate Airflow DAGs — parse test, import time, linting, and unit tests
---

# Validate DAGs

Run the following validation checks:

## DAG Parse Test
- Run `python -c "from airflow.models import DagBag; db = DagBag('.'); assert not db.import_errors, db.import_errors"` to verify all DAGs parse without errors.
- Alternatively run `airflow dags list` if the Airflow CLI is available.

## DAG Import Time Check
- Measure DAG file import time using `time python -c "import <dag_module>"`.
- Flag any DAG file that takes more than 2 seconds to import.
- Use `airflow dags report` for per-DAG timing if available.

## Linting
- Run `ruff check` on all DAG files for Python style and common errors.
- Fall back to `flake8` if ruff is not available.
- Check for Airflow-specific issues: deprecated imports, removed parameters, API changes.

## Unit Tests
- Run `pytest tests/` for DAG unit tests.
- Verify test coverage includes:
  - DAG validation (no import errors, correct task count).
  - Task dependency structure (upstream/downstream correctness).
  - Custom operator logic with mocked hooks and connections.

Report all findings with file paths, line numbers, and suggested fixes.
