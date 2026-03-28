---
paths:
  - shared/**/*.py
  - workflows/**/*.py
---

# PySpark & Python Conventions

- All files: `from __future__ import annotations` at the top
- Import order: stdlib > third-party > first-party
- PySpark alias: `from pyspark.sql import functions as F` — use `F.col()`, never bare `col()`
- Formatter: black (100 char line)
- Linter: ruff
- Type checker: mypy strict
- One-line docstrings only unless explaining business logic
- Frozen dataclasses for configs
