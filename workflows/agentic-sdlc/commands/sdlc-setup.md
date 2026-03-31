---
description: "Interactive setup wizard — configures code host, ticket system, and docs platform for the Agentic SDLC pipeline."
---

# SDLC Setup Wizard

Interactive setup that detects your environment and asks you to choose providers for the Agentic SDLC pipeline. Stores configuration in `.claude/sdlc-config.yml`.

## Input

`$ARGUMENTS`

If arguments provided (e.g., `github jira confluence`), use them directly. Otherwise run interactive mode.

---

## STEP 1: AUTO-DETECT ENVIRONMENT

### Detect Code Host

```bash
git remote get-url origin 2>/dev/null
```

Parse the URL to detect the provider:
- Contains `github.com` → **github**
- Contains `gitlab.com` or `gitlab.` → **gitlab**
- Contains `dev.azure.com` or `visualstudio.com` → **azure-devops**
- Contains `bitbucket.org` → **bitbucket**
- Cannot detect → ask user

Extract owner/org and repo name from the URL.

### Detect CLI Tools Available

Check which CLIs are installed:
```bash
which gh 2>/dev/null     # GitHub CLI
which glab 2>/dev/null   # GitLab CLI
which az 2>/dev/null     # Azure CLI
which bb 2>/dev/null     # Bitbucket CLI (optional)
```

### Detect Existing Config

```bash
cat .claude/sdlc-config.yml 2>/dev/null
```

If exists, show current config and ask: "Update existing config or start fresh?"

---

## STEP 2: CHOOSE PROVIDERS

Present detected info and ask user to confirm or override.

### Code Host

```
Detected code host: GitHub (from git remote)
  Owner: {owner}
  Repo: {repo}

Is this correct? [Y/n]
If not, choose: (1) GitHub  (2) GitLab  (3) Azure DevOps  (4) Bitbucket
```

### Ticket System

```
Choose your ticket/issue tracking system:
  (1) GitHub Issues  — built into GitHub, uses milestones for sprints
  (2) Jira           — Atlassian, requires JIRA_HOST/EMAIL/TOKEN env vars
  (3) Azure Boards   — Azure DevOps work items and iterations
  (4) GitLab Issues  — built into GitLab, uses milestones for sprints

Your choice:
```

If Jira selected, ask for:
- JIRA host (e.g., `mycompany.atlassian.net`)
- Project key (e.g., `PROJ`)
- Board ID (for sprint management)
- Verify: `Are JIRA_EMAIL and JIRA_TOKEN env vars set?`

### Documentation Platform

```
Choose your documentation platform:
  (1) Confluence       — Atlassian wiki, requires CONFLUENCE_HOST/EMAIL/TOKEN
  (2) Notion           — requires NOTION_TOKEN env var
  (3) GitHub Wiki      — git-based wiki in your repo
  (4) Local Markdown   — docs/ directory in your repo (default)
  (5) Skip             — no documentation integration

Your choice:
```

If Confluence selected, ask for:
- Host, space key, parent page ID
- Verify env vars

---

## STEP 3: CONFIGURE SPRINT DEFAULTS

```
Sprint settings:
  Duration (days) [14]:
  Enforce TDD? [Y/n]:
  Auto code review on PRs? [Y/n]:
  Max parallel agents [5]:
```

---

## STEP 4: CLAUDE.MD MANAGEMENT

```
CLAUDE.md management:
  Auto-update CLAUDE.md with project context? [Y/n]:
  Include tech stack info? [Y/n]:
  Include team conventions? [Y/n]:
  Include available /commands? [Y/n]:
```

---

## STEP 5: GENERATE CONFIG

Create `.claude/sdlc-config.yml` with all selections:

```bash
mkdir -p .claude
```

Write the config file based on user selections using the template from
`workflows/agentic-sdlc/templates/sdlc-config.yml.example`.

---

## STEP 6: VERIFY SETUP

Run provider-specific verification:

### GitHub
```bash
gh auth status
gh repo view {owner}/{repo} --json name
```

### GitLab
```bash
glab auth status
```

### Jira
```bash
curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" "https://{host}/rest/api/3/myself" | head -1
```

### Confluence
```bash
curl -s -u "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" "https://{host}/wiki/api/v2/spaces?limit=1" | head -1
```

Report results:
```
Setup complete!

  Code:    GitHub (divyangbissadev/my-project) ✓
  Tickets: Jira (mycompany.atlassian.net / PROJ) ✓
  Docs:    Confluence (mycompany.atlassian.net / DEV) ✓
  Sprint:  14 days, TDD enforced, auto-review on

Config saved to: .claude/sdlc-config.yml

You can now run:
  /sdlc <your idea>     — full SDLC pipeline
  /sprint new "name"    — create a sprint
  /ticket 42            — work on an issue
  /sdlc-docs <topic>    — documentation flow
```

---

## STEP 7: UPDATE CLAUDE.MD (if opted in)

If auto-update CLAUDE.md is enabled, append or update the SDLC section in CLAUDE.md:

```markdown
## Agentic SDLC

This project uses the Agentic SDLC workflow.

### Providers
- Code: {provider} ({details})
- Tickets: {provider} ({details})
- Docs: {provider} ({details})

### Available Commands
- `/sdlc <idea>` — Full development lifecycle
- `/sprint <cmd>` — Sprint management
- `/ticket <#>` — Work on issues
- `/sdlc-docs <topic>` — Documentation flow
- `/sdlc-setup` — Reconfigure providers

### Conventions
- Branch naming: feat/{issue}-slug, fix/{issue}-slug, chore/{issue}-slug
- PRs must reference issue: "Closes #{issue}"
- TDD required: tests before implementation
- Sprint duration: {N} days
```

---

## QUICK SETUP (non-interactive)

```
/sdlc-setup github jira confluence
/sdlc-setup gitlab gitlab-issues markdown-local
/sdlc-setup azure-devops azure-boards confluence
```
