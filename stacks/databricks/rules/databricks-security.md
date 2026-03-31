---
paths:
  - src/**/*.py
  - notebooks/**/*.py
  - workflows/**/*.py
  - resources/**/*.yml
  - resources/**/*.yaml
  - databricks.yml
---

# Databricks Security Rules

## Secrets Management

- NEVER hardcode tokens, passwords, connection strings, or API keys in source code
- ALWAYS use `dbutils.secrets.get(scope="scope-name", key="key-name")` for secrets
- NEVER log or print secret values — not even partially (no `secret[:4]`)
- Secret scopes MUST be backed by Azure Key Vault, AWS Secrets Manager, or GCP Secret Manager
- NEVER commit `.env` files, `credentials.json`, or files containing `dapi` tokens

## Unity Catalog Access Control

- ALWAYS use GRANT statements for access control — never mount storage directly
- NEVER use `ALL PRIVILEGES` except for catalog-level admin roles
- Follow least privilege: grant only the minimum permissions needed
- Review all GRANT statements in code review as security-critical changes
- Use row filters and column masks for sensitive data — never filter in application code alone
- External locations must use managed storage credentials — no inline keys

## Network Isolation

- Workspaces MUST use VNet injection (Azure) or VPC (AWS) for production
- Enable Private Link endpoints for control plane and data plane traffic
- Configure IP access lists to restrict workspace access to corporate networks
- Enable secure cluster connectivity (no public IPs on cluster nodes)
- Use private endpoints for storage accounts, Key Vaults, and other cloud services

## Audit and Compliance

- Enable Unity Catalog system tables: `system.access.audit`
- Monitor for privilege escalation events in audit logs
- Track data access patterns via `system.access.table_lineage`
- Retain audit logs for minimum 90 days (regulatory compliance)
- Alert on unauthorized `GRANT` or `CREATE EXTERNAL LOCATION` operations

## Compute Security

- Cluster policies MUST restrict allowed instance types, max workers, and runtime versions
- NEVER allow `spark.databricks.cluster.profile = "singleNode"` in production
- Init scripts MUST be stored in workspace or Unity Catalog volumes — no external URLs
- Disable local file system access on production clusters where possible
- Enable credential passthrough or Unity Catalog identity federation — no shared service accounts

## Code Security

- No `eval()`, `exec()`, or dynamic SQL construction from user input
- No `subprocess.call()` with `shell=True` in production code
- Validate all external inputs before passing to Spark SQL
- Pin all dependency versions in `pyproject.toml` — no unpinned ranges
- Run `pip audit` or `safety check` in CI/CD before deployment
