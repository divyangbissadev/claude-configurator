# Terraform Stack Anti-Patterns and Guidelines

## Anti-Patterns — Never Do These

- No hardcoded provider credentials in Terraform files
- No local state — always use a remote backend (S3, GCS, Azure Blob, Terraform Cloud)
- No `terraform apply` without reviewing the plan output first
- No modules without `variables.tf`, `outputs.tf`, and `versions.tf`
- No `count` for conditional resources — use `for_each` instead for stable resource addresses
- No inline blocks when separate resources provide clearer intent and manageability

## Required Practices

- Always pin provider versions with pessimistic constraint (`~>`)
- Always use workspaces or separate state files per environment
- Always run `terraform fmt` and `terraform validate` before committing
- Always include a `README.md` in every module with usage examples
- Lock state files during operations to prevent concurrent modifications
- Use `moved` blocks for refactoring instead of destroy/recreate
