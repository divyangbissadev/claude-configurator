---
description: Validate AWS infrastructure code — CDK synth, CFN validate, IAM policy lint, security group audit, and tag compliance
---

# Validate AWS

Run comprehensive validation on AWS infrastructure code.

## Steps

1. **CDK Synth / CloudFormation Validate**
   - Run `cdk synth` to synthesize CloudFormation templates from CDK code
   - Run `aws cloudformation validate-template` on all CloudFormation templates
   - Report any synthesis or validation errors

2. **IAM Policy Lint**
   - Run `parliament` to lint IAM policies for common mistakes
   - Run `iamlive` in analysis mode to detect unused permissions
   - Flag any policies with wildcard (`*`) actions or resources
   - Check for missing condition keys

3. **Security Group Audit**
   - Scan all security group definitions for `0.0.0.0/0` inbound rules
   - Flag overly broad port ranges
   - Verify egress rules are scoped appropriately
   - Check for unused security groups

4. **Tag Compliance Check**
   - Verify all resources have required tags: `team`, `environment`, `cost-center`
   - Flag resources missing any required tags
   - Check for consistent tag value formatting

Report all findings with severity levels: CRITICAL, HIGH, MEDIUM, LOW.
