---
description: Validate Databricks project — check structure, DLT definitions, Unity Catalog references, lint, and test.
---

# Validate Databricks

## Steps

### 1. Project Structure Check

Verify expected directory structure exists:
```bash
echo "=== Checking project structure ==="
for dir in src tests resources; do
  if [ -d "$dir" ]; then echo "OK: $dir/"; else echo "MISSING: $dir/"; fi
done
for f in databricks.yml pyproject.toml; do
  if [ -f "$f" ]; then echo "OK: $f"; else echo "MISSING: $f"; fi
done
```

### 2. DLT Pipeline Validation

Search for DLT definitions and verify expectations:
- Every `@dlt.table` must have at least one `@dlt.expect` decorator
- No `try/except` blocks wrapping DLT transforms
- No hardcoded file paths in DLT notebooks

```bash
echo "=== DLT tables without expectations ==="
grep -rn "@dlt.table" src/ --include="*.py" -l | while read f; do
  if ! grep -q "@dlt.expect" "$f"; then
    echo "WARNING: $f has @dlt.table but no @dlt.expect"
  fi
done
```

### 3. Unity Catalog Reference Check

Verify 3-level namespace usage:
- Search for unqualified table references
- Verify no direct storage path access (mounts, abfss://, s3://)

```bash
echo "=== Checking for direct storage paths ==="
grep -rn "abfss://\|s3://\|gs://\|dbfs:/mnt" src/ tests/ --include="*.py" 2>/dev/null | head -20
echo "=== Checking for mount usage ==="
grep -rn "dbutils.fs.mount\|/mnt/" src/ tests/ --include="*.py" 2>/dev/null | head -20
```

### 4. Anti-Pattern Scan

Search for known Databricks anti-patterns:
- Bare `col()` without `F.` prefix
- `.count()` outside tests
- `inferSchema` usage
- `collect()` / `toPandas()` in non-test code
- Hardcoded cluster IDs
- `except Exception: pass`
- `write_mode="append"` on output tables
- Hardcoded secrets or tokens

```bash
echo "=== Anti-pattern scan ==="
grep -rn "from pyspark.sql.functions import col" src/ --include="*.py" 2>/dev/null | head -10
grep -rn "inferSchema" src/ --include="*.py" 2>/dev/null | head -10
grep -rn "\.collect()\|\.toPandas()" src/ --include="*.py" 2>/dev/null | head -10
grep -rn "existing_cluster_id" src/ resources/ --include="*.py" --include="*.yml" --include="*.yaml" 2>/dev/null | head -10
grep -rn "except Exception: pass\|except:$" src/ --include="*.py" 2>/dev/null | head -10
grep -rn "token.*=.*['\"]dapi" src/ --include="*.py" 2>/dev/null | head -10
```

### 5. Lint Check

```bash
echo "=== Ruff lint ==="
python3 -m ruff check src/ tests/ 2>&1 | tail -20
echo "=== Black format check ==="
python3 -m black --check src/ tests/ 2>&1 | tail -10
echo "=== Mypy type check ==="
python3 -m mypy src/ --ignore-missing-imports 2>&1 | tail -20
```

### 6. Run Tests

```bash
echo "=== Unit tests ==="
python3 -m pytest tests/unit/ -v --no-cov 2>&1 | tail -30
echo "=== Integration tests (if available) ==="
python3 -m pytest tests/integration/ -v --no-cov 2>&1 | tail -30
```
