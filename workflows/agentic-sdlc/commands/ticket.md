---
description: "Work on a single ticket from any provider — branches, TDD implements, creates PR/MR, and closes the ticket."
---

# Ticket Worker (Provider-Agnostic)

Pick up a ticket from any configured provider and work it end-to-end: branch, implement with TDD, verify, create PR/MR, and link back to the ticket.

## Input

`$ARGUMENTS`

Accepted formats:
- `#42` or `42` — work on ticket/issue number 42
- `PROJ-123` — work on Jira ticket PROJ-123
- `#42 #43 #44` — work on multiple tickets in parallel
- `next` — pick the next unassigned ticket from the current sprint

---

## PROVIDER LOADING

```bash
cat .claude/sdlc-config.yml 2>/dev/null
```

Load ticket provider from `providers.tickets` and code provider from `providers.code`.
If no config, auto-detect from git remote.

---

## SINGLE TICKET WORKFLOW

### Step 1: Load the Ticket

Use the ticket provider adapter to read the ticket:
- **GitHub Issues**: `gh issue view <number> --json number,title,body,labels,milestone`
- **Jira**: `curl -s -u "$JIRA_EMAIL:$JIRA_TOKEN" "https://$JIRA_HOST/rest/api/3/issue/<key>"`
- **Azure Boards**: `az boards work-item show --id <id> --output json`
- **GitLab Issues**: `glab issue view <number>`

Parse: title, description, acceptance criteria, dependencies/blocked-by.
If blocked by open tickets, warn user and ask whether to proceed.

### Step 2: Update Ticket Status

Mark ticket as "in progress" using provider adapter.

### Step 3: Create Branch

```bash
git checkout -b <prefix>/<ticket-ref>-<slug>
```

Branch prefix:
- `feat/` for features
- `fix/` for bugs
- `chore/` for chores
- `docs/` for documentation tickets

Ticket ref format:
- GitHub/GitLab: `42`
- Jira: `PROJ-123`
- Azure: `42`

### Step 4: Understand Context

- Read files referenced in the ticket
- Search for existing solutions in the codebase
- If a plan file references this ticket, load the relevant section

### Step 5: Route by Ticket Type

**If ticket is documentation type (label: docs)**:
1. Dispatch doc-writer agent
2. Dispatch doc-reviewer agent
3. Publish to docs provider (Confluence, Notion, wiki, or local)
4. Skip to Step 8

**If ticket is code type**:
Continue to Step 6

### Step 6: TDD Implementation

1. Write failing tests based on acceptance criteria
2. Implement minimal code to pass tests
3. Refactor if needed
4. Ensure 80%+ coverage on changed files

### Step 7: Verify

- Run full test suite — read output, check exit code
- Run linter if configured
- Run build if applicable
- No claims without fresh evidence

### Step 8: Create PR/MR

Use the code provider adapter:
- **GitHub**: `gh pr create --title "<type>: <title>" --body "Closes #<number>"`
- **GitLab**: `glab mr create --title "<type>: <title>" --description "Closes #<number>"`
- **Azure DevOps**: `az repos pr create --title "<type>: <title>" --description "Closes AB#<id>"`
- **Bitbucket**: Create PR via REST API

PR body always includes:
- Summary of changes
- Reference to ticket (Closes #N / Fixes PROJ-123)
- Test plan checklist

### Step 9: Link Back to Ticket

Comment on the ticket with PR/MR link using provider adapter.

### Step 10: Code Review

Run quality-gate agent. If issues found, fix, push, re-verify.

---

## MULTI-TICKET PARALLEL MODE

When multiple ticket refs are provided:

1. **Check dependencies** between tickets
2. **Group independent tickets** for parallel execution
3. **Dispatch via Agent tool** — one agent per ticket in isolated worktree
4. **Sequential for dependent tickets** — dependency order
5. **Report results** — table of all tickets with PR/MR links

---

## NEXT MODE

When `next` is provided:

1. Load active sprint from ticket provider
2. List open tickets not in-progress or blocked
3. Pick the first one (by priority, then by ID)
4. Mark as in-progress
5. Execute single ticket workflow

---

## DOCUMENTATION TICKET MODE

When the ticket is labeled as docs/documentation:

1. Read the ticket requirements
2. Dispatch doc-writer agent with requirements
3. doc-writer reads codebase and generates content
4. Dispatch doc-reviewer agent to validate
5. If Confluence: dispatch confluence-writer agent to publish
6. If other provider: use adapter to publish
7. Create PR for any in-repo doc changes
8. Close ticket with link to published doc

---

## EXAMPLES

```
/ticket 42                → Work on GitHub/GitLab issue #42
/ticket PROJ-123          → Work on Jira ticket PROJ-123
/ticket #12 #13 #14       → Work 3 tickets in parallel
/ticket next              → Pick next sprint ticket
```
