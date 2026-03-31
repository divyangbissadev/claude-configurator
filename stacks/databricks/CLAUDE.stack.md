# Databricks Stack

Critical anti-patterns and rules for Databricks platform development:

## Delta Lake Anti-Patterns

- **No `write_mode="append"` for fact tables** — always use MERGE for idempotency; append-only creates duplicates on retries
- **No schema inference** — define `StructType` schemas explicitly; `inferSchema` causes extra read passes and type instability
- **No `overwrite` without partition predicates** — use `replaceWhere` to avoid wiping entire tables
- **No small file problem** — always run `OPTIMIZE` after batch writes; enable auto-compaction (`delta.autoOptimize.optimizeWrite = true`)
- **No skipping VACUUM** — schedule `VACUUM` with retention >= 7 days; stale files waste storage and slow reads
- **No ignoring Z-ORDER** — Z-order on high-cardinality filter columns; use liquid clustering for new tables on Delta Lake 3.0+

## Delta Live Tables (DLT) Anti-Patterns

- **No manual retry logic in DLT** — the DLT runtime handles retries; adding your own causes double-processing
- **No `try/except` for data quality** — use DLT expectations (`@dlt.expect`, `@dlt.expect_or_drop`, `@dlt.expect_or_fail`)
- **No mixing DLT and non-DLT writes** — DLT manages its own checkpoints; external writes corrupt pipeline state
- **No hardcoded paths in DLT** — use `spark.conf.get()` or pipeline parameters for environment-specific values
- **No skipping expectations** — every DLT table MUST have at least one data quality expectation defined

## Unity Catalog Rules

- **Always use 3-level namespace** — `catalog.schema.table`; never reference tables without full qualification
- **Grants over direct storage access** — use `GRANT SELECT ON` instead of mounting storage or using direct paths
- **No `CREATE TABLE LOCATION`** — let Unity Catalog manage table locations; external tables only for legacy migration
- **No service principal tokens in code** — use Unity Catalog identity federation and managed credentials
- **Audit all privilege escalations** — review `GRANT` statements in code review; no `ALL PRIVILEGES` except for catalog admins

## Workflow Anti-Patterns

- **No hardcoded cluster IDs** — use job clusters defined inline or via cluster policies
- **No all-purpose clusters for jobs** — always use job clusters; they auto-terminate and cost less
- **No missing retry policies** — configure `max_retries` and `retry_on_timeout` for production jobs
- **No monolithic single-task jobs** — decompose into multi-task DAGs with proper dependencies
- **No hardcoded parameters** — use `dbutils.widgets` or job parameters with `{{job.parameters}}`

## MLflow Rules

- **Always log params, metrics, and artifacts** — every training run must call `mlflow.log_param()`, `mlflow.log_metric()`, `mlflow.log_artifact()`
- **Always use Model Registry** — never deploy models from local paths; register in Unity Catalog Model Registry
- **Always log the model signature** — use `mlflow.models.infer_signature()` or define `ModelSignature` explicitly
- **Tag experiments and runs** — use tags for team, project, and environment for discoverability
- **No training without experiment tracking** — set `mlflow.set_experiment()` before any training code

## Compute Rules

- **Serverless preferred** — use serverless compute for jobs and SQL warehouses unless specific libraries require custom images
- **Autoscaling enabled** — set `min_workers` and `max_workers`; never use fixed-size clusters in production
- **Spot instances for non-critical** — use spot/preemptible instances for development and non-SLA workloads
- **No oversized drivers** — driver should match worker instance type unless running `collect()` operations
- **Cluster policies enforced** — all clusters must comply with workspace cluster policies

## SQL Warehouse Rules

- **Serverless warehouse for BI** — use serverless SQL warehouses for dashboards and ad-hoc queries
- **No classic warehouses for ad-hoc** — classic warehouses have cold start delays; serverless scales instantly
- **Query tagging required** — all queries must include `/* team:x, pipeline:y */` comment headers for cost attribution
- **No `SELECT *` in production views** — always project specific columns for performance and governance
