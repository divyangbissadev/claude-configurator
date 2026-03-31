# Agentic SDLC — Installation & Usage Guide

Install the pluggable Agentic SDLC workflow into any repository. Works with GitHub, GitLab, Azure DevOps, or Bitbucket. Supports Jira, GitHub Issues, Azure Boards, or GitLab Issues for tickets. Publishes docs to Confluence, Notion, GitHub Wiki, or local Markdown.

---

## Prerequisites

- **Claude Code** CLI installed (`claude` command available)
- **Git** repository (existing or new)
- One of: `gh` (GitHub), `glab` (GitLab), `az` (Azure), or Bitbucket credentials
- Optional: `JIRA_HOST`/`JIRA_EMAIL`/`JIRA_TOKEN` env vars for Jira
- Optional: `CONFLUENCE_HOST`/`CONFLUENCE_EMAIL`/`CONFLUENCE_TOKEN` for Confluence
- Optional: `NOTION_TOKEN` for Notion

---

## Installation Methods

### Method 1: Submodule (Recommended for teams)

```bash
cd your-project

# Add configurator as a submodule
git submodule add https://github.com/divyangbissadev/claude-configurator.git .claude-configurator

# Copy SDLC commands to your project
mkdir -p .claude/commands
cp .claude-configurator/workflows/agentic-sdlc/commands/*.md .claude/commands/

# Copy SDLC agents
mkdir -p .claude/agents
cp .claude-configurator/workflows/agentic-sdlc/agents/*.md .claude/agents/

# Copy provider adapters (for reference by agents)
cp -r .claude-configurator/workflows/agentic-sdlc/providers .claude/providers

# Copy rules
mkdir -p .claude/rules
cp .claude-configurator/workflows/agentic-sdlc/rules/*.md .claude/rules/

# Copy config template
cp .claude-configurator/workflows/agentic-sdlc/templates/sdlc-config.yml.example .claude/sdlc-config.yml

# Install community skills
npx skills add vercel-labs/skills@find-skills -y
npx skills add borghei/claude-skills@agile-product-owner -y
npx skills add miles990/claude-software-skills@project-management -y
npx skills add martinholovsky/claude-skills-generator@cicd-expert -y
npx skills add martinholovsky/claude-skills-generator@devsecops-expert -y
npx skills add mindrally/skills@ci-cd-best-practices -y
npx skills add vudovn/antigravity-kit@code-review-checklist -y
npx skills add zixun-github/aisdlc@using-aisdlc -y

# Commit
git add .claude-configurator .claude/ .agents/ skills-lock.json
git commit -m "feat: add Agentic SDLC workflow"
```

### Method 2: Direct Copy (Quick setup)

```bash
cd your-project

# Clone configurator temporarily
git clone https://github.com/divyangbissadev/claude-configurator.git /tmp/claude-configurator

# Copy what you need
mkdir -p .claude/{commands,agents,providers,rules}
cp /tmp/claude-configurator/workflows/agentic-sdlc/commands/*.md .claude/commands/
cp /tmp/claude-configurator/workflows/agentic-sdlc/agents/*.md .claude/agents/
cp -r /tmp/claude-configurator/workflows/agentic-sdlc/providers/* .claude/providers/
cp /tmp/claude-configurator/workflows/agentic-sdlc/rules/*.md .claude/rules/
cp /tmp/claude-configurator/workflows/agentic-sdlc/templates/sdlc-config.yml.example .claude/sdlc-config.yml

# Clean up
rm -rf /tmp/claude-configurator

# Commit
git add .claude/
git commit -m "feat: add Agentic SDLC workflow"
```

### Method 3: User-Level Install (Available in all repos)

```bash
# Copy commands to user-level .claude directory
mkdir -p ~/.claude/commands
cp workflows/agentic-sdlc/commands/*.md ~/.claude/commands/

# Now /sdlc, /sprint, /ticket, /sdlc-docs, /sdlc-setup are available in every repo
```

---

## Setup

### Step 1: Configure Providers

Open Claude Code in your repo and run:

```
/sdlc-setup
```

The interactive wizard will:
1. Auto-detect your code host from `git remote`
2. Ask you to choose a ticket system
3. Ask you to choose a docs platform
4. Configure sprint defaults
5. Save config to `.claude/sdlc-config.yml`
6. Verify authentication for each provider

**Quick setup (non-interactive):**
```
/sdlc-setup github github-issues markdown-local
/sdlc-setup github jira confluence
/sdlc-setup gitlab gitlab-issues markdown-local
/sdlc-setup azure-devops azure-boards confluence
```

### Step 2: Verify

```
/sprint board
```

If this works without errors, you're set up.

---

## Usage

### Full SDLC Pipeline

Give it any prompt — layman language works:

```
/sdlc build me a user authentication system with OAuth2 and 2FA
```

```
/sdlc add a REST API for managing tasks with CRUD operations
```

```
/sdlc document our API endpoints and publish to Confluence
```

```
/sdlc fix the login bug where users get 401 on valid credentials
```

