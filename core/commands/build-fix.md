---
description: Diagnose and fix build errors with minimal changes — no refactoring, no architecture changes.
---

# Build Fix

## Steps

1. **Collect errors**: Run the project's build/lint/type-check commands, capture all errors
2. **Categorize**: Group by type (import, type, dependency, config)
3. **Fix in order**: Resolve import errors first, then types, then deps
4. **Verify**: Run build again — confirm zero errors and tests still pass
5. **Commit**: Minimal fix only — no unrelated changes
