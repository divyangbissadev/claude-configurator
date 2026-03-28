# Python-Spark Stack

Critical anti-patterns to avoid in PySpark and Delta Lake code:

- **No `.count()` for logging** — triggers full Spark actions. Use `.isEmpty()` on cached DFs only
- **No string interpolation in Spark filters** — use `F.col("x") == value`, never `f"x = '{value}'"` (SQL injection risk)
- **No `collect_list` without `sort_array`** — ordering is lost across shuffles
- **No hardcoded catalog names** — derive from config (`catalog_base` + `catalog_suffix`)
- **No `except Exception: pass`** in writers/readers — masks permission/network errors
- **No `write_mode="append"`** for output tables — always MERGE for idempotency
- **No broad `try/except` around `spark.read`** — use `DeltaTable.isDeltaTable()` for existence checks
- **No schema inference** — define `StructType` schemas explicitly
- **No `collect()` or `toPandas()`** in pipeline transforms — pulls all data to driver
- **No bare `col()`** — always use `F.col()` (import as `from pyspark.sql import functions as F`)
