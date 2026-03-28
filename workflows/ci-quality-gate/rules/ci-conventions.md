---
paths:
  - "**/*"
---

# CI Quality Gate Conventions

- All checks must pass before merging to main
- Coverage must meet the minimum threshold defined in project vars
- Security findings rated "High" or above block merge
- Lint auto-fix is acceptable for formatting; manual fix required for logic issues
