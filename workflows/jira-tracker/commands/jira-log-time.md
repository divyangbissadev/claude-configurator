---
description: Push tracked time to JIRA as worklogs via the JIRA REST API.
---

# JIRA Log Time

Push locally tracked time to JIRA as official worklogs.

## Prerequisites

Set these environment variables:
- `JIRA_HOST` — your JIRA instance (e.g., `myorg.atlassian.net`)
- `JIRA_EMAIL` — your JIRA email
- `JIRA_TOKEN` — your JIRA API token

## Steps

### 1. Read Unsynced Time

Parse `.claude/jira/time-log.csv` for entries not yet synced.
Check `.claude/jira/synced-entries.txt` for already-pushed session IDs.

### 2. Group by Ticket

Aggregate time per ticket per day (JIRA expects one worklog per day per ticket).

### 3. Push to JIRA

For each ticket+day combination:
```bash
curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
  -X POST "https://$JIRA_HOST/rest/api/3/issue/<TICKET>/worklog" \
  -H "Content-Type: application/json" \
  -d '{
    "timeSpentSeconds": <total_seconds>,
    "comment": "Claude Code: <N> sessions on <date>",
    "started": "<date>T09:00:00.000+0000"
  }'
```

### 4. Mark as Synced

Append pushed session IDs to `.claude/jira/synced-entries.txt`.

### 5. Report

```
JIRA Time Sync Complete:
  PR-557: 2h 15m logged for 2026-03-28
  PR-558: 0h 45m logged for 2026-03-28
  Skipped: 3 sessions (unlinked — no ticket)
```
