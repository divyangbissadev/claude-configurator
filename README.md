# claude-configurator

Enterprise-grade Claude Code configuration generator for multi-pod organizations. **282 files** including 22 core agents, 28 commands, 16 stacks (31 stack agents), 8 workflows, 12 hook scripts, write-gated agent memory, JIRA time tracking, pluggable Agentic SDLC with 12 provider adapters, and usage analytics.

---

## Table of Contents

1. [What This Solves](#what-this-solves)
2. [Quick Start (60 seconds)](#quick-start)
3. [Greenfield Project Setup](#greenfield-project-setup)
4. [Brownfield Project Setup](#brownfield-project-setup)
5. [How It Works](#how-it-works)
6. [Daily Developer Experience](#daily-developer-experience)
7. [Complete Feature Reference](#complete-feature-reference)
   - [Core Agents (22)](#core-agents-22)
   - [Core Commands (23)](#core-commands-23)
   - [Core Rules (9)](#core-rules-9)
   - [Contexts (3)](#contexts-3)
   - [Hooks (12 scripts, 10 events)](#hooks-12-scripts-10-events)
   - [Agent Memory System](#agent-memory-system)
   - [MCP Integrations (2)](#mcp-integrations-2)
   - [Stacks (16)](#stacks-16)
   - [Workflows (8)](#workflows-8)
   - [Example Templates (4)](#example-templates-4)
8. [Customizing Your Setup](#customizing-your-setup)
9. [Superpowers Integration](#superpowers-integration)
10. [Contributing (New Stacks & Workflows)](#contributing)
11. [CLI Reference](#cli-reference)
12. [Architecture](#architecture)
13. [FAQ](#faq)

---

## What This Solves

| Problem | Solution |
|---------|----------|
| Every developer configures Claude Code differently | One `claude-pod.yml` → consistent setup across the team |
| New devs don't know team conventions | Rules + anti-patterns enforced automatically from day 1 |
| Claude gives generic advice | Stack-specific agents know Spring/PySpark/Go/Rust idioms |
| Same anti-patterns keep appearing in reviews | Stack anti-patterns caught automatically every time |
| Code reviews are inconsistent | code-reviewer + stack-reviewer apply the same standards |
| Nobody keeps CLAUDE.md updated | Auto-generated from config — always current |
| No visibility into AI tool usage | Usage tracker with cost estimates and Langfuse export |
| No time tracking per JIRA ticket | JIRA tracker auto-links sessions to tickets from branch names |
| Agent context resets every session | Write-gated agent memory persists learned patterns across sessions |
| Dangerous commands executed accidentally | PreToolUse hooks block `rm -rf`, force push, destructive SQL |

---

## Quick Start

```bash
# In your pod repo
git submodule add <configurator-repo-url> .claude-configurator

# Interactive wizard (2 minutes)
.claude-configurator/bin/claude-setup init

# Done. Open Claude Code — everything is configured.
```

---

## Greenfield Project Setup

### Step 1: Create repo and add configurator

```bash
mkdir my-service && cd my-service && git init
git submodule add <configurator-repo-url> .claude-configurator
```

### Step 2: Run the wizard

```bash
.claude-configurator/bin/claude-setup init
```

The wizard asks:
- Pod name, team, description
- Stack (10 options: python-spark, java-spring, golang, rust, etc.)
- Workflows to enable (ci-quality-gate, tdd, jira-tracker, etc.)
- Your test/lint/ci commands, commit format, coverage minimum

### Step 3: Commit

```bash
git add .gitmodules .claude-configurator .claude/ .claude-local/ claude-pod.yml CLAUDE.md
git commit -m "feat: add Claude Code configuration"
```

### Step 4: Start building

Claude Code now has your full setup — agents, commands, rules, hooks, contexts, memory.

---

## Brownfield Project Setup

### Step 1: Add configurator

```bash
cd existing-project
git submodule add <configurator-repo-url> .claude-configurator
.claude-configurator/bin/claude-setup init
```

### Step 2: Migrate existing `.claude/` files

```bash
# Move pod-specific agents to .claude-local/ (they have project context)
mv .claude/agents/my-custom-agent.md .claude-local/agents/

# Move pod-specific commands
mv .claude/commands/my-custom-command.md .claude-local/commands/

# Move pod-specific rules
mv .claude/rules/my-custom-rule.md .claude-local/rules/
```

### Step 3: Register in `claude-pod.yml`

```yaml
overrides:
  agents:
    include:
      - .claude-local/agents/my-custom-agent.md
  commands:
    include:
      - .claude-local/commands/my-custom-command.md
```

### Step 4: Add architecture context

Create `.claude-local/CLAUDE.extra.md` with your architecture diagrams, extension points, and reference documents. This is appended to the generated CLAUDE.md.

### Step 5: Regenerate and commit

```bash
.claude-configurator/bin/claude-setup generate
git add .gitmodules .claude-configurator .claude/ .claude-local/ claude-pod.yml CLAUDE.md
git commit -m "feat: adopt Claude Code configurator"
```

---

## How It Works

### Layering Model

```
┌─────────────────────────────────────────────────┐
│  Layer 4: .claude-local/  (pod overrides)        │  Highest priority
├─────────────────────────────────────────────────┤
│  Layer 3: workflows/      (opt-in modules)       │
├─────────────────────────────────────────────────┤
│  Layer 2: stacks/         (language-specific)    │
├─────────────────────────────────────────────────┤
│  Layer 1: core/           (universal foundation) │  Lowest priority
└─────────────────────────────────────────────────┘
```

Later layers overwrite earlier on filename conflict. Your `.claude-local/` overrides always win.

### What gets generated

| Generated (don't hand-edit) | Your files (hand-edit these) |
|---|---|
| `.claude/agents/` | `.claude-local/agents/` |
| `.claude/commands/` | `.claude-local/commands/` |
| `.claude/rules/` | `.claude-local/rules/` |
| `.claude/contexts/` | `.claude-local/CLAUDE.extra.md` |
| `.claude/hooks/` | `claude-pod.yml` |
| `.claude/mcp-configs/` | `.claude/settings.local.json` |
| `.claude/settings.json` | |
| `.claude/agent-memory/` (scaffolded, never overwritten) | |
| `CLAUDE.md` | |

---

## Daily Developer Experience

### Session lifecycle (automatic)

```
Session Start
  → session-start.sh loads persisted context
  → jira-session-start.sh detects ticket from branch (PR-557)
  → inject-agent-memory.sh ready for subagent dispatches
  → log-prompt.sh begins tracking

During Session
  → block-dangerous.sh prevents rm -rf, force push, destructive SQL
  → post-edit-check.sh scans for hardcoded secrets after each edit
  → track-agent-usage.sh logs agent dispatches with cost estimates
  → log-task-complete.sh tracks productivity
  → memory-write-gate.sh validates before persisting learned context

Session End
  → session-end.sh saves metadata + usage estimates
  → jira-session-end.sh calculates duration, logs against JIRA ticket
  → Prints: session usage ($0.75 sonnet) + JIRA time (47m on PR-557)
```

### Common tasks

| What You Do | What Activates | Stack Enhancement |
|---|---|---|
| "Explain this codebase" | `onboarding-guide` agent, `/explore` | Stack-specific conventions |
| "Fix the failing build" | `build-error-resolver` + stack build resolver | Go/Java/Rust-specific fixes |
| "Add a new endpoint" | `planner` → `tdd-guide` → `api-designer` | Stack API patterns |
| `/tdd` | Red-green-refactor cycle enforced | Stack testing conventions |
| `/review-pr` | `code-reviewer` + `security-reviewer` | Stack-specific anti-pattern scan |
| `/validate` | Runs your `make ci` (from vars) | Stack lint/type rules |
| "Check this SQL" | `database-reviewer` | Indexes, N+1, parameterization |
| "How much have I spent?" | `/usage` or `/cost` | Model-specific pricing |
| "Time on PR-557?" | `/jira-time` | Ticket-level breakdown |
| "Ship it" | `/verify` then Superpowers finish-branch | Commit format from vars |

### Context modes

| Mode | Activate | Behavior |
|------|----------|----------|
| **dev** | "Switch to dev mode" | Speed, TDD, small commits, YAGNI |
| **review** | "Switch to review mode" | Thoroughness, confidence scoring, security focus |
| **research** | "Switch to research mode" | Read-only exploration, no changes, document findings |

---

## Complete Feature Reference

### Core Agents (22)

Every pod gets these regardless of stack:

| Agent | Model | Purpose |
|-------|-------|---------|
| `accessibility-tester` | opus | WCAG 2.1 AA compliance, screen reader compat, keyboard navigation |
| `api-designer` | opus | REST/GraphQL API design, versioning, contracts, error formats |
| `architect` | sonnet | System design review, scalability, simplicity, extensibility |
| `build-error-resolver` | sonnet | Fix build errors minimally — no refactoring, no architecture changes |
| `chief-of-staff` | sonnet | Workflow orchestration, task triage (P0-P3), multi-agent coordination |
| `code-reviewer` | sonnet | Multi-pass review: design → line-by-line → anti-patterns → confidence scoring |
| `data-engineer` | opus | ETL pipelines, data quality checks, warehouse schema design |
| `database-reviewer` | sonnet | Query optimization, index design, N+1 detection, RLS, parameterization |
| `debugger` | sonnet | Scientific method: reproduce → hypothesize → investigate → isolate → fix |
| `doc-updater` | sonnet | Keep CLAUDE.md, README, API docs current with codebase |
| `docs-lookup` | sonnet | Find and retrieve documentation, assess freshness |
| `e2e-runner` | sonnet | E2E test creation, flaky test management, journey coverage |
| `loop-operator` | sonnet | Iterative processes: retry, converge, checkpoint, abort conditions |
| `migration-specialist` | opus | Schema/data migrations, expand-contract, zero-downtime, rollback |
| `onboarding-guide` | sonnet | Codebase walkthrough for new developers |
| `performance-engineer` | opus | Profiling, bottleneck identification, optimization by impact/effort |
| `planner` | sonnet | Implementation plans with exact file paths, dependencies, risk levels |
| `prompt-engineer` | opus | LLM prompt design, evaluation frameworks, production prompt systems |
| `refactor-cleaner` | sonnet | Dead code detection, duplicate elimination, safe refactoring |
| `security-reviewer` | sonnet | OWASP Top 10, injection, auth, secrets, dependency vulnerabilities |
| `tdd-guide` | sonnet | Enforce RED → GREEN → REFACTOR with edge case coverage |
| `technical-writer` | opus | API docs, architecture docs, runbooks, user guides |

### Core Commands (23)

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `/build-fix` | Fix build errors minimally | Build failures |
| `/checkpoint` | Save work state for recovery | Before risky operations |
| `/e2e` | Generate and run E2E tests | Testing critical user flows |
| `/eval` | Evaluate against success criteria | Before claiming "done" |
| `/explore` | Systematic codebase exploration | Understanding new code |
| `/memory-correct` | Correct a memory entry with propagation | Wrong info in agent memory |
| `/memory-prune` | Remove stale/expired memory entries | Monthly cleanup |
| `/memory-search` | Search across all agent memories | Finding prior context |
| `/memory-status` | Show memory entry counts and staleness | Health check |
| `/memory-write` | Write validated entry to agent memory | Persisting learned patterns |
| `/multi-execute` | Execute coordinated agent waves | Complex multi-domain tasks |
| `/multi-plan` | Decompose task across agents | Planning complex work |
| `/orchestrate` | Coordinate multiple agents | Cross-domain work |
| `/plan` | Create implementation plan | Before coding any feature |
| `/refactor-clean` | Remove dead code and duplicates | Periodic cleanup |
| `/review-pr` | Multi-pass PR review | Before merge |
| `/sessions` | View/restore session history | Resuming prior work |
| `/setup-pod` | Refine pod config interactively | Changing setup |
| `/tdd` | Red-green-refactor cycle | Feature development |
| `/test-coverage` | Analyze coverage gaps | Before PR |
| `/update-docs` | Sync docs with codebase | After major changes |
| `/validate` | Run project quality gate | Before every commit |
| `/verify` | Verify implementation matches spec | Before claiming done |

### Core Rules (9)

| Rule | Scope | Key Points |
|------|-------|------------|
| `agent-memory` | `.claude/agent-memory/**` | Format, write gates, corrections, security, hygiene |
| `agents` | `.claude/agents/**` | Use specific agents, provide context, review output |
| `documentation` | All files | CLAUDE.md current, comments explain WHY, no dead code |
| `git-workflow` | All files | Commit format, branch naming, PR size < 400 lines |
| `hooks` | `.claude/hooks/**` | Fast, idempotent, silent on success |
| `patterns` | All files | Composition > inheritance, DI, explicit > implicit |
| `performance` | All files | No O(n²), no blocking calls, batch operations, profile first |
| `security` | Code files | No hardcoded creds, parameterized queries, validate input |
| `testing` | Test files | Behavior > implementation, independent, edge cases required |

### Contexts (3)

| Context | File | Focus |
|---------|------|-------|
| `dev` | `.claude/contexts/dev.md` | Speed, TDD, small commits, read before write, YAGNI |
| `review` | `.claude/contexts/review.md` | Correctness, security, design, tests, readability |
| `research` | `.claude/contexts/research.md` | Understand first, map landscape, document, no changes |

### Hooks (12 scripts, 10 events)

| Event | Script | What It Does |
|-------|--------|-------------|
| **SessionStart** | `session-start.sh` | Loads `.claude/session-context.md` from previous session |
| **UserPromptSubmit** | `log-prompt.sh` | Logs prompt length (not content) to CSV for analytics |
| **PreToolUse (Bash)** | `block-dangerous.sh` | Blocks `rm -rf /`, `git push --force`, `git reset --hard`, `DROP TABLE` |
| **PostToolUse (Agent)** | `track-agent-usage.sh` | Logs agent name, model, token count, cost estimate |
| **PostToolUse (Edit/Write)** | `post-edit-check.sh` | Scans for hardcoded secrets and debug statements |
| **SubagentStart** | `inject-agent-memory.sh` | Loads agent-specific + shared memory into subagent context |
| **SubagentStop** | `capture-agent-learnings.sh` | Logs agent completion events |
| **PreCompact** | `pre-compact.sh` | Checkpoints git state before context window compaction |
| **Stop** | `session-end.sh` | Saves session metadata, estimates tokens and cost |
| **TaskCompleted** | `log-task-complete.sh` | Logs task completions for productivity tracking |
| **StopFailure** | `handle-rate-limit.sh` | Logs rate limit errors, suggests cost reduction |
| (validation) | `memory-write-gate.sh` | Validates memory entries against 5 quality gates |

### Agent Memory System

Persistent, write-gated memory that prevents context rot across sessions.

**Structure:**
```
.claude/agent-memory/
├── shared/MEMORY.md              # Cross-agent knowledge
├── code-reviewer/MEMORY.md       # Review patterns, recurring issues
├── debugger/MEMORY.md            # Root causes, debugging insights
├── planner/MEMORY.md             # Planning decisions, scope patterns
└── ... (one per agent, auto-scaffolded)
```

**Entry format:**
```markdown
### [Pattern] N+1 query in OrderService — 2026-03-28

**Context**: Found during PR review of order listing feature
**Insight**: getOrders() makes individual DB calls per order for items. Use batch fetch.
**Evidence**: src/services/OrderService.java:47
**Confidence**: High
**Expires**: Never
```

**Write gates** (must pass at least one):

| Gate | Question | Prevents |
|------|----------|----------|
| Behavioral | Will this change how Claude acts next time? | Storing trivia |
| Commitment | Is someone counting on this? | Forgetting deadlines |
| Decision | Why was X chosen over Y? | Losing decision context |
| Factual | Will this remain true tomorrow? | Storing ephemeral info |
| Explicit | Did the user say "remember this"? | Missing explicit requests |

**Correction propagation**: Old entries marked `[SUPERSEDED]`, corrections propagate to shared memory and other agents referencing the same fact.

**Key design**: Memory files are **never overwritten** on `generate`/`sync` — learned knowledge survives updates.

### MCP Integrations (2)

Templates in `.claude/mcp-configs/` — copy and configure with your credentials:

| Config | Service | Environment Variables |
|--------|---------|----------------------|
| `github.json` | GitHub API | `$GITHUB_TOKEN` |
| `azure-devops.json` | Azure DevOps | `$ADO_ORG`, `$ADO_PAT` |

### Stacks (16)

#### Application Stacks (10)

| Stack | Agents | Anti-Patterns | Best For |
|-------|--------|---------------|----------|
| `python-spark` | databricks-developer, databricks-architect, python-reviewer, pytorch-build-resolver | 10 (no .count(), no bare col(), no schema inference) | Databricks, Delta Lake, PySpark |
| `java-spring` | spring-reviewer, java-build-resolver | 8 (no field injection, no @Transactional on private) | Spring Boot, Maven/Gradle |
| `typescript-react` | react-reviewer, typescript-reviewer | 8 (no any, no default exports, no useEffect for state) | React, Next.js, Node.js |
| `golang` | go-reviewer, go-build-resolver | 7 (no panic(), no goroutine without ctx) | Go microservices, gRPC |
| `rust` | rust-reviewer, rust-build-resolver | 6 (no unwrap(), no unsafe without comment) | Axum, Actix, systems |
| `kotlin` | kotlin-reviewer, kotlin-build-resolver | 8 (no !!, no GlobalScope.launch) | Android, KMP |
| `cpp` | cpp-reviewer, cpp-build-resolver | 9 (no raw new/delete, no C-style casts) | C++20/23, systems |
| `flutter` | flutter-reviewer | 8 (no setState for complex, no dynamic types) | Flutter/Dart mobile |
| `dotnet` | (stub — agents coming) | 7 (no async void, no Task.Result) | .NET, ASP.NET Core |
| `python-django` | (stub — agents coming) | 7 (no raw SQL, no N+1, no objects.all()) | Django, DRF |

#### Platform & Infrastructure Stacks (6) — NEW

| Stack | Agents | Anti-Patterns | Best For |
|-------|--------|---------------|----------|
| `databricks` | platform-engineer, dlt-developer, mlops-engineer, unity-catalog-admin, workflow-orchestrator, sql-analyst, reviewer (7) | 12 (no append-only, no schema inference, no hardcoded cluster IDs, always MERGE) | Databricks, Unity Catalog, DLT, MLflow, Feature Store |
| `airflow` | dag-developer, plugin-builder, infra-engineer, reviewer (4) | 8 (no top-level DAG code, no hardcoded connections, always TaskFlow API) | Apache Airflow, Astronomer, MWAA, Cloud Composer |
| `aws` | solutions-architect, lambda-developer, data-engineer, devops-engineer, security-engineer, reviewer (6) | 9 (no IAM wildcards, no public S3, no unencrypted, always tag) | AWS Lambda, ECS, EKS, Glue, Redshift, CDK, Step Functions |
| `terraform` | developer, module-builder, security-auditor, reviewer (4) | 8 (no local state, no count for conditionals, pin versions) | Terraform, OpenTofu, multi-cloud IaC |
| `kubernetes` | manifest-developer, helm-chart-builder, gitops-engineer, networking-engineer, security-engineer, reviewer (6) | 9 (no latest tag, no root containers, always probes/limits/PDB) | K8s, Helm, ArgoCD, Istio, Kustomize |
| `observability` | otel-instrumentation-engineer, grafana-dashboard-builder, alerting-engineer, reviewer (4) | 7 (no high-cardinality labels, no alerts without runbooks) | OpenTelemetry, Prometheus, Grafana, Jaeger |

### Workflows (8)

#### `ci-quality-gate` — Quality gates before merge
- `/ci-gate` command — lint, type check, tests, security scan
- `ci-conventions` rule — all checks must pass, coverage threshold enforced

#### `tdd` — Test-driven development
- `/tdd` command — strict RED → GREEN → REFACTOR cycle
- `tdd-conventions` rule — test before implementation, commit per green state

#### `incident-response` — Production debugging
- `incident-responder` agent — assess, stabilize, diagnose, fix, verify, document
- `/debug-incident` command — systematic triage workflow

#### `adr` — Architecture Decision Records
- `/new-adr` command — scaffold ADR with template (context, decision, consequences, alternatives)

#### `onboarding` — New developer orientation
- `onboarding-buddy` agent — patient tech lead for codebase tours
- `/explore-codebase` command — guided exploration

#### `usage-tracker` — Token usage and cost analytics
- `cost-analyst` agent — usage patterns, optimization recommendations
- `/usage` command — full report (daily, weekly, by model, by agent)
- `/cost` command — quick current-session estimate
- `/usage-export` command — CSV/JSON export with Langfuse integration code
- `cost-awareness` rule — cheapest model for the task, batch operations
- Hooks: `track-session-start.sh`, `track-session-end.sh`, `track-agent.sh`
- Data: `.claude/usage/usage-log.csv` (project), `~/.claude/usage/global-usage.csv` (cross-project)

#### `jira-tracker` — JIRA time tracking and sprint analytics
- `jira-analyst` agent — time attribution, velocity metrics, pattern analysis
- `/jira-link` command — manually link session to ticket
- `/jira-time` command — time report by ticket (today/week/all time)
- `/jira-sprint` command — sprint analytics with velocity insights
- `/jira-log-time` command — push tracked time to JIRA as worklogs via REST API
- `/jira-commits` command — git commits correlated with ticket time
- `jira-conventions` rule — branch naming includes ticket, commit messages prefixed
- Hooks: `jira-session-start.sh` (auto-detect ticket from branch), `jira-session-end.sh` (log duration)
- Data: `.claude/jira/time-log.csv` (project), `~/.claude/jira/global-time-log.csv` (cross-project)
- API: Set `$JIRA_HOST`, `$JIRA_EMAIL`, `$JIRA_TOKEN` for JIRA REST API integration

#### `agentic-sdlc` — Pluggable Agentic Software Development Life Cycle

**Provider-agnostic SDLC** that works with any combination of code host, ticket system, and docs platform.

**Supported Providers:**
| Category | Providers |
|----------|-----------|
| Code Host | GitHub (`gh`), GitLab (`glab`), Azure DevOps (`az repos`), Bitbucket (REST API) |
| Tickets | GitHub Issues, Jira (REST API), Azure Boards (`az boards`), GitLab Issues |
| Documentation | Confluence (REST API), Notion (API), GitHub Wiki, Local Markdown |

**Agents (8):**
- `prompt-polisher` — refines layman prompts into structured engineering specs
- `sprint-manager` — creates sprints/milestones, tracks velocity, generates retrospectives
- `ticket-worker` — picks up tickets, branches, TDD implements, creates PRs/MRs
- `quality-gate` — runs tests, lint, security, code review on PRs before merge
- `doc-writer` — creates architecture docs, API docs, guides, sprint reports
- `doc-reviewer` — reviews documentation for accuracy against the codebase
- `confluence-writer` — specialist for Confluence storage format, macros, page hierarchy
- `claude-md-manager` — auto-generates and maintains CLAUDE.md from codebase analysis

**Commands (5):**
- `/sdlc` — full pipeline: prompt polish → brainstorm → plan → sprint setup → parallel agents → quality gates → sprint close
- `/sprint` — sprint management: `new`, `board`, `add`, `plan`, `run`, `status`, `close`, `history`, `docs`
- `/ticket` — work tickets from any provider (GitHub `#42`, Jira `PROJ-123`, or `next`)
- `/sdlc-docs` — documentation flow: write, review, publish to configured platform
- `/sdlc-setup` — interactive wizard to configure providers and store in `.claude/sdlc-config.yml`

**Provider Adapters (12):** 4 code, 4 ticket, 4 docs — each with CLI commands, auth, and detection patterns
**Rules:** `sdlc-conventions` — provider-agnostic branch naming, PR/MR conventions, quality gates, doc flow
**Hook:** `sdlc-pre-commit.sh` — auto-references ticket ID from branch name in commits
**Config:** `.claude/sdlc-config.yml` — stores provider selections, sprint settings, agent config
**Integrates with:** `/devfleet`, `/team-builder`, `/orchestrate` (everything-claude-code), `/brainstorm`, `/writing-plans` (superpowers), Atlassian plugin (Jira/Confluence)

### Example Templates (4)

Ready-to-use CLAUDE.md examples in `examples/`:

| Template | Stack | Architecture |
|----------|-------|-------------|
| `saas-nextjs-CLAUDE.md` | Next.js 14, Supabase, Stripe | App Router, server actions, tRPC |
| `go-microservice-CLAUDE.md` | Go 1.22, gRPC, PostgreSQL, Redis | Hexagonal, domain-driven |
| `django-api-CLAUDE.md` | Django 5, DRF, Celery, PostgreSQL | Service layer, async tasks |
| `rust-api-CLAUDE.md` | Rust 1.77, Axum, SQLx, PostgreSQL | Handler → service → repository |

---

## Customizing Your Setup

### `claude-pod.yml` — your pod's config

```yaml
pod:
  name: "order-service"
  team: "Platform Engineering"
  description: "Order processing microservice with event sourcing"

stack: "golang"              # One of 10 stacks

workflows:                   # Opt-in modules
  - ci-quality-gate
  - tdd
  - jira-tracker
  - usage-tracker
  - incident-response
  - adr
  - onboarding

overrides:
  agents:
    include:                 # Your pod-specific agents
      - .claude-local/agents/my-domain-agent.md
    exclude:                 # Remove irrelevant core agents
      - e2e-runner
      - accessibility-tester
  rules:
    include:
      - .claude-local/rules/my-team-conventions.md
    exclude: []
  commands:
    include:
      - .claude-local/commands/my-deploy.md
    exclude: []

vars:
  repo_name: "myorg/order-service"
  repo_host: "github"          # github | azure-devops | gitlab
  commit_format: "feat|fix|chore: <summary>"
  coverage_minimum: "80"
  primary_language: "go"
  test_command: "make test"
  lint_command: "make lint"
  ci_command: "make ci"
```

### Adding pod-specific agents

1. Create `.claude-local/agents/my-agent.md` (copy format from any core agent)
2. Add to `overrides.agents.include` in `claude-pod.yml`
3. Run `claude-setup generate`

### Adding pod-specific commands

1. Create `.claude-local/commands/my-command.md` with `description:` frontmatter
2. Add to `overrides.commands.include`
3. Regenerate. Shows as `/my-command` in Claude Code.

### Adding CLAUDE.md sections

Create `.claude-local/CLAUDE.extra.md` — appended to the generated CLAUDE.md. Use for: architecture diagrams, domain model, extension points, deployment guides, reference doc links.

### Excluding defaults

```yaml
overrides:
  agents:
    exclude:
      - e2e-runner         # No frontend in this service
      - accessibility-tester  # Backend only
```

### Environment variables for integrations

```bash
# JIRA time tracking
export JIRA_HOST="your-org.atlassian.net"
export JIRA_EMAIL="your-email"
export JIRA_TOKEN="your-api-token"

# GitHub MCP
export GITHUB_TOKEN="ghp_..."

# Azure DevOps MCP
export ADO_ORG="your-org"
export ADO_PAT="your-pat"
```

---

## Superpowers Integration

The configurator and [Superpowers](https://github.com/obra/superpowers) are complementary:

```
SUPERPOWERS = HOW you develop (process enforcement)
CONFIGURATOR = WHAT Claude knows (domain knowledge)
```

| Phase | Superpowers | Configurator |
|-------|------------|-------------|
| Brainstorm | Forces design before code | api-designer + stack anti-patterns + architecture context |
| Plan | Breaks into 2-5 min tasks | planner agent uses your patterns, vars for commands |
| Implement | TDD: RED → GREEN → REFACTOR | tdd-guide + stack testing conventions |
| Review | Two-stage: spec → quality | code-reviewer + stack-reviewer + security-reviewer |
| Verify | Runs commands, confirms output | `/validate` runs your `vars.ci_command` |
| Finish | Merge/PR/cleanup options | git-workflow rules, commit format from vars |

Both active simultaneously, no configuration needed. See [Superpowers Integration Guide](docs/SUPERPOWERS_INTEGRATION.md).

---

## Contributing

### Adding a New Stack

```
stacks/your-stack/
├── agents/your-reviewer.md      # Stack-specific code reviewer
├── agents/your-build-resolver.md  # Stack-specific build fixer
├── rules/your-style.md           # Coding conventions
├── rules/testing.md              # Testing conventions
├── manifest.yml                  # name, description, provides
└── CLAUDE.stack.md               # Anti-patterns (injected into CLAUDE.md)
```

See [Adding a Stack](docs/ADDING_A_STACK.md).

### Adding a New Workflow

```
workflows/your-workflow/
├── agents/your-agent.md     # Optional
├── commands/your-command.md # Optional
├── rules/your-rule.md       # Optional
├── hooks/your-hook.sh       # Optional
└── manifest.yml             # name, description
```

See [Adding a Workflow](docs/ADDING_A_WORKFLOW.md).

---

## CLI Reference

| Command | What It Does |
|---------|-------------|
| `claude-setup init` | Interactive wizard → creates `claude-pod.yml`, `.claude-local/`, generates `.claude/` |
| `claude-setup generate` | Reads `claude-pod.yml`, assembles `.claude/` from layers, renders CLAUDE.md |
| `claude-setup sync` | Re-runs generate after configurator update, shows diff of changes |

**Running generate manually** (when submodule isn't on PATH):
```bash
bash -c 'CONFIGURATOR_ROOT=.claude-configurator; source $CONFIGURATOR_ROOT/lib/parse_config.sh; source $CONFIGURATOR_ROOT/lib/generate.sh; parse_config claude-pod.yml; run_generate .'
```

---

## Architecture

### Repository Structure

```
claude-configurator/           213 files
├── bin/claude-setup                CLI entrypoint (init, generate, sync)
├── lib/
│   ├── parse_config.sh            YAML parser for claude-pod.yml
│   ├── generate.sh                Layer assembly + template rendering
│   ├── init_wizard.sh             Interactive wizard
│   └── sync.sh                    Regeneration with diff
├── core/                           Universal foundation
│   ├── agents/ (22)               Core agents
│   ├── commands/ (23)             Core commands
│   ├── rules/ (9)                 Core rules
│   ├── contexts/ (3)              Dev, review, research modes
│   ├── hooks/ (12 scripts + json) Lifecycle hooks
│   ├── mcp-configs/ (2)           GitHub, Azure DevOps
│   └── agent-memory/              Memory templates + shared memory
├── stacks/ (10)                    Language-specific layers
│   ├── python-spark/ (4 agents)
│   ├── java-spring/ (2 agents)
│   ├── typescript-react/ (2 agents)
│   ├── golang/ (2 agents)
│   ├── rust/ (2 agents)
│   ├── kotlin/ (2 agents)
│   ├── cpp/ (2 agents)
│   ├── flutter/ (1 agent)
│   ├── dotnet/ (stub)
│   └── python-django/ (stub)
├── workflows/ (7)                  Opt-in modules
│   ├── ci-quality-gate/
│   ├── tdd/
│   ├── incident-response/
│   ├── adr/
│   ├── onboarding/
│   ├── usage-tracker/ (3 hooks, 3 commands, 1 agent)
│   └── jira-tracker/ (2 hooks, 5 commands, 1 agent)
├── templates/                      CLAUDE.md + settings.json templates
├── examples/ (4)                   Ready-to-use CLAUDE.md templates
├── tests/ (5 suites)               Bash test suite
└── docs/ (5 guides)                Documentation
```

### Generation Flow

```
claude-pod.yml
     │
     ▼
┌──────────────────────────────────────┐
│ 1. Validate stack + workflows exist  │
│ 2. Clear .claude/ (preserve memory)  │
│ 3. Copy core/* → .claude/           │
│ 4. Overlay stacks/{stack}/*         │
│ 5. Overlay workflows/{name}/*       │
│ 6. Apply excludes (delete files)    │
│ 7. Apply includes (copy from local) │
│ 8. Scaffold agent memory dirs       │
│ 9. Render CLAUDE.md from template   │
│ 10. Render settings.json            │
└──────────────────────────────────────┘
     │
     ▼
.claude/ + CLAUDE.md (generated)
```

---

## Agentic SDLC — Quick Install

The Agentic SDLC workflow can be installed into any repo in 3 commands:

```bash
git submodule add https://github.com/divyangbissadev/claude-configurator.git .claude-configurator
mkdir -p .claude/{commands,agents,providers,rules}
cp .claude-configurator/workflows/agentic-sdlc/commands/*.md .claude/commands/ && \
cp .claude-configurator/workflows/agentic-sdlc/agents/*.md .claude/agents/ && \
cp -r .claude-configurator/workflows/agentic-sdlc/providers/* .claude/providers/ && \
cp .claude-configurator/workflows/agentic-sdlc/rules/*.md .claude/rules/ && \
cp .claude-configurator/workflows/agentic-sdlc/templates/sdlc-config.yml.example .claude/sdlc-config.yml
```

Then in Claude Code: `/sdlc-setup` to configure providers, `/sdlc <your idea>` to run.

See **[Full Installation & Usage Guide](docs/AGENTIC_SDLC_INSTALL.md)** for detailed instructions, plugin requirements, provider setup, and all available commands.

---

## FAQ

**Q: Do developers need to know the configurator exists?**
No. They use Claude Code normally. The configurator makes it smarter about their codebase from the first interaction.

**Q: What if I don't want some core agents?**
Add them to `overrides.agents.exclude` in `claude-pod.yml`.

**Q: Can two pods use different stacks?**
Yes. Each pod has its own `claude-pod.yml`. The configurator is shared, configs are independent.

**Q: What happens when the configurator is updated?**
Run `claude-setup sync`. Your `.claude-local/` overrides and agent memory are preserved. Review the diff.

**Q: Do hooks require Node.js?**
No. All hooks are bash scripts. Works on macOS, Linux, WSL.

**Q: How accurate are the cost estimates?**
Rough estimates based on message/tool counts (±30%). For precise tracking, use the Anthropic API dashboard or Langfuse export.

**Q: Is agent memory shared across the team?**
Yes — memory files are committed to git. The whole team benefits from learned patterns.

**Q: What model should agents use?**
`sonnet` for standard tasks (fast, cheap). `opus` for deep reasoning (API design, architecture, performance analysis). `haiku` for mechanical tasks. Set per-agent in frontmatter.

**Q: Can I use this with Superpowers?**
Yes — they complement each other. Superpowers enforces the development process, the configurator provides domain knowledge. Both active simultaneously. See [integration guide](docs/SUPERPOWERS_INTEGRATION.md).

**Q: How do I push time to JIRA?**
Run `/jira-log-time` with `$JIRA_HOST`, `$JIRA_EMAIL`, `$JIRA_TOKEN` set. It aggregates sessions by ticket+day and POSTs worklogs via the JIRA REST API.

---

## Updating

```bash
git submodule update --remote .claude-configurator
.claude-configurator/bin/claude-setup sync
git add .claude-configurator .claude/ CLAUDE.md
git commit -m "chore: update Claude Code configurator"
```

---
