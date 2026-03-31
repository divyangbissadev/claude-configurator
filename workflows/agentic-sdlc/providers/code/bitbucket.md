---
name: Bitbucket
description: Code host provider adapter for Bitbucket using the REST API via curl
---

# Bitbucket Provider Adapter

## Provider Overview

Bitbucket is an Atlassian Git-based code hosting platform. Unlike the other providers, Bitbucket does not have a widely adopted official CLI tool. This adapter uses the Bitbucket REST API v2.0 via `curl`. If the community `bb` CLI is available, it may be used as an alternative.

> **Note:** If the `bb` CLI (https://bitbucket.org/nickmccurdy/bb) or similar is installed, prefer it for simpler commands. The curl-based approach below works universally without extra tooling.

## CLI Tool

- **Tool:** `curl` (for REST API calls)
- **API Base:** `https://api.bitbucket.org/2.0`
- **Docs:** https://developer.atlassian.com/cloud/bitbucket/rest/intro/

## Authentication

Check current auth status:

```bash
curl -s -u "{username}:{app_password}" https://api.bitbucket.org/2.0/user
```

Authentication uses Bitbucket App Passwords. Generate one at:
`https://bitbucket.org/account/settings/app-passwords/`

Set credentials as environment variables for reuse:

```bash
export BB_USER="{username}"
export BB_PASS="{app_password}"
export BB_AUTH="${BB_USER}:${BB_PASS}"
```

## Provider Detection

Auto-detect Bitbucket by inspecting the git remote URL:

```bash
git remote get-url origin | grep -q "bitbucket.org"
```

Patterns to match:
- `https://bitbucket.org/{workspace}/{repo}.git`
- `git@bitbucket.org:{workspace}/{repo}.git`
- `ssh://git@bitbucket.org/{workspace}/{repo}.git`

## Repository Operations

### Get Repository Info

```bash
curl -s -u "${BB_AUTH}" https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}
```

### Clone a Repository

```bash
git clone https://bitbucket.org/{workspace}/{repo}.git
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
curl -s -u "${BB_AUTH}" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "title": "{title}",
    "description": "{body}",
    "source": {
      "branch": {
        "name": "{branch}"
      }
    },
    "destination": {
      "branch": {
        "name": "{base_branch}"
      }
    },
    "close_source_branch": true
  }' \
  https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests
```

### Merge a Pull Request

```bash
curl -s -u "${BB_AUTH}" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "type": "pullrequest",
    "merge_strategy": "squash",
    "close_source_branch": true
  }' \
  https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests/{pr_id}/merge
```

Other merge strategies:

```bash
# Merge commit
-d '{"merge_strategy": "merge_commit", "close_source_branch": true}'

# Fast-forward
-d '{"merge_strategy": "fast_forward", "close_source_branch": true}'
```

### List Pull Requests

```bash
curl -s -u "${BB_AUTH}" \
  https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests
```

Filter by state:

```bash
curl -s -u "${BB_AUTH}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests?state=OPEN"

curl -s -u "${BB_AUTH}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests?state=MERGED"

curl -s -u "${BB_AUTH}" \
  "https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests?state=DECLINED"
```

### View a Pull Request

```bash
curl -s -u "${BB_AUTH}" \
  https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests/{pr_id}
```

### Add Reviewers to a Pull Request

```bash
curl -s -u "${BB_AUTH}" \
  -X PUT \
  -H "Content-Type: application/json" \
  -d '{
    "reviewers": [
      {"uuid": "{reviewer_uuid}"}
    ]
  }' \
  https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests/{pr_id}
```

### Approve a Pull Request

```bash
curl -s -u "${BB_AUTH}" \
  -X POST \
  https://api.bitbucket.org/2.0/repositories/{workspace}/{repo}/pullrequests/{pr_id}/approve
```
