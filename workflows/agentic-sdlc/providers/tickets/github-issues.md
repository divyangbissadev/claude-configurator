---
name: github-issues
description: GitHub Issues ticket provider using the gh CLI for issue tracking, milestones, and labels
---

# GitHub Issues Provider

## Provider Overview

GitHub Issues is the built-in issue tracking system for GitHub repositories. This provider uses the `gh` CLI (GitHub CLI) to manage issues, milestones, and labels. Milestones serve as the sprint equivalent, grouping issues into time-boxed iterations.

## CLI Tool

- **Tool**: `gh` (GitHub CLI)
- **Documentation**: https://cli.github.com/manual/
- **Install**: `brew install gh` / `apt install gh` / `winget install GitHub.cli`

## Required Configuration

| Variable / Setting | Description |
|---|---|
| `gh auth login` | Must be authenticated via `gh auth login` before use |
| `GH_TOKEN` | Alternatively, set a personal access token as `GH_TOKEN` env var |
| `GH_REPO` | Optionally set `owner/repo` to avoid passing it each time |

The `gh` CLI auto-detects the repository from the current git remote. If running outside a repo directory, set `GH_REPO=owner/repo` or pass `--repo owner/repo` to each command.

## Sprint Mapping

GitHub Issues does not have a native sprint concept. **Milestones** are used as the sprint equivalent:

| SDLC Concept | GitHub Concept |
|---|---|
| Sprint / Iteration | Milestone |
| Sprint Name | Milestone title |
| Sprint Start Date | _(not natively supported)_ |
| Sprint End Date | Milestone `due_on` date |
| Sprint Backlog | Issues assigned to the milestone |

## Status Mapping

| SDLC Status | GitHub State | Notes |
|---|---|---|
| TODO | `open` | Issue is open with no assignee or "todo" label |
| IN-PROGRESS | `open` | Issue is open and assigned, or has "in-progress" label |
| DONE | `closed` | Issue is closed |

Since GitHub Issues only has `open` and `closed` states, use labels (e.g., `status:todo`, `status:in-progress`) to distinguish between TODO and IN-PROGRESS.

## Sprint/Iteration Operations

### Create Milestone (Sprint)

```bash
gh api repos/{owner}/{repo}/milestones --method POST \
  -f title="{title}" \
  -f due_on="{date}" \
  -f description="{description}" \
  -f state="open"
```

- `{date}` must be ISO 8601 format: `YYYY-MM-DDTHH:MM:SSZ`

### List Milestones

```bash
gh api repos/{owner}/{repo}/milestones --jq '.[].title'
```

### Close Milestone (End Sprint)

```bash
gh api repos/{owner}/{repo}/milestones/{milestone_number} --method PATCH \
  -f state="closed"
```

## Issue/Ticket Operations

### Create Issue

```bash
gh issue create \
  --title "{title}" \
  --body "{body}" \
  --label "{label}" \
  --milestone "{milestone}" \
  --assignee "{assignee}"
```

### View Issue

```bash
gh issue view {number} --json number,title,body,labels,milestone,assignees,state
```

### List Issues

```bash
gh issue list \
  --milestone "{milestone}" \
  --json number,title,state,labels
```

Filter by label:

```bash
gh issue list \
  --milestone "{milestone}" \
  --label "{label}" \
  --json number,title,state,labels
```

### Update Issue

```bash
gh issue edit {number} \
  --title "{new_title}" \
  --body "{new_body}" \
  --add-label "{label}" \
  --milestone "{milestone}"
```

### Close Issue

```bash
gh issue close {number} --comment "{comment}"
```

### Reopen Issue

```bash
gh issue reopen {number}
```

### Comment on Issue

```bash
gh issue comment {number} --body "{body}"
```

### Label Operations

Create a label:

```bash
gh label create "{name}" --color "{color}" --force
```

Add labels to an issue:

```bash
gh issue edit {number} --add-label "{label1},{label2}"
```

Remove labels from an issue:

```bash
gh issue edit {number} --remove-label "{label}"
```
