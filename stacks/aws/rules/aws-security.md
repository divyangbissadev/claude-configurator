# AWS Security Rules

## IAM
- Never use wildcard (`*`) actions or resources in IAM policies
- Always attach permission boundaries to roles created by delegated administrators
- Use SCP guardrails at the organization level to prevent dangerous actions
- Require MFA for all human IAM users and console access
- Rotate access keys every 90 days; prefer IAM roles over long-lived keys

## Encryption
- Encrypt all data at rest using KMS (customer-managed keys for sensitive workloads)
- Enforce TLS 1.2 minimum for all data in transit
- Enable default encryption on S3 buckets, EBS volumes, RDS instances, and DynamoDB tables
- Use separate KMS keys per environment and per service domain
- Enable automatic key rotation for all symmetric KMS keys

## Networking
- No security groups with 0.0.0.0/0 inbound rules unless explicitly justified and documented
- Use VPC endpoints (Gateway and Interface) for AWS service access to avoid public internet
- Place databases and internal services in private subnets only
- Enable VPC Flow Logs on all VPCs and subnets
- Use AWS Network Firewall or third-party appliances for advanced traffic inspection

## Secrets
- Store all secrets in Secrets Manager or Parameter Store (SecureString)
- Never hardcode credentials, API keys, or tokens in source code or environment variables
- Enable automatic rotation for database credentials via Secrets Manager
- Use IAM roles for service-to-service authentication within AWS

## Logging and Monitoring
- Enable CloudTrail in all regions with log file validation
- Send all logs to a centralized logging account
- Enable GuardDuty in all accounts and regions
- Configure Security Hub with CIS AWS Foundations Benchmark
- Set up CloudWatch alarms for security-relevant metrics