The pipeline:
1. Polishes your prompt into a structured spec
2. Validates the product need
3. Brainstorms 3+ approaches — you pick one
4. Creates a detailed plan
5. Sets up a sprint with tickets in your ticket system
6. Dispatches developer agents in parallel (isolated worktrees)
7. Runs 4-layer code review + security + E2E tests
8. Merges PRs (with your approval at every step)
9. Publishes sprint report + updates CLAUDE.md

**You approve at 10 gates. Nothing ships without your sign-off.**

### Sprint Management

```bash
# Create a sprint
/sprint new "Q2 Auth Overhaul"

# View the board
/sprint board

# Add tickets
/sprint add "Implement OAuth2 with Google"
/sprint add "Add 2FA with TOTP"

# Plan all tickets into implementation steps
/sprint plan all

# Execute with parallel developer agents
/sprint run

# Check progress
/sprint status

# Close sprint (generates report, moves carryover)
/sprint close

# View past sprints
/sprint history
```

### Working Individual Tickets

```bash
# Work a single ticket
/ticket 42
/ticket PROJ-123

# Work multiple in parallel
/ticket #12 #13 #14

# Pick the next available ticket
/ticket next
```

### Documentation

```bash
# Write docs on a topic
/sdlc-docs "Architecture overview of the payment system"

# Generate API docs from code
/sdlc-docs api

# Sprint report
/sdlc-docs sprint-report

# Developer onboarding guide
/sdlc-docs onboarding

# Architecture Decision Record
/sdlc-docs adr "Switch from REST to GraphQL"

# Review existing docs for accuracy
/sdlc-docs review docs/architecture.md

# Publish local markdown to Confluence/Notion
/sdlc-docs publish docs/api-reference.md

# Generate or update CLAUDE.md
/sdlc-docs claude-md
```

---

## Required Plugins

The SDLC integrates with these Claude Code plugins. Install them for full functionality:

```bash
# Essential
/plugin install superpowers
/plugin install everything-claude-code
/plugin install code-review

# Recommended
/plugin install code-simplifier
/plugin install feature-dev
/plugin install atlassian          # If using Jira/Confluence
```

---

## Provider Quick Reference

### GitHub

```bash
# Auth
gh auth login

# Verify
gh auth status
```

### GitLab

```bash
# Auth
glab auth login

# Verify
glab auth status
```

### Jira

```bash
# Set env vars
export JIRA_HOST="mycompany.atlassian.net"
export JIRA_EMAIL="you@company.com"
export JIRA_TOKEN="your-api-token"  # Generate at id.atlassian.com
```

### Confluence

```bash
# Set env vars
export CONFLUENCE_HOST="mycompany.atlassian.net"
export CONFLUENCE_EMAIL="you@company.com"
export CONFLUENCE_TOKEN="your-api-token"
```

### Azure DevOps

```bash
# Auth
az login
az devops configure --defaults organization=https://dev.azure.com/myorg project=MyProject
```

---

## File Structure After Install

```
your-project/
├── .claude/
│   ├── sdlc-config.yml              ← Your provider config
│   ├── commands/
│   │   ├── sdlc.md                  ← /sdlc command
│   │   ├── sdlc-setup.md           ← /sdlc-setup command
│   │   ├── sdlc-docs.md            ← /sdlc-docs command
│   │   ├── sprint.md               ← /sprint command
│   │   └── ticket.md               ← /ticket command
│   ├── agents/
│   │   ├── prompt-polisher.md
│   │   ├── sprint-manager.md
│   │   ├── ticket-worker.md
│   │   ├── quality-gate.md
│   │   ├── doc-writer.md
│   │   ├── doc-reviewer.md
│   │   ├── confluence-writer.md
│   │   └── claude-md-manager.md
│   ├── providers/
│   │   ├── code/                    ← GitHub, GitLab, Azure, Bitbucket
│   │   ├── tickets/                 ← GitHub Issues, Jira, Azure Boards, GitLab
│   │   └── docs/                    ← Confluence, Notion, Wiki, Markdown
│   └── rules/
│       └── sdlc-conventions.md
├── .agents/skills/                  ← Community skills (from npx skills)
├── CLAUDE.md                        ← Auto-managed by claude-md-manager
└── docs/                            ← Local documentation output
```

---

## Updating

### Submodule method

```bash
cd .claude-configurator
git pull origin main
cd ..
cp .claude-configurator/workflows/agentic-sdlc/commands/*.md .claude/commands/
git add .claude-configurator .claude/commands/
git commit -m "chore: update Agentic SDLC to latest"
```

### Direct copy method

Re-run the clone + copy steps from Method 2.

---

## Uninstalling

```bash
# Remove commands and agents
rm .claude/commands/sdlc*.md .claude/commands/sprint.md .claude/commands/ticket.md
rm .claude/agents/{prompt-polisher,sprint-manager,ticket-worker,quality-gate,doc-writer,doc-reviewer,confluence-writer,claude-md-manager}.md
rm -rf .claude/providers
rm .claude/rules/sdlc-conventions.md
rm .claude/sdlc-config.yml

# Remove community skills
npx skills remove agile-product-owner ci-cd-best-practices cicd-expert code-review-checklist devsecops-expert project-management using-aisdlc find-skills

# Remove submodule (if used)
git submodule deinit .claude-configurator
git rm .claude-configurator
rm -rf .git/modules/.claude-configurator
```
