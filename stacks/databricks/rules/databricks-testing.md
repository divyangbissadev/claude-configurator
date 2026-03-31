---
paths:
  - tests/**/*.py
---

# Databricks Testing Conventions

## Framework and Tools

- Test framework: pytest
- DataFrame assertions: chispa (`assert_df_equality`, `assert_column_equality`)
- Local Spark: `master=local[2]` with Delta Lake extensions
- Remote testing: databricks-connect for integration tests
- Coverage: pytest-cov with minimum threshold defined in project config

## Test Structure

- `tests/unit/` — Local PySpark tests, no Databricks dependency
- `tests/integration/` — Tests requiring Databricks connectivity
- `tests/conftest.py` — Session-scoped `spark_session` fixture with Delta Lake
- Test isolation: function-scoped `temp_dir` and `delta_table_path` fixtures

## Naming

- Test files: `test_<module>.py`
- Test functions: `test_<unit>_<condition>_<expected>`
- All test functions MUST have docstrings explaining what they verify

## Fixtures

### Spark Session
```python
@pytest.fixture(scope="session")
def spark_session():
    """Session-scoped local Spark with Delta Lake."""
    return (
        SparkSession.builder
        .master("local[2]")
        .config("spark.sql.extensions", "io.delta.sql.DeltaSparkSessionExtension")
        .config("spark.sql.catalog.spark_catalog", "org.apache.spark.sql.delta.catalog.DeltaCatalog")
        .config("spark.sql.shuffle.partitions", "2")
        .getOrCreate()
    )
```

### Temporary Delta Table
```python
@pytest.fixture
def delta_table_path(tmp_path):
    """Function-scoped temp directory for Delta table isolation."""
    return str(tmp_path / "delta_table")
```

## DataFrame Assertions with chispa

```python
from chispa import assert_df_equality

def test_transform_deduplicates_by_id(spark_session):
    """Verify transform removes duplicate rows by ID, keeping latest."""
    input_df = spark_session.createDataFrame(input_data, schema=input_schema)
    expected_df = spark_session.createDataFrame(expected_data, schema=expected_schema)
    result_df = transform(input_df)
    assert_df_equality(result_df, expected_df, ignore_row_order=True)
```

## Integration Testing with Unity Catalog

- Use a dedicated `testing` catalog for integration tests
- Clean up test tables after each test run
- Use unique schema names per test run to avoid conflicts
- Never run integration tests against production catalogs

```python
@pytest.fixture(scope="session")
def test_schema(spark_session):
    """Create an isolated schema for this test run."""
    schema_name = f"testing.test_run_{uuid4().hex[:8]}"
    spark_session.sql(f"CREATE SCHEMA IF NOT EXISTS {schema_name}")
    yield schema_name
    spark_session.sql(f"DROP SCHEMA IF EXISTS {schema_name} CASCADE")
```

## Key Rules

- NEVER mock Spark — use local PySpark for unit tests
- NEVER use `assert df.count() == N` — use chispa for full DataFrame comparison
- ALWAYS test with explicit schemas — no relying on inference in tests
- ALWAYS test MERGE logic with duplicate and out-of-order data
- ALWAYS test DLT expectations by passing both valid and invalid data
- ALWAYS run `ruff` and `mypy` before test execution in CI
