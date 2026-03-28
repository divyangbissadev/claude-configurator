---
description: Link the current session to a JIRA ticket for time tracking.
---

# JIRA Link

Link this Claude Code session to a JIRA ticket so time is tracked against it.

## Steps

### 1. Get Ticket ID

If not provided as argument, ask: "Which JIRA ticket are you working on? (e.g., PR-557)"

### 2. Validate Format

Ticket must match pattern: `[A-Z]+-[0-9]+` (e.g., PR-557, PLAT-123, DATA-42)

### 3. Save Link

Write the ticket ID to `.claude/jira/.current-ticket`:
```bash
echo "<TICKET_ID>" > .claude/jira/.current-ticket
```

### 4. Confirm

```
Session linked to <TICKET_ID>.
Time will be logged against this ticket when the session ends.
```

### 5. Optional: Fetch Ticket Details

If JIRA API credentials are available (`$JIRA_EMAIL` and `$JIRA_TOKEN`):
```bash
curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" \
  "https://<jira-host>/rest/api/3/issue/<TICKET_ID>?fields=summary,status,assignee" \
  -H "Content-Type: application/json"
```

Show: ticket summary, status, assignee.
