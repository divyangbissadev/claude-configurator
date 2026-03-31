# Agentic SDLC

Pluggable, AI-powered Software Development Life Cycle for Claude Code. Takes a layman prompt through prompt refinement, planning, sprint management, parallel agent execution, multi-layer code review, and documentation — with user approval gates at every phase.

> **Install in your repo**: See [Installation & Usage Guide](../../docs/AGENTIC_SDLC_INSTALL.md) for full setup instructions.

## Quick Start

```bash
# 1. Configure providers (interactive wizard)
/sdlc-setup

# 2. Run the full pipeline
/sdlc build me a landing page for an AI code assistant

# Or manage sprints directly
/sprint new "Auth System"
/sprint run
/ticket next
```

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        AGENTIC SDLC                              │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Commands          Agents (8)           Providers (12)           │
│  ──────────        ──────────           ────────────             │
│  /sdlc             prompt-polisher      Code:                    │
│  /sdlc-setup       sprint-manager       ├── github.md            │
│  /sdlc-docs        ticket-worker        ├── gitlab.md            │
│  /sprint           quality-gate         ├── azure-devops.md      │
│  /ticket           doc-writer           └── bitbucket.md         │
│                    doc-reviewer                                  │
│                    confluence-writer     Tickets:                 │
│                    claude-md-manager     ├── github-issues.md     │
│                                         ├── jira.md              │
│  Rules             Hooks                ├── azure-boards.md      │
│  ──────            ──────               └── gitlab-issues.md     │
│  sdlc-conventions  sdlc-pre-commit.sh                            │
│                                         Docs:                    │
│  Config                                 ├── confluence.md        │
│  ──────                                 ├── notion.md            │
│  .claude/sdlc-config.yml               ├── github-wiki.md       │
│                                         └── markdown-local.md    │
│                                                                  │
├──────────────────────────────────────────────────────────────────┤
│                    PLUGIN INTEGRATIONS                            │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  everything-claude-code (15 skills, 14+ agents)                  │
│  ├── /prompt-optimize, /product-lens, /blueprint                 │
│  ├── /team-builder, /devfleet, /orchestrate                      │
│  ├── /tdd, /e2e, /security-review, /verification-loop            │
│  ├── /search-first, /learn-eval, /simplify                       │
│  └── code-reviewer, security-reviewer, tdd-guide, architect,     │
│      planner, e2e-runner, doc-updater, refactor-cleaner,         │
│      python/typescript/go/rust/java/kotlin/cpp/flutter-reviewer  │
│                                                                  │
│  superpowers (7 skills, 4 agents)                                │
│  ├── /brainstorm, /writing-plans, /subagent-driven-development   │
│  ├── /dispatching-parallel-agents, /verification-before-completion│
│  └── spec-reviewer, code-quality-reviewer,                       │
│      spec-document-reviewer, plan-document-reviewer              │
│                                                                  │
│  code-review, code-simplifier, atlassian (optional)              │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## Pipeline (10 Phases, 10 User Gates)

| Phase | What Happens | Skills/Agents Fired | User Gate |
|-------|-------------|--------------------:|-----------|
| 0. Init | Detect repo, stack, load config | auto-detect | Confirm repo + stack |
| 1. Polish | Refine layman prompt → structured spec | `/prompt-optimize` | Approve spec or refine |
| 2. Validate | Challenge assumptions, check personas | `/product-lens` | Approve / Refine / Pivot / Cancel |
| 3. Brainstorm | Explore 3+ approaches, pick direction | `/brainstorm` + spec-doc-reviewer | Pick approach or explore more |
| 4. Plan | Blueprint → detailed tasks → review | `/blueprint` + `/writing-plans` + plan-reviewer | Approve plan or adjust |
| 5. Sprint | Create milestone + tickets from plan | sprint-manager + provider adapter | Approve board or modify |
| 6. Execute | Parallel agents in worktrees, TDD | `/devfleet` + `/team-builder` + `/tdd` | After each batch: continue/review/adjust |
| 7. Quality | Tests, security, code review, docs | All reviewers + `/verification-before-completion` | Approve / Fix / Request changes |
| 8. Merge | Squash merge approved PRs | code provider adapter | Merge all / selected / hold |
| 8. Retro | Sprint report + retrospective | confluence-writer + `/learn-eval` | Feedback or skip |

## Supported Providers

| Category | Providers |
|----------|-----------|
| **Code Host** | GitHub (`gh`), GitLab (`glab`), Azure DevOps (`az repos`), Bitbucket (REST API) |
| **Tickets** | GitHub Issues, Jira (REST API), Azure Boards (`az boards`), GitLab Issues |
| **Docs** | Confluence (REST API), Notion (API), GitHub Wiki, Local Markdown |

## Flow Routing

The pipeline auto-routes based on prompt intent:

```
                    ┌─── CODE ──────→ Full Pipeline (Phases 0-8)
Raw Prompt → Polish │
                    ├─── DOCS ──────→ Doc Flow (Phase 4-DOCS → 8)
                    │
                    └─── BOTH ──────→ Full Pipeline + Doc agents in team
```

## Commands Reference

| Command | Description |
|---------|-------------|
| `/sdlc <idea>` | Full SDLC pipeline from prompt to shipped code |
| `/sdlc-setup` | Interactive provider configuration wizard |
| `/sdlc-docs <topic>` | Documentation flow: write, review, publish |
| `/sprint new <name>` | Create a new sprint with milestone + labels |
| `/sprint board` | View kanban board for current sprint |
| `/sprint add <title>` | Add a ticket to current sprint |
| `/sprint plan all` | Break tickets into implementation steps |
| `/sprint run` | Execute sprint with parallel developer agents |
| `/sprint status` | Quick progress bar |
| `/sprint close` | Close sprint with report + retrospective |
| `/sprint history` | View past sprints |
| `/sprint docs` | Generate sprint documentation |
| `/ticket <#N>` | Work a single ticket end-to-end |
| `/ticket #N #M #O` | Work multiple tickets in parallel |
| `/ticket PROJ-123` | Work a Jira ticket |
| `/ticket next` | Pick next available sprint ticket |

## Configuration

Provider config is stored in `.claude/sdlc-config.yml`. Run `/sdlc-setup` to generate it interactively, or copy from `templates/sdlc-config.yml.example`.

## File Structure

```
workflows/agentic-sdlc/
├── README.md                    ← You are here
├── manifest.yml                 ← Workflow manifest
├── templates/
│   └── sdlc-config.yml.example  ← Config template
├── commands/                    ← 5 slash commands
├── agents/                      ← 8 custom agents
├── providers/
│   ├── code/                    ← 4 code host adapters
│   ├── tickets/                 ← 4 ticket system adapters
│   └── docs/                    ← 4 documentation platform adapters
├── rules/                       ← Convention rules
├── hooks/                       ← Git hooks
└── docs/                        ← Detailed documentation
    ├── PIPELINE.md              ← Full pipeline reference
    ├── AGENTS.md                ← Agent inventory
    ├── PROVIDERS.md             ← Provider guide
    └── EXAMPLES.md              ← Walkthrough examples
```

## Further Reading

- [Pipeline Reference](docs/PIPELINE.md) — Detailed breakdown of all 10 phases
- [Agent Inventory](docs/AGENTS.md) — All agents used across the pipeline
- [Provider Guide](docs/PROVIDERS.md) — How providers work, how to add new ones
- [Examples](docs/EXAMPLES.md) — Step-by-step walkthroughs
