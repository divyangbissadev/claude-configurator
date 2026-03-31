# Airflow Stack — Anti-patterns and Guidelines

## Anti-patterns

- No top-level code in DAG files. All imports and logic outside the DAG context manager hurt parsing performance.
- No hardcoded connections. Always use Airflow connections and variables via `BaseHook.get_connection()` or `Variable.get()`.
- No `provide_context=True` in Airflow 2.x — context is passed automatically to Python callables.
- No heavy computation in DAG file scope. DAG files are parsed every `dag_file_processor_timeout` seconds; keep them lightweight.
- No `trigger_rule="all_done"` without understanding that it runs even when upstream tasks fail or are skipped.
- Always set `catchup=False` unless backfill is intentional. Unintended catchup can overwhelm the scheduler.

## Required Practices

- Always use the TaskFlow API (`@task` decorator) for Python operators instead of `PythonOperator`.
- Use the `with DAG(...)` context manager pattern for DAG definition.
- Return values from `@task` functions instead of using XCom push/pull directly.
- Use dynamic task mapping (`expand()`/`partial()`) instead of generating tasks in a loop.
- Set meaningful `owner`, `retries`, `retry_delay`, and `tags` in `default_args`.
- Use Datasets and data-aware scheduling for cross-DAG dependencies instead of `ExternalTaskSensor`.
