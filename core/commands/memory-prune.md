---
description: Clean up stale, contradicted, or obsolete agent memory entries.
---

# Memory Prune

Remove outdated entries from agent memory files.

## Steps

### 1. Scan All Memory Files

Read every MEMORY.md in `.claude/agent-memory/`.

### 2. Identify Candidates for Removal

- **Expired**: Entries with `Expires: YYYY-MM-DD` where the date has passed
- **Stale**: Entries older than 90 days with `Confidence: Low`
- **Orphaned**: Entries referencing files that no longer exist (check with `ls`)
- **Contradicted**: Entries where a newer entry on the same topic exists

### 3. Review and Remove

For each candidate:
- Show the entry
- Explain why it's a candidate for removal
- Remove if clearly stale, ask if ambiguous

### 4. Report

```markdown
## Memory Prune Report

- Expired entries removed: X
- Stale entries removed: X
- Orphaned entries removed: X
- Contradicted entries removed: X
- Entries retained: X
```
