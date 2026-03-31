---
name: GitLab
description: Code host provider adapter for GitLab using the glab CLI
---

# GitLab Provider Adapter

## Provider Overview

GitLab is a Git-based DevOps platform that provides source code management, CI/CD, and more. This adapter uses the `glab` CLI tool to interact with repositories and merge requests.

## CLI Tool

- **Tool:** `glab` (GitLab CLI)
- **Install:** https://gitlab.com/gitlab-org/cli
- **Docs:** https://gitlab.com/gitlab-org/cli/-/blob/main/docs/source/index.md

## Authentication

Check current auth status:

```bash
glab auth status
```

Set up authentication interactively:

```bash
glab auth login
```

Authenticate with a token:

```bash
glab auth login --hostname gitlab.com --token {token}
```

For self-hosted GitLab instances:

```bash
glab auth login --hostname {gitlab_host} --token {token}
```

## Provider Detection

Auto-detect GitLab by inspecting the git remote URL:

```bash
git remote get-url origin | grep -q "gitlab.com"
```

Patterns to match:
- `https://gitlab.com/{group}/{project}.git`
- `git@gitlab.com:{group}/{project}.git`
- `ssh://git@gitlab.com/{group}/{project}.git`
- `https://{self-hosted-gitlab}/{group}/{project}.git`

## Repository Operations

### Get Repository Info

```bash
glab repo view
```

### Clone a Repository

```bash
glab repo clone {group}/{project}
```

### Create a Branch

```bash
git checkout -b {branch}
```

### Push a Branch

```bash
git push -u origin {branch}
```

### Create a Merge Request

```bash
glab mr create --title "{title}" --description "{body}" --milestone "{milestone}"
```

With additional options:

```bash
glab mr create --title "{title}" --description "{body}" --target-branch {base_branch} --source-branch {branch} --label "{label}" --reviewer "{reviewer}" --milestone "{milestone}"
```

### Merge a Merge Request

```bash
glab mr merge {mr_number} --squash --remove-source-branch
```

Other merge strategies:

```bash
glab mr merge {mr_number} --remove-source-branch
glab mr merge {mr_number} --rebase
```

### List Merge Requests

```bash
glab mr list
```

Filter by state:

```bash
glab mr list --state opened
glab mr list --state merged
glab mr list --state closed
```

### View a Merge Request

```bash
glab mr view {mr_number}
```

### Add Reviewers to a Merge Request

```bash
glab mr update {mr_number} --reviewer "{reviewer}"
```

### Check Merge Request Pipeline Status

```bash
glab ci status
```
