# AWS Cost Governance Rules

## Tagging
- All resources must have these tags: `team`, `environment`, `cost-center`
- Use AWS Config rules to detect and flag untagged resources
- Tag values must follow consistent formatting (lowercase, hyphen-separated)
- Add `managed-by` tag to indicate IaC tool (cdk, cloudformation, terraform)

## Right-Sizing
- Review EC2 instance utilization monthly; downsize instances below 40% average CPU
- Use Graviton (ARM) instances where supported for better price-performance
- Set Lambda memory based on profiling, not defaults
- Use auto-scaling for variable workloads instead of provisioning for peak
- Prefer Fargate Spot for fault-tolerant batch workloads

## Reserved Capacity
- Purchase Reserved Instances or Savings Plans for steady-state workloads running 24/7
- Review RI/SP utilization monthly; modify or exchange underutilized reservations
- Use Convertible RIs for workloads where instance type may change
- Evaluate Compute Savings Plans for cross-service flexibility

## Storage
- Implement S3 lifecycle policies to transition data to cheaper tiers (IA, Glacier)
- Delete unused EBS snapshots and unattached EBS volumes
- Use S3 Intelligent-Tiering for unpredictable access patterns
- Set expiration policies for CloudWatch log groups
- Use GP3 over GP2 for EBS volumes (better price-performance)

## Data Transfer
- Minimize cross-region data transfer; replicate only what is necessary
- Use VPC endpoints to avoid NAT Gateway data processing charges
- Use CloudFront for content delivery to reduce origin egress
- Consolidate workloads in fewer AZs when HA requirements allow
