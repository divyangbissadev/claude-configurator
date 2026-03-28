---
description: Run the full CI quality gate — lint, type check, tests, and security scan.
---

# CI Quality Gate

Run all quality checks before committing or creating a PR.

## Steps

1. **Lint**: Run the project's lint command
2. **Type Check**: Run the project's type checker (if configured)
3. **Tests**: Run the full test suite with coverage
4. **Security**: Run security scanning tools (if configured)
5. **Summary**: Report pass/fail for each check with a final verdict
