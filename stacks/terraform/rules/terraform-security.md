# Terraform Security Rules

## Credentials
- Never hardcode provider credentials in `.tf` files
- Use environment variables, IAM roles, or workload identity for authentication
- Mark sensitive variables with `sensitive = true`
- Never output sensitive values without `sensitive = true`
- Add `*.tfstate` and `*.tfstate.backup` to `.gitignore`

## State Security
- Always use remote backends with encryption at rest
- Enable state locking to prevent concurrent modifications
- Restrict access to state storage (S3 bucket policies, GCS IAM, Azure RBAC)
- Never store state in version control
- Use `terraform_remote_state` data source with caution — limit what is exposed

## Resource Security
- Encrypt all storage resources at rest (S3, EBS, RDS, GCS, Azure Storage)
- Enforce TLS/SSL for all network resources
- No security groups or firewall rules with `0.0.0.0/0` inbound unless explicitly justified
- Use private subnets for databases and internal services
- Enable logging on all resources that support it

## IAM and Access Control
- Follow least privilege for all IAM/RBAC configurations
- No wildcard (`*`) permissions in IAM policies
- Use separate roles per service and per environment
- Implement MFA and conditional access where supported
- Review IAM configurations with `tfsec` or `checkov`

## Secrets Management
- Use provider-specific secret stores (AWS Secrets Manager, GCP Secret Manager, Azure Key Vault)
- Reference secrets via data sources, never inline
- Rotate secrets on a defined schedule
- Audit secret access with provider logging
