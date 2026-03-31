# Airflow Testing Patterns

## DAG Validation Tests
- Test that all DAGs load without import errors using `DagBag`.
- Verify expected number of tasks per DAG.
- Check task dependencies match the intended graph structure.
- Validate no cycles exist in the DAG.

```python
def test_dag_loaded_with_no_errors():
    dag_bag = DagBag(dag_folder="dags/", include_examples=False)
    assert len(dag_bag.import_errors) == 0, f"DAG import errors: {dag_bag.import_errors}"
```

## Task Mocking
- Mock external connections using `unittest.mock.patch` on hook methods.
- Use `airflow.models.Connection` with `mock_connections` fixture.
- Mock `Variable.get()` calls with environment variables (`AIRFLOW_VAR_*`).
- Never call real external services in unit tests.

```python
@mock.patch("airflow.providers.http.hooks.http.HttpHook.run")
def test_http_task(mock_run):
    mock_run.return_value = Mock(status_code=200, json=lambda: {"key": "value"})
    # Execute task logic
```

## TaskFlow Testing
- Test `@task` functions as regular Python functions by calling them directly.
- Verify return values and XCom outputs.
- Test branching logic by asserting the returned task ID.

## Integration Testing
- Use `dag.test()` method (Airflow 2.5+) for local DAG execution.
- Set up test connections in `airflow_db` fixture or environment variables.
- Use Docker Compose to spin up dependent services (databases, APIs) for integration tests.

## Test Organization
- Place tests in `tests/dags/` mirroring the `dags/` directory structure.
- Name test files `test_<dag_id>.py`.
- Use pytest fixtures for common setup (DagBag, connections, variables).
- Run tests in CI with `pytest --tb=short -q tests/`.
