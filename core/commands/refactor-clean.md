---
description: Find and remove dead code, unused imports, duplicate logic, and unused dependencies.
---

# Refactor Clean

## Steps

1. **Detect**: Search for unused functions, imports, exports, and dependencies
2. **Categorize by risk**: SAFE (no references), CAREFUL (dynamic usage possible), RISKY (public API)
3. **Remove SAFE items first**: One category at a time (deps → imports → functions → files)
4. **Test after each batch**: Build + tests must pass
5. **Consolidate duplicates**: Choose best implementation, update all references
6. **Commit per batch**: Descriptive message per removal category
