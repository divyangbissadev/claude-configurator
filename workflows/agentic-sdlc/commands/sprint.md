---
description: "Sprint management — create, view, run, and close sprints using any configured ticket provider (GitHub Issues, Jira, Azure Boards, GitLab)."
---

# Sprint Manager (Provider-Agnostic)

Manage development sprints using your configured ticket provider. Works with GitHub Issues, Jira, Azure Boards, or GitLab Issues.

## Input

Command: `$ARGUMENTS`

---

## PROVIDER LOADING

Before executing any command, load the provider configuration:

```bash
cat .claude/sdlc-config.yml 2>/dev/null
```

Read `providers.tickets` to determine which adapter to use.
Load the corresponding provider adapter from `providers/tickets/`.
Load the code provider adapter from `providers/code/` for PR operations.

If no config exists, auto-detect from git remote and default to the platform's native issue system.

---

## COMMANDS

### `sprint new <name>` — Create a New Sprint

1. Load ticket provider adapter
2. Create sprint/milestone/iteration using the provider's command:
   - **GitHub Issues**: Create milestone via `gh api`
   - **Jira**: Create sprint via Agile REST API
   - **Azure Boards**: Create iteration via `az boards`
   - **GitLab Issues**: Create milestone via `glab api`
3. Set duration from config (default: 14 days)
4. Create standard labels/tags if they don't exist (using provider's label mechanism)
5. Display: "Sprint '<name>' created, due <date>"

### `sprint board` — View Current Sprint Board

1. Load active sprint/milestone/iteration from provider
2. List all tickets
3. Map provider-specific statuses to universal statuses:
   - TODO (open/new/to-do/backlog)
   - IN PROGRESS (in-progress/active/doing)
   - DONE (closed/done/resolved)
4. Display as formatted kanban board:

```
Sprint: <name> | Due: <date> | Progress: X/Y completed

TODO
────
#12  feat: OAuth2 login flow              [feature]
#14  test: Auth integration tests          [chore]

IN PROGRESS
───────────
#13  feat: JWT token management            [feature]

DONE
────
#11  feat: User model setup                [feature] ✓
```

### `sprint add <title>` — Add a Ticket to Current Sprint

1. Find active sprint/milestone/iteration
2. Ask user for:
   - Description (or generate from title)
   - Label: feature / bug / chore / infra / docs
   - Dependencies (blocked by which tickets?)
3. Create ticket using provider adapter
4. Add dependency references

### `sprint plan <ticket-refs or "all">` — Plan Tickets into Actionable Tasks

For each specified ticket (or all open tickets in sprint):
1. Read ticket using provider adapter
2. Break into implementation steps
3. Update ticket description with detailed plan
4. Estimate complexity: S / M / L / XL

### `sprint run` — Execute the Current Sprint

Core execution engine using developer agents.

1. **Load sprint board** from ticket provider
2. **Build dependency graph** from ticket references
3. **Identify parallel batches** of independent tickets
4. **For each batch**:
   a. Map ticket labels to agent types:
      - feature → ticket-worker / feature-dev agent
      - bug → debugger agent
      - docs → doc-writer + doc-reviewer agents
      - chore → general-purpose agent
      - infra → architect agent
   b. Dispatch agents in isolated worktrees (one per ticket)
   c. Each agent:
      - Read ticket from provider
      - Create branch: `<prefix>/<ticket-id>-<slug>`
      - TDD: write tests → implement → verify
      - Create PR/MR using code provider adapter
      - Comment on ticket with PR/MR link
   d. Run quality-gate agent per PR
5. **Report progress** after each batch
6. **Handle blockers** — flag to user, skip to next batch

### `sprint status` — Quick Status Check

Query ticket provider for sprint progress:

```
Sprint: <name> | Due: <date>
Progress: ████████░░ 8/10 (80%)
Open: 2 | In Progress: 0 | Done: 8
Velocity: 4 tickets/week
```

### `sprint close` — Close the Current Sprint

1. Check for open tickets via provider
2. If open tickets exist, ask user:
   - Close them? (mark as won't-do)
   - Move to next sprint? (carryover)
3. For carryover, create next sprint and reassign
4. Close the sprint/milestone/iteration via provider
5. Generate sprint report:
   - Tickets completed vs planned
   - PRs/MRs merged (list with links)
   - Carryover items
6. **Publish report to docs provider**:
   - Confluence: dispatch confluence-writer agent
   - Notion: use Notion API
   - GitHub Wiki: push to wiki repo
   - markdown-local: write to `docs/sprints/`
7. **Update CLAUDE.md** via claude-md-manager agent
8. Capture learnings

### `sprint history` — View Past Sprints

Query ticket provider for closed sprints/milestones with completion stats.

### `sprint docs` — Generate Sprint Documentation

1. Gather all completed tickets, PRs, and changes from the sprint
2. Dispatch doc-writer agent to create sprint documentation
3. Dispatch doc-reviewer agent to validate
4. Publish to configured docs provider

---

## DEFAULTS

- If no command is given, show `sprint board`
- Sprint duration from config (default: 14 days)
- All operations use the configured ticket provider
- Falls back to auto-detection if no config

## EXAMPLES

```
/sprint new "Auth System"         → Creates sprint in your ticket provider
/sprint board                     → Kanban board from any provider
/sprint add "OAuth2 login flow"   → Creates ticket in current sprint
/sprint plan all                  → Breaks all tickets into impl steps
/sprint run                       → Executes sprint with developer agents
/sprint status                    → Quick progress bar
/sprint close                     → Closes sprint, publishes report
/sprint history                   → Lists past sprints
/sprint docs                      → Generates sprint documentation
```
