---
description: Run full quality gate on PySpark pipeline code — lint, type check, tests, anti-pattern scan.
---

# Validate Pipeline

## Steps

### 1. Lint Check
```bash
python3 -m ruff check shared/ workflows/ tests/ 2>&1 | tail -20
python3 -m black --check shared/ workflows/ tests/ 2>&1 | tail -10
```

### 2. Type Check
```bash
python3 -m mypy shared/ workflows/ --ignore-missing-imports 2>&1 | tail -20
```

### 3. Unit Tests
```bash
python3 -m pytest tests/unit/ -v --no-cov 2>&1 | tail -30
```

### 4. Anti-Pattern Scan

Search for known PySpark anti-patterns:
- `.count()` outside tests
- String interpolation in `.filter()` / `.where()`
- `except Exception: pass`
- `write_mode="append"` on output tables
- `inferSchema` usage
- `collect()` / `toPandas()` in transforms
- Missing `from __future__ import annotations`
- Hardcoded catalog names
