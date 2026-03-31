---
description: Validate Terraform code — fmt check, validate, tfsec/Checkov scan, and dry-run plan
---

# Validate Terraform

Run comprehensive validation on Terraform configurations.

## Steps

1. **Format Check**
   - Run `terraform fmt -check -recursive` on the project root
   - Report any files that are not properly formatted
   - Optionally auto-fix with `terraform fmt -recursive`

2. **Terraform Validate**
   - Run `terraform init -backend=false` to initialize providers without backend
   - Run `terraform validate` to check configuration syntax and internal consistency
   - Report any validation errors with file and line references

3. **Security Scan**
   - Run `tfsec .` to detect security misconfigurations
   - Run `checkov -d .` for additional policy checks
   - Categorize findings by severity: CRITICAL, HIGH, MEDIUM, LOW
   - Flag any CRITICAL or HIGH findings as blocking

4. **Dry-Run Plan**
   - Run `terraform plan -detailed-exitcode` to verify the configuration plans successfully
   - Exit code 0: no changes, exit code 2: changes present, exit code 1: error
   - Report any planning errors

Report all findings with severity levels and actionable remediation guidance.
