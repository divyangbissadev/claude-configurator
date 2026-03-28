---
description: Search across all agent memories for a specific topic, pattern, or keyword.
---

# Memory Search

Search all agent memory files for relevant context.

## Steps

### 1. Get Search Query

What are you looking for? (keyword, file path, concept, pattern)

### 2. Search All Memory Files

```bash
grep -rn "<query>" .claude/agent-memory/ --include="*.md"
```

### 3. Present Results

Group by agent, show the full entry for each match with context.

```markdown
## Memory Search: "[query]"

### code-reviewer (2 matches)
- [Pattern] N+1 query in UserService — 2026-03-15
  **Insight**: ...

### debugger (1 match)
- [Issue] Flaky auth test — 2026-03-20
  **Insight**: ...
```
