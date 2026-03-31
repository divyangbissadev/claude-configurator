# Airflow Style Conventions

## DAG File Structure
1. License header (if applicable).
2. Standard library imports.
3. Third-party imports.
4. Airflow imports.
5. Constants and default_args.
6. DAG definition using `with DAG(...)` context manager.
7. Task definitions inside the context manager.
8. Task dependencies at the end of the context manager.

## DAG Configuration
- Use `dag_id` that matches the filename (without `.py` extension).
- Set `tags` for categorization and filtering in the UI.
- Set `owner` in `default_args` to the responsible team.
- Use `doc_md` for DAG-level documentation visible in the UI.
- Always set `start_date` as a static, timezone-aware datetime.

## Task Naming
- Use snake_case for task IDs.
- Use descriptive names that convey the action: `extract_orders`, `transform_data`, `load_to_warehouse`.
- Prefix with the stage for ETL DAGs: `extract_`, `transform_`, `load_`.

## TaskFlow API
- Prefer `@task` decorator over `PythonOperator`.
- Return values from `@task` functions for implicit XCom.
- Use type hints on `@task` function signatures.
- Keep `@task` functions pure — no side effects beyond the intended operation.

## Dependencies
- Use `>>` and `<<` operators for task dependencies.
- Use `chain()` for linear sequences, `cross_downstream()` for many-to-many.
- Avoid deeply nested dependency chains — refactor into task groups.

## Task Groups
- Use `@task_group` decorator for logical grouping of related tasks.
- Name task groups descriptively: `process_payments`, `validate_inputs`.
