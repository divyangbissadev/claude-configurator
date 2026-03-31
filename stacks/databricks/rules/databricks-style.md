---
paths:
  - src/**/*.py
  - notebooks/**/*.py
  - workflows/**/*.py
---

# Databricks Coding Conventions

## Language and Library Versions

- Python 3.11+ / PySpark 3.5+ / Delta Lake 3.0+
- MLflow 2.x for experiment tracking and model registry
- Databricks SDK for Python for API interactions

## Python Standards

- All files: `from __future__ import annotations` at the top
- Import order: stdlib > third-party > first-party (enforced by ruff/isort)
- Formatter: black (100 char line)
- Linter: ruff
- Type checker: mypy strict
- One-line docstrings only unless explaining business logic
- Frozen dataclasses for configs: `@dataclass(frozen=True)`

## PySpark Standards

- Alias: `from pyspark.sql import functions as F` — use `F.col()`, never bare `col()`
- Alias: `from pyspark.sql import types as T` — use `T.StructType()`, `T.StringType()`
- Explicit `StructType` schemas for all read operations — no `inferSchema`
- Column references: `F.col("name")`, never `df.name` or `df["name"]` in transforms
- MERGE for all write operations to output tables — no `write_mode="append"`
- `DeltaTable.isDeltaTable()` for existence checks — no `try/except` on read

## Naming Conventions

- Tables follow Medallion architecture: `bronze_`, `silver_`, `gold_` prefixes
- Catalog names: `{environment}` (e.g., `production`, `development`, `staging`)
- Schema names: `{domain}` (e.g., `sales`, `marketing`, `finance`)
- DLT functions: named after the target table (e.g., `def bronze_events():`)
- Job names: `{team}-{pipeline}-{environment}` (e.g., `de-ingest-production`)
- Feature tables: `{domain}_features` (e.g., `user_features`, `product_features`)

## Configuration

- Frozen dataclasses for pipeline configs — no mutable dicts
- Environment-specific values via `spark.conf.get()` or Databricks widgets
- Secrets via `dbutils.secrets.get(scope, key)` — never hardcoded
- Cluster configs via cluster policies — never ad-hoc sizing

## File Organization

```
src/
  bronze/          # Ingestion layer
  silver/          # Cleansing and conforming
  gold/            # Business-level aggregations
  common/          # Shared utilities, schemas, configs
tests/
  unit/            # Local PySpark tests
  integration/     # Databricks-connected tests
resources/
  schemas/         # JSON/YAML schema definitions
databricks.yml     # Databricks Asset Bundle definition
pyproject.toml     # Python project configuration
```
