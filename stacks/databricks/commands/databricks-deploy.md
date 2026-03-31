---
description: Deploy to Databricks — bundle, deploy jobs, DLT pipelines, notebooks, and promote MLflow models.
---

# Databricks Deploy

## Steps

### 1. Validate Bundle Configuration

```bash
echo "=== Validating Databricks Asset Bundle ==="
databricks bundle validate 2>&1
```

### 2. Run Tests Before Deploy

```bash
echo "=== Running tests ==="
python3 -m pytest tests/ -v --no-cov 2>&1 | tail -30
if [ $? -ne 0 ]; then
  echo "FAIL: Tests did not pass. Aborting deploy."
  exit 1
fi
```

### 3. Deploy Bundle

Deploy jobs, DLT pipelines, and notebooks using Databricks Asset Bundles:

```bash
echo "=== Deploying bundle to target environment ==="
databricks bundle deploy --target "${DEPLOY_TARGET:-development}" 2>&1
```

### 4. Deploy DLT Pipelines

If DLT pipelines are defined, trigger an update:

```bash
echo "=== Checking for DLT pipeline deployments ==="
databricks bundle run --target "${DEPLOY_TARGET:-development}" 2>&1 | head -20
```

### 5. Promote MLflow Models

If model promotion is requested, transition model alias:

```bash
echo "=== Model promotion (if applicable) ==="
# List registered models
databricks unity-catalog models list --catalog-name "${CATALOG:-production}" --schema-name "${SCHEMA:-ml}" 2>&1 | head -20
```

For model promotion, use the MLflow Python API:
```python
import mlflow
client = mlflow.tracking.MlflowClient()
# Set champion alias on validated model version
client.set_registered_model_alias(
    name=f"{catalog}.{schema}.{model_name}",
    alias="champion",
    version=new_version,
)
```

### 6. Post-Deploy Validation

```bash
echo "=== Verifying deployment ==="
databricks bundle summary --target "${DEPLOY_TARGET:-development}" 2>&1
echo "=== Checking job status ==="
databricks jobs list --output TABLE 2>&1 | head -20
```

### 7. Notify

Report deployment status including:
- Bundle target environment
- Jobs deployed/updated
- DLT pipelines deployed/updated
- Models promoted (if any)
- Any warnings or errors encountered
