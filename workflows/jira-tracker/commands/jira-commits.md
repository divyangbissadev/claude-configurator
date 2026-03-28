---
description: Show commits linked to JIRA tickets with time correlation.
---

# JIRA Commits

Show git commits linked to JIRA tickets, correlated with session time.

## Steps

### 1. Parse Git Log

```bash
git log --oneline --since="2 weeks ago" | grep -oP '[A-Z]+-[0-9]+'
```

### 2. Correlate with Time Log

For each ticket found in commits, look up total time from `.claude/jira/time-log.csv`.

### 3. Report

```markdown
## Commits by Ticket

### PR-557 (Total time: 32h 15m)
| Date | Commit | Message |
|------|--------|---------|
| 2026-03-28 | abc1234 | PR-557: Add schema guard validation |
| 2026-03-27 | def5678 | PR-557: Fix merge key format |
| ... | | |
**Commits**: 12 | **Avg time between commits**: 2h 41m

### PR-558 (Total time: 8h 30m)
| Date | Commit | Message |
|------|--------|---------|
| 2026-03-28 | ghi9012 | PR-558: Add PostgresWriter with upsert |
**Commits**: 5 | **Avg time between commits**: 1h 42m

### Unlinked Commits
| Date | Commit | Message |
|------|--------|---------|
| 2026-03-26 | jkl3456 | fix: datetime compatible imports |
```
