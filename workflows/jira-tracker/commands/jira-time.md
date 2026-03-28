---
description: Show time spent per JIRA ticket — today, this week, or all time.
---

# JIRA Time Report

Show time tracked against JIRA tickets.

## Steps

### 1. Read Time Log

Parse `.claude/jira/time-log.csv` (project-level) or `~/.claude/jira/global-time-log.csv` (cross-project).

### 2. Generate Report

```markdown
## Time Report — [project name]

### Today (YYYY-MM-DD)
| Ticket | Sessions | Total Time | Branch |
|--------|----------|------------|--------|
| PR-557 | 3 | 2h 15m | feature/ottava-ingest |
| PR-558 | 1 | 0h 45m | feature/schema-guard |
| unlinked | 2 | 0h 30m | main |
| **Total** | **6** | **3h 30m** | |

### This Week
| Ticket | Sessions | Total Time |
|--------|----------|------------|
| PR-557 | 12 | 8h 30m |
| PR-558 | 5 | 3h 15m |
| PR-560 | 3 | 2h 00m |
| unlinked | 4 | 1h 00m |
| **Total** | **24** | **14h 45m** |

### All Time (top 10 tickets)
| Ticket | Sessions | Total Time | First Seen | Last Active |
|--------|----------|------------|------------|-------------|
| PR-557 | 45 | 32h 15m | 2026-03-01 | 2026-03-28 |
| ... | | | | |
```

### 3. Insights

- Average session duration per ticket
- Tickets with most time invested
- Unlinked sessions (time not attributed to any ticket)
- Sessions per day trend
