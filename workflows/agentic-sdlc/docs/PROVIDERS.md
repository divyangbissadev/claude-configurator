# Provider Guide

The Agentic SDLC is provider-agnostic. All operations go through provider adapters so the same pipeline works with any combination of code host, ticket system, and docs platform.

---

## Provider Matrix

| Category | Provider | CLI/API | Adapter File |
|----------|----------|---------|-------------|
| **Code** | GitHub | `gh` CLI | `providers/code/github.md` |
| | GitLab | `glab` CLI | `providers/code/gitlab.md` |
| | Azure DevOps | `az repos` CLI | `providers/code/azure-devops.md` |
| | Bitbucket | REST API (curl) | `providers/code/bitbucket.md` |
| **Tickets** | GitHub Issues | `gh` CLI | `providers/tickets/github-issues.md` |
| | Jira | REST API (curl) | `providers/tickets/jira.md` |
| | Azure Boards | `az boards` CLI | `providers/tickets/azure-boards.md` |
| | GitLab Issues | `glab` CLI | `providers/tickets/gitlab-issues.md` |
| **Docs** | Confluence | REST API v2 (curl) | `providers/docs/confluence.md` |
| | Notion | API (curl) | `providers/docs/notion.md` |
| | GitHub Wiki | git clone/push | `providers/docs/github-wiki.md` |
| | Local Markdown | file system | `providers/docs/markdown-local.md` |

---

## How Providers Work

### Auto-Detection

The pipeline auto-detects providers from your environment:

1. **Code host** — parsed from `git remote get-url origin`:
   - `github.com` → GitHub
   - `gitlab.com` or `gitlab.` → GitLab
   - `dev.azure.com` or `visualstudio.com` → Azure DevOps
   - `bitbucket.org` → Bitbucket

2. **Ticket system** — defaults to code host's native issues, overridden by:
   - `$JIRA_HOST` env var → Jira

3. **Docs platform** — defaults to local markdown, overridden by:
   - `$CONFLUENCE_HOST` env var → Confluence
   - `$NOTION_TOKEN` env var → Notion

### Configuration

Explicit configuration via `.claude/sdlc-config.yml`:

```yaml
providers:
  code: github
  tickets: jira
  docs: confluence
```

Run `/sdlc-setup` to generate this interactively.

### Adapter Structure

Each adapter file contains:
- **Provider Overview** — what it is, when to use
- **CLI/API Tool** — what command-line tool or API to use
- **Authentication** — how to check and set up auth
- **Provider Detection** — how to auto-detect from git remote
- **Operations** — exact command templates with `{placeholders}`
- **Status Mapping** — how TODO/IN-PROGRESS/DONE map to provider-specific states
- **Sprint Mapping** — how sprints map (milestones, iterations, etc.)

---

## Common Provider Combinations

| Setup | Code | Tickets | Docs | Notes |
|-------|------|---------|------|-------|
| **GitHub-native** | GitHub | GitHub Issues | GitHub Wiki | Simplest, everything in one platform |
| **Enterprise GitHub + Jira** | GitHub | Jira | Confluence | Common enterprise setup |
| **GitLab-native** | GitLab | GitLab Issues | Local Markdown | Self-hosted friendly |
| **Azure-native** | Azure DevOps | Azure Boards | Confluence | Microsoft ecosystem |
| **Mixed** | Bitbucket | Jira | Confluence | Atlassian ecosystem |

---

## Required Environment Variables

| Provider | Variables | Purpose |
|----------|-----------|---------|
| GitHub | (none — uses `gh auth`) | Auth via GitHub CLI |
| GitLab | (none — uses `glab auth`) | Auth via GitLab CLI |
| Azure DevOps | `AZURE_DEVOPS_EXT_PAT` | Personal access token |
| Bitbucket | `BITBUCKET_USERNAME`, `BITBUCKET_APP_PASSWORD` | App password auth |
| Jira | `JIRA_HOST`, `JIRA_EMAIL`, `JIRA_TOKEN` | Atlassian API token |
| Confluence | `CONFLUENCE_HOST`, `CONFLUENCE_EMAIL`, `CONFLUENCE_TOKEN` | Atlassian API token |
| Notion | `NOTION_TOKEN` | Integration token |

---

## Adding a New Provider

To add support for a new provider (e.g., Linear for tickets):

### 1. Create the adapter file

Create `providers/tickets/linear.md` with:

```markdown
---
name: linear-tickets
description: Linear issue tracking provider adapter for the Agentic SDLC.
---

# Linear — Ticket Provider

## Provider Overview
...

## Required Configuration
- `LINEAR_API_KEY` env var

## Provider Detection
Check for LINEAR_API_KEY or linear.app references in project.

## Sprint Mapping
Linear Cycles = Sprints

## Status Mapping
| Universal | Linear |
|-----------|--------|
| TODO | Backlog, Todo |
| IN PROGRESS | In Progress |
| DONE | Done, Canceled |

## Operations

### Create Cycle (Sprint)
curl -X POST https://api.linear.app/graphql ...

### Create Issue
curl -X POST https://api.linear.app/graphql ...

### List Issues in Cycle
...
```

### 2. Update sdlc-config.yml.example

Add the new provider option:

```yaml
providers:
  tickets: linear  # NEW
```

### 3. Update sdlc-setup.md

Add the new option to the interactive wizard.

### 4. Test

Run `/sdlc-setup` and verify the new provider appears.
Create a test sprint and ticket to verify the adapter commands work.
