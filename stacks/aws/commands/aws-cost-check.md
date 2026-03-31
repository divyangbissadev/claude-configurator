---
description: Estimate AWS costs — Infracost analysis, right-sizing recommendations, and Reserved/Savings Plans evaluation
---

# AWS Cost Check

Estimate and optimize costs for AWS infrastructure.

## Steps

1. **Infracost Analysis**
   - Run `infracost breakdown` on CDK/CloudFormation templates
   - Compare with `infracost diff` against the current baseline
   - Highlight the top cost drivers
   - Flag any resources exceeding cost thresholds

2. **Right-Sizing Recommendations**
   - Analyze EC2 instance types against workload requirements
   - Check RDS instance sizing versus actual utilization patterns
   - Review Lambda memory configuration (use Power Tuning results if available)
   - Identify over-provisioned resources

3. **Reserved / Savings Plans Analysis**
   - Calculate potential savings with Reserved Instances (1-year, 3-year)
   - Evaluate Savings Plans coverage and utilization
   - Recommend commitment levels based on steady-state usage
   - Identify on-demand resources suitable for spot or reserved

4. **Output**
   - Monthly cost estimate with breakdown by service
   - Optimization recommendations ranked by savings potential
   - Comparison table: current vs optimized costs
