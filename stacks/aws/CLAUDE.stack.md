# AWS Stack Anti-Patterns and Guidelines

## Anti-Patterns — Never Do These

- No hardcoded AWS credentials — use IAM roles, SSO, or environment variables instead
- No `*` in IAM policies — always follow least privilege principle
- No public S3 buckets without explicit justification documented in code comments
- No Lambda functions without a dead letter queue (DLQ) configured
- No ECS tasks without health checks defined
- No CloudFormation stacks without drift detection enabled
- No security groups with `0.0.0.0/0` inbound rules

## Required Practices

- Always tag all resources with: `team`, `environment`, `cost-center`
- Always encrypt data at rest and in transit
- Use KMS customer-managed keys for sensitive workloads
- Enable CloudTrail logging for all accounts
- Enable VPC Flow Logs for network visibility
- Use AWS Config rules for continuous compliance monitoring
