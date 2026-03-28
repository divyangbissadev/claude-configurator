---
description: Sprint analytics — time per story, velocity estimate, burndown data.
---

# JIRA Sprint Report

Analyze time spent during a sprint across all tickets.

## Steps

### 1. Gather Data

Read from `.claude/jira/time-log.csv` and optionally query JIRA API for sprint details.

### 2. Sprint Time Breakdown

```markdown
## Sprint Report

### Time by Story
| Ticket | Summary | Status | Time Spent | Sessions |
|--------|---------|--------|------------|----------|
| PR-557 | Ottava case ingest pipeline | Done | 32h 15m | 45 |
| PR-558 | Schema guard | In Progress | 8h 30m | 12 |
| PR-560 | PostgreSQL writer | To Do | 0h 00m | 0 |

### Time by Day
| Date | Mon | Tue | Wed | Thu | Fri |
|------|-----|-----|-----|-----|-----|
| Hours | 4.5 | 6.0 | 5.5 | 7.0 | 3.0 |
| Sessions | 8 | 10 | 9 | 12 | 5 |

### Velocity Insights
- Total sprint hours: 26h 00m
- Stories completed: 3/5
- Avg hours per story: 8h 40m
- Avg session duration: 35m
- Most productive day: Thursday (7h)

### Unlinked Time
- 3h 30m across 8 sessions not attributed to any ticket
- Consider running /jira-link at session start
```

### 3. JIRA API Integration (optional)

If `$JIRA_EMAIL`, `$JIRA_TOKEN`, and `$JIRA_HOST` are set:
- Fetch sprint board for story summaries and statuses
- Log time directly to JIRA via worklog API:

```bash
curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
  -X POST "https://$JIRA_HOST/rest/api/3/issue/<TICKET>/worklog" \
  -H "Content-Type: application/json" \
  -d '{
    "timeSpentSeconds": <seconds>,
    "comment": "Claude Code session: <session_id>",
    "started": "<timestamp>"
  }'
```
