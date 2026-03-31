---
description: Review Terraform plan output — parse JSON plan, highlight changes, flag dangerous operations, and estimate cost impact
---

# Terraform Plan Review

Review and analyze Terraform plan output for safety and cost.

## Steps

1. **Generate Plan**
   - Run `terraform plan -out=tfplan` to create a saved plan
   - Run `terraform show -json tfplan` to produce JSON output for analysis

2. **Parse Changes**
   - Categorize all resource changes: create, update, destroy, replace
   - List each changed resource with its address and change type
   - Show attribute-level diffs for updates

3. **Flag Dangerous Operations**
   - CRITICAL: Any resource with `destroy` action (especially databases, S3 buckets, state stores)
   - HIGH: Any resource with `replace` action (forces recreation)
   - MEDIUM: Updates to security-sensitive resources (IAM, security groups, encryption)
   - Verify `prevent_destroy` lifecycle rules are in place for stateful resources
   - Check for `count` index shifts causing unintended destroys

4. **Cost Impact Estimation**
   - Run `infracost breakdown --path tfplan` for cost analysis
   - Run `infracost diff --path tfplan` to compare against baseline
   - Highlight cost increases exceeding thresholds
   - Summarize monthly cost delta

5. **Output Summary**
   - Total resources: created, updated, destroyed, replaced, unchanged
   - Danger flags with severity and recommended actions
   - Cost impact summary
   - Go/no-go recommendation
