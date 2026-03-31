---
name: azure-boards
description: Azure Boards ticket provider using the az boards CLI for work item tracking, iterations, and queries
---

# Azure Boards Provider

## Provider Overview

Azure Boards is the work tracking system within Azure DevOps. This provider uses the `az boards` CLI extension to manage iterations, work items, queries, and comments. Iterations serve as the sprint container, and work items support types such as Epic, Feature, User Story, Task, and Bug.

## CLI Tool

- **Tool**: `az boards` (Azure CLI with DevOps extension)
- **Documentation**: https://learn.microsoft.com/en-us/cli/azure/boards
- **Install**: `az extension add --name azure-devops`
- **Login**: `az login` then `az devops configure --defaults organization=https://dev.azure.com/{org} project={project}`

## Required Configuration

| Variable / Setting | Description |
|---|---|
| `AZURE_DEVOPS_EXT_PAT` | Personal access token for Azure DevOps (alternative to `az login`) |
| `az devops configure --defaults organization=...` | Set default organization URL |
| `az devops configure --defaults project=...` | Set default project name |

Either authenticate via `az login` or set the `AZURE_DEVOPS_EXT_PAT` environment variable with a PAT that has Work Items read/write scope.

## Sprint Mapping

Azure Boards uses Iterations as the sprint equivalent:

| SDLC Concept | Azure Boards Concept |
|---|---|
| Sprint / Iteration | Iteration (under project settings) |
| Sprint Name | Iteration name |
| Sprint Start Date | Iteration `start-date` |
| Sprint End Date | Iteration `finish-date` |
| Sprint Backlog | Work items assigned to the iteration path |

## Status Mapping

| SDLC Status | Azure Boards State | Notes |
|---|---|---|
| TODO | `New` | Default state for new work items |
| IN-PROGRESS | `Active` | Work item is being worked on |
| DONE | `Closed` | Work item is complete |

Additional states like `Resolved` may exist depending on the process template (Agile, Scrum, CMMI). For Scrum process, the mapping is:

| SDLC Status | Scrum State |
|---|---|
| TODO | `New` |
| IN-PROGRESS | `In Progress` (or `Committed`) |
| DONE | `Done` |

## Sprint/Iteration Operations

### Create Iteration

```bash
az boards iteration project create \
  --name "{name}" \
  --start-date "{start}" \
  --finish-date "{end}"
```

- Dates in `YYYY-MM-DD` format

### List Iterations

```bash
az boards iteration project list --depth 1
```

### Delete Iteration

```bash
az boards iteration project delete --path "\\{project}\\Iteration\\{name}" --yes
```

## Issue/Ticket Operations

### Create Work Item

```bash
az boards work-item create \
  --title "{title}" \
  --type "{type}" \
  --description "{body}" \
  --iteration "{iteration}" \
  --assigned-to "{assignee}"
```

- `{type}` is typically `User Story`, `Task`, `Bug`, `Feature`, or `Epic`

### Read Work Item

```bash
az boards work-item show --id {id}
```

### List Work Items (by query)

```bash
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State] FROM WorkItems WHERE [System.IterationPath] = '{iteration}' AND [System.State] <> 'Closed'"
```

List work items assigned to a specific person:

```bash
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State] FROM WorkItems WHERE [System.IterationPath] = '{iteration}' AND [System.AssignedTo] = '{assignee}'"
```

### Update Work Item

Update state:

```bash
az boards work-item update --id {id} --state "{state}"
```

Update fields:

```bash
az boards work-item update --id {id} \
  --title "{new_title}" \
  --assigned-to "{assignee}" \
  --iteration "{iteration}"
```

### Close Work Item

```bash
az boards work-item update --id {id} --state "Closed"
```

### Comment on Work Item

```bash
az boards work-item update --id {id} --discussion "{comment}"
```

### Label / Tag Operations

Add tags to a work item:

```bash
az boards work-item update --id {id} --fields "System.Tags={tag1}; {tag2}"
```

Note: Azure Boards uses Tags (semicolon-separated) rather than labels. Tags are set via the `System.Tags` field.
