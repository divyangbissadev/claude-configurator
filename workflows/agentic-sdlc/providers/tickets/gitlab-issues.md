---
name: gitlab-issues
description: GitLab Issues ticket provider using the glab CLI for issue tracking, milestones, and labels
---

# GitLab Issues Provider

## Provider Overview

GitLab Issues is the built-in issue tracking system for GitLab projects. This provider uses the `glab` CLI to manage issues, milestones, and labels. Milestones serve as the sprint equivalent, grouping issues into time-boxed iterations.

## CLI Tool

- **Tool**: `glab` (GitLab CLI)
- **Documentation**: https://gitlab.com/gitlab-org/cli
- **Install**: `brew install glab` / `apt install glab` / `winget install GLab.GLab`

## Required Configuration

| Variable / Setting | Description |
|---|---|
| `glab auth login` | Must be authenticated via `glab auth login` before use |
| `GITLAB_TOKEN` | Alternatively, set a personal access token as `GITLAB_TOKEN` env var |
| `GITLAB_HOST` | Set if using a self-managed GitLab instance (default: `gitlab.com`) |

The `glab` CLI auto-detects the project from the current git remote. If running outside a repo directory, pass `--repo owner/repo` to each command.

## Sprint Mapping

GitLab Issues uses Milestones as the sprint equivalent:

| SDLC Concept | GitLab Concept |
|---|---|
| Sprint / Iteration | Milestone |
| Sprint Name | Milestone title |
| Sprint Start Date | Milestone `start_date` |
| Sprint End Date | Milestone `due_date` |
| Sprint Backlog | Issues assigned to the milestone |

Note: GitLab also offers native Iterations (in GitLab Premium+), but Milestones are available on all tiers.

## Status Mapping

| SDLC Status | GitLab State | Notes |
|---|---|---|
| TODO | `opened` | Issue is open with no assignee or "todo" label |
| IN-PROGRESS | `opened` | Issue is open and assigned, or has "in-progress" label |
| DONE | `closed` | Issue is closed |

Since GitLab Issues only has `opened` and `closed` states, use labels (e.g., `workflow::todo`, `workflow::in-progress`) to distinguish between TODO and IN-PROGRESS.

## Sprint/Iteration Operations

### Create Milestone (Sprint)

```bash
glab api projects/{project_id}/milestones --method POST \
  -f title="{title}" \
  -f due_date="{date}" \
  -f start_date="{start_date}" \
  -f description="{description}"
```

- `{date}` and `{start_date}` in `YYYY-MM-DD` format
- `{project_id}` can be the numeric ID or URL-encoded path (e.g., `owner%2Frepo`)

### List Milestones

```bash
glab api projects/{project_id}/milestones --method GET
```

### Close Milestone (End Sprint)

```bash
glab api projects/{project_id}/milestones/{milestone_id} --method PUT \
  -f state_event="close"
```

## Issue/Ticket Operations

### Create Issue

```bash
glab issue create \
  --title "{title}" \
  --description "{body}" \
  --label "{label}" \
  --milestone "{milestone}" \
  --assignee "{assignee}"
```

### View Issue

```bash
glab issue view {number}
```

For JSON output:

```bash
glab api projects/{project_id}/issues/{number}
```

### List Issues

```bash
glab issue list --milestone "{milestone}"
```

Filter by label:

```bash
glab issue list --milestone "{milestone}" --label "{label}"
```

List only open issues:

```bash
glab issue list --milestone "{milestone}" --state opened
```

### Update Issue

```bash
glab issue update {number} \
  --title "{new_title}" \
  --description "{new_body}"
```

### Close Issue

```bash
glab issue close {number} --comment "{comment}"
```

### Reopen Issue

```bash
glab issue reopen {number}
```

### Comment on Issue

```bash
glab issue comment {number} --body "{body}"
```

### Label Operations

Create a label:

```bash
glab label create "{name}" --color "{color}"
```

Add labels to an issue:

```bash
glab issue update {number} --label "{label1},{label2}"
```

Remove labels from an issue:

```bash
glab issue update {number} --unlabel "{label}"
```
