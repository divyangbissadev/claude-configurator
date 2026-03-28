---
description: Run the project's quality gate — lint, type check, tests, security scan.
---

# Validate

Run the full quality gate for this project.

## Steps

### 1. Read project config

Check CLAUDE.md for the project's lint, test, and CI commands.

### 2. Run lint

Execute the project's lint command. Report pass/fail with violation count.

### 3. Run tests

Execute the project's test command. Report pass/fail with test counts.

### 4. Run CI gate

If the project has a combined CI command, run it. Otherwise run lint + tests.

### 5. Summary

| Check   | Status    | Details         |
|---------|-----------|-----------------|
| Lint    | PASS/FAIL | X violations    |
| Tests   | PASS/FAIL | X passed, Y failed |
| Overall | READY / NEEDS FIXES |         |
