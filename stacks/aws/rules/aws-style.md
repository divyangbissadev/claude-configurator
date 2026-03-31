# AWS Style Rules

## CDK Conventions
- Use L2 constructs over L1 (Cfn*) unless L2 is unavailable
- Name constructs with PascalCase: `MyApiGateway`, `UserTable`
- Organize stacks by lifecycle: stateful (databases, S3) separate from stateless (Lambda, API Gateway)
- Use CDK Aspects for cross-cutting concerns (tagging, encryption enforcement)
- Export only values needed by other stacks; prefer SSM Parameter Store for cross-stack references

## CloudFormation Conventions
- Use YAML over JSON for readability
- Logical resource IDs in PascalCase: `ProductionVpc`, `ApiLambdaFunction`
- Use `!Ref`, `!GetAtt`, `!Sub` over `Fn::Ref`, `Fn::GetAtt`, `Fn::Sub`
- Group resources by service in template sections
- Add `DeletionPolicy: Retain` for stateful resources (databases, S3 buckets)

## Naming Conventions
- S3 buckets: `{company}-{env}-{service}-{purpose}` (e.g., `acme-prod-api-uploads`)
- Lambda functions: `{service}-{action}-{env}` (e.g., `orders-process-prod`)
- IAM roles: `{service}-{purpose}-role` (e.g., `lambda-orders-execution-role`)
- Security groups: `{service}-{tier}-sg` (e.g., `api-web-sg`, `db-data-sg`)
- Tags use lowercase with hyphens: `cost-center`, `managed-by`

## Code Organization
- One stack per file, one construct per file for complex constructs
- Shared configuration in a `config/` directory
- Environment-specific values in `cdk.json` context or Parameter Store
- Keep Lambda handler files in a `lambda/` or `functions/` directory
