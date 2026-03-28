---
paths:
  - tests/**/*.py
---

# PySpark Testing Conventions

- All tests use local PySpark (`master=local[2]`) with Delta Lake
- Session-scoped `spark_session` fixture in `tests/conftest.py`
- Function-scoped `temp_dir` and `delta_table_path` fixtures for isolation
- Coverage minimum as defined in project vars
- Test names: `test_<unit>_<condition>_<expected>`
- All test methods MUST have docstrings explaining what they verify
