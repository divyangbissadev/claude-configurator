---
name: Azure DevOps
description: Code host provider adapter for Azure DevOps using the az repos CLI
---

# Azure DevOps Provider Adapter

## Provider Overview

Azure DevOps provides Git repositories, CI/CD pipelines, and project management tools as part of the Microsoft Azure ecosystem. This adapter uses the `az repos` commands from the Azure CLI with the DevOps extension.

## CLI Tool

- **Tool:** `az` (Azure CLI) with the `azure-devops` extension
- **Install:** https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
- **Extension:** `az extension add --name azure-devops`
- **Docs:** https://learn.microsoft.com/en-us/cli/azure/repos

## Authentication

Check current auth status:

```bash
az account show
```

Log in interactively:

```bash
az login
```

Configure the default organization and project:

```bash
az devops configure --defaults organization=https://dev.azure.com/{org} project={project}
```

Authenticate with a personal access token:

```bash
export AZURE_DEVOPS_EXT_PAT={pat_token}
```

## Provider Detection

Auto-detect Azure DevOps by inspecting the git remote URL:

```bash
git remote get-url origin | grep -qE "dev\.azure\.com|visualstudio\.com"
```

Patterns to match:
- `https://dev.azure.com/{org}/{project}/_git/{repo}`
- `https://{org}@dev.azure.com/{org}/{project}/_git/{repo}`
- `git@ssh.dev.azure.com:v3/{org}/{project}/{repo}`
- `https://{org}.visualstudio.com/{project}/_git/{repo}` (legacy)

## Repository Operations

### Get Repository Info

```bash
az repos show --repository {repo}
```

### Clone a Repository

```bash
git clone https://dev.azure.com/{org}/{project}/_git/{repo}
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
az repos pr create --title "{title}" --description "{body}" --target-branch main
```

With additional options:

```bash
az repos pr create --title "{title}" --description "{body}" --source-branch {branch} --target-branch {base_branch} --repository {repo} --reviewers "{reviewer}" --work-items {work_item_id}
```

### Merge a Pull Request

```bash
az repos pr update --id {pr_id} --status completed --squash true --delete-source-branch true
```

Other completion options:

```bash
az repos pr update --id {pr_id} --status completed --merge-strategy squash --delete-source-branch true
az repos pr update --id {pr_id} --status completed --merge-strategy rebase --delete-source-branch true
```

### List Pull Requests

```bash
az repos pr list --output table
```

Filter by status:

```bash
az repos pr list --status active --output table
az repos pr list --status completed --output table
az repos pr list --status abandoned --output table
```

### View a Pull Request

```bash
az repos pr show --id {pr_id} --output table
```

### Add Reviewers to a Pull Request

```bash
az repos pr reviewer add --id {pr_id} --reviewers "{reviewer}"
```

### Set Pull Request Auto-Complete

```bash
az repos pr update --id {pr_id} --auto-complete true
```
