# Terraform Testing Rules

## Terratest (Go)
- Write integration tests that deploy real infrastructure, validate, and destroy
- Use `terraform.InitAndApply` and `terraform.Destroy` with `defer` for cleanup
- Set reasonable timeouts: `go test -timeout 30m` (infrastructure takes time)
- Use `terraform.OutputRequired` to validate outputs exist and are correct
- Test each example in the `examples/` directory
- Use `t.Parallel()` for independent test cases to reduce total test time
- Store test fixtures in `tests/fixtures/` for reusable test data

## terraform-compliance (BDD)
- Write feature files in Gherkin syntax against plan JSON output
- Organize features by domain: `compliance/networking.feature`, `compliance/encryption.feature`
- Test both positive (must have) and negative (must not have) conditions
- Run with `terraform-compliance -p plan.json -f compliance/`

## Plan Validation
- Run `terraform plan -detailed-exitcode` in CI for every pull request
- Exit code 0: success (no changes), 2: success (changes present), 1: failure
- Use `terraform plan -json` for machine-parseable output in automation
- Validate all examples with `terraform init -backend=false && terraform validate`

## Test Organization
- Unit tests: validate variable defaults, locals computation, output values
- Integration tests: deploy and validate real infrastructure (Terratest)
- Policy tests: validate compliance against plan output (terraform-compliance, conftest)
- Smoke tests: minimal deployment to verify core functionality after module changes

## CI Pipeline Integration
- Run `terraform fmt -check` as the first step (fast fail)
- Run `terraform validate` after init
- Run security scans (tfsec, checkov) before plan
- Run `terraform plan` and save output for review
- Run policy tests against saved plan
- Run integration tests on merge to main (not on every PR due to cost)
