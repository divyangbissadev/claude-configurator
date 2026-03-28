---
description: Show agent memory status — which agents have memories, entry counts, staleness.
---

# Memory Status

Show the state of agent memory for this project.

## Steps

### 1. Scan Memory Directory

```bash
find .claude/agent-memory -name "MEMORY.md" -type f 2>/dev/null
```

### 2. For Each Memory File

Count entries (lines starting with `###`), check last modified date, identify stale entries (older than 30 days with no `Expires: Never`).

### 3. Report

```markdown
## Agent Memory Status

| Agent | Entries | Last Updated | Stale |
|-------|---------|-------------|-------|
| shared | X | YYYY-MM-DD | X |
| code-reviewer | X | YYYY-MM-DD | X |
| debugger | X | YYYY-MM-DD | X |
| ... | | | |

**Total entries**: X across Y agents
**Stale entries**: X (consider running /memory-prune)
**Memory size**: X KB
```
