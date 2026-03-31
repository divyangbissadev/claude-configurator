---
name: GitHub
description: Code host provider adapter for GitHub using the gh CLI
---

# GitHub Provider Adapter

## Provider Overview

GitHub is a Git-based code hosting platform. This adapter uses the official `gh` CLI tool to interact with repositories, pull requests, and other GitHub features from the command line.

## CLI Tool

- **Tool:** `gh` (GitHub CLI)
- **Install:** https://cli.github.com/
- **Docs:** https://cli.github.com/manual/

## Authentication

Check current auth status:

```bash
gh auth status
```

Set up authentication interactively:

```bash
gh auth login
```

Authenticate with a token:

```bash
gh auth login --with-token < token.txt
```

## Provider Detection

Auto-detect GitHub by inspecting the git remote URL:

```bash
git remote get-url origin | grep -q "github.com"
```

Patterns to match:
- `https://github.com/{owner}/{repo}.git`
- `git@github.com:{owner}/{repo}.git`
- `ssh://git@github.com/{owner}/{repo}.git`

## Repository Operations

### Get Repository Info

```bash
gh repo view --json name,owner,defaultBranchRef
```

### Clone a Repository

```bash
gh repo clone {owner}/{repo}
```

### Create a Branch

```bash
git checkout -b {branch}
```

### Push a Branch

```bash
git push -u origin {branch}
```

### Create a Pull Request

```bash
gh pr create --title "{title}" --body "{body}" --milestone "{milestone}"
```

With additional options:

```bash
gh pr create --title "{title}" --body "{body}" --base {base_branch} --head {branch} --label "{label}" --reviewer "{reviewer}" --milestone "{milestone}"
```

### Merge a Pull Request

```bash
gh pr merge {pr_number} --squash --delete-branch
```

Other merge strategies:

```bash
gh pr merge {pr_number} --merge --delete-branch
gh pr merge {pr_number} --rebase --delete-branch
```

### List Pull Requests

```bash
gh pr list --json number,title,state
```

Filter by state:

```bash
gh pr list --state open --json number,title,state,author
gh pr list --state closed --json number,title,state
gh pr list --state merged --json number,title,state
```

### View a Pull Request

```bash
gh pr view {pr_number} --json number,title,state,body,author,reviews
```

### Add Reviewers to a Pull Request

```bash
gh pr edit {pr_number} --add-reviewer "{reviewer}"
```

### Check Pull Request Status

```bash
gh pr checks {pr_number}
```
