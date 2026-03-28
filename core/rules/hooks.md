---
paths:
  - .claude/hooks/**/*
---

# Hooks Conventions

- Hooks must be fast — they run synchronously and block the session
- Hooks must be idempotent — running twice should produce the same result
- Hooks must be silent on success — only output on failure or important warnings
- Never modify code in hooks — hooks are for validation and context, not implementation
- Test hooks in isolation before enabling in settings
