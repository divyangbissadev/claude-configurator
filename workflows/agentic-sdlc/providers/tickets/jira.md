---
name: jira
description: Jira ticket provider using the Jira REST API for project management, sprints, and issue tracking
---

# Jira Provider

## Provider Overview

Jira is Atlassian's project management and issue tracking platform. This provider uses the Jira REST API v3 and Agile REST API to manage sprints, issues, transitions, and comments. Authentication uses API tokens with basic auth.

## CLI/API Tool

- **Tool**: `curl` against Jira REST API
- **API Base**: `https://{host}/rest/api/3/` (issue operations) and `https://{host}/rest/agile/1.0/` (sprint/board operations)
- **Documentation**: https://developer.atlassian.com/cloud/jira/platform/rest/v3/
- **Atlassian Plugin**: If the Atlassian MCP plugin is available, the following skills can be used:
  - `/spec-to-backlog` -- Convert a Confluence spec into a structured Jira backlog with Epics and tickets
  - `/triage-issue` -- Search for duplicate issues and intelligently triage bug reports

## Required Configuration

| Variable | Description |
|---|---|
| `JIRA_HOST` | Jira instance hostname (e.g., `mycompany.atlassian.net`) |
| `JIRA_EMAIL` | Email address associated with the Jira account |
| `JIRA_TOKEN` | Jira API token (generate at https://id.atlassian.com/manage-profile/security/api-tokens) |
| `JIRA_PROJECT_KEY` | Default project key (e.g., `PROJ`) |
| `JIRA_BOARD_ID` | Agile board ID for sprint operations |

All `curl` commands must include the authentication header:

```bash
-u "{JIRA_EMAIL}:{JIRA_TOKEN}" \
-H "Content-Type: application/json"
```

## Sprint Mapping

Jira has native sprint support through Scrum boards:

| SDLC Concept | Jira Concept |
|---|---|
| Sprint / Iteration | Sprint (on a Scrum board) |
| Sprint Name | Sprint name |
| Sprint Start Date | Sprint `startDate` |
| Sprint End Date | Sprint `endDate` |
| Sprint Backlog | Issues in the sprint |

## Status Mapping

| SDLC Status | Jira Status | Notes |
|---|---|---|
| TODO | `To Do` | Default status for new issues |
| IN-PROGRESS | `In Progress` | Transitioned via workflow |
| DONE | `Done` | Transitioned via workflow |

Status changes require transitions. Use the "Get Transitions" endpoint to discover available transition IDs for a given issue.

## Sprint/Iteration Operations

### Create Sprint

```bash
curl -X POST "https://{host}/rest/agile/1.0/sprint" \
  -u "{JIRA_EMAIL}:{JIRA_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "{name}",
    "startDate": "{start}",
    "endDate": "{end}",
    "originBoardId": {board_id},
    "goal": "{goal}"
  }'
```

- Dates in ISO 8601 format: `YYYY-MM-DDTHH:MM:SS.000Z`

### List Sprints

```bash
curl "https://{host}/rest/agile/1.0/board/{board_id}/sprint?state=active,future" \
  -u "{JIRA_EMAIL}:{JIRA_TOKEN}" \
  -H "Content-Type: application/json"
```

### Close Sprint

Sprints are closed by updating their state to `closed`:

```bash
curl -X POST "https://{host}/rest/agile/1.0/sprint/{sprint_id}" \
  -u "{JIRA_EMAIL}:{JIRA_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "state": "closed"
  }'
```

## Issue/Ticket Operations

### Create Issue

```bash
curl -X POST "https://{host}/rest/api/3/issue" \
  -u "{JIRA_EMAIL}:{JIRA_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "{project}"},
      "summary": "{title}",
      "description": {
        "type": "doc",
        "version": 1,
        "content": [
          {
            "type": "paragraph",
            "content": [
              {"type": "text", "text": "{body}"}
            ]
          }
        ]
      },
      "issuetype": {"name": "{type}"},
      "labels": ["{label}"],
      "assignee": {"accountId": "{account_id}"}
    }
  }'
```

- `{type}` is typically `Story`, `Task`, `Bug`, or `Epic`

### Read Issue

```bash
curl "https://{host}/rest/api/3/issue/{key}" \
  -u "{JIRA_EMAIL}:{JIRA_TOKEN}" \
  -H "Content-Type: application/json"
```

### List Issues in Sprint

```bash
curl "https://{host}/rest/agile/1.0/sprint/{sprint_id}/issue" \
  -u "{JIRA_EMAIL}:{JIRA_TOKEN}" \
  -H "Content-Type: application/json"
```

### List Issues by JQL

```bash
curl -G "https://{host}/rest/api/3/search" \
  --data-urlencode "jql=project={project} AND sprint={sprint_id} AND status!=Done" \
  -u "{JIRA_EMAIL}:{JIRA_TOKEN}" \
  -H "Content-Type: application/json"
```

### Update Issue

```bash
curl -X PUT "https://{host}/rest/api/3/issue/{key}" \
  -u "{JIRA_EMAIL}:{JIRA_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "summary": "{new_title}",
      "labels": ["{label1}", "{label2}"]
    }
  }'
```

### Transition Issue (Change Status)

First, get available transitions:

```bash
curl "https://{host}/rest/api/3/issue/{key}/transitions" \
  -u "{JIRA_EMAIL}:{JIRA_TOKEN}" \
  -H "Content-Type: application/json"
```

Then apply the transition:

```bash
curl -X POST "https://{host}/rest/api/3/issue/{key}/transitions" \
  -u "{JIRA_EMAIL}:{JIRA_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "transition": {"id": "{transition_id}"}
  }'
```

### Comment on Issue

```bash
curl -X POST "https://{host}/rest/api/3/issue/{key}/comment" \
  -u "{JIRA_EMAIL}:{JIRA_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "body": {
      "type": "doc",
      "version": 1,
      "content": [
        {
          "type": "paragraph",
          "content": [
            {"type": "text", "text": "{comment}"}
          ]
        }
      ]
    }
  }'
```

### Label Operations

Add labels to an issue (via update):

```bash
curl -X PUT "https://{host}/rest/api/3/issue/{key}" \
  -u "{JIRA_EMAIL}:{JIRA_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "update": {
      "labels": [{"add": "{label}"}]
    }
  }'
```

Remove a label:

```bash
curl -X PUT "https://{host}/rest/api/3/issue/{key}" \
  -u "{JIRA_EMAIL}:{JIRA_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "update": {
      "labels": [{"remove": "{label}"}]
    }
  }'
```
