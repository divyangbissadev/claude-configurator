# Agent Inventory

Complete inventory of all agents used in the Agentic SDLC pipeline — both custom agents and agents from integrated plugins.

---

## Custom Agents (8)

These agents are defined in `workflows/agentic-sdlc/agents/`.

| Agent | Model | Purpose | Used In |
|-------|-------|---------|---------|
| `prompt-polisher` | sonnet | Refines layman prompts into structured engineering specs | Phase 1 (fallback) |
| `sprint-manager` | sonnet | Creates milestones, issues, tracks velocity, generates reports | Phase 5, 8 |
| `ticket-worker` | sonnet | Picks up tickets, branches, TDD implements, creates PRs | Phase 6 |
| `quality-gate` | sonnet | Runs tests, lint, security, code review on PRs | Phase 7 |
| `doc-writer` | sonnet | Creates architecture docs, API docs, guides, sprint reports | Phase 4-DOCS, 6, 8 |
| `doc-reviewer` | sonnet | Reviews documentation for accuracy against codebase | Phase 4-DOCS, 7 |
| `confluence-writer` | sonnet | Confluence storage format specialist, macros, page hierarchy | Phase 4-DOCS, 8 |
| `claude-md-manager` | sonnet | Auto-generates and maintains CLAUDE.md from codebase analysis | Phase 8 |

---

## Everything-Claude-Code Agents (14+)

These agents are defined in the ECC plugin at `agents/`.

### Core Development Agents

| Agent | Model | Purpose | Used In |
|-------|-------|---------|---------|
| `planner` | sonnet | Implementation planning, step breakdown, dependency ordering | Phase 4 |
| `architect` | sonnet | Architecture decisions, system design | Phase 4 |
| `tdd-guide` | sonnet | Test-driven development enforcement | Phase 6 |
| `build-error-resolver` | sonnet | Fix build errors, compiler issues | Phase 6 (bug tickets) |
| `refactor-cleaner` | sonnet | Code cleanup, dead code removal | Phase 6 (refactor tickets) |
| `e2e-runner` | sonnet | Playwright E2E test generation and execution | Phase 6, 7 |
| `doc-updater` | haiku | Codemap generation, documentation freshness | Phase 7 |
| `performance-optimizer` | sonnet | Performance analysis, optimization | Phase 6 (perf tickets) |

### Review Agents

| Agent | Model | Purpose | Used In |
|-------|-------|---------|---------|
| `code-reviewer` | sonnet | Confidence-based code review (>80% threshold) | Phase 7 |
| `security-reviewer` | sonnet | OWASP Top 10, secrets detection, input validation | Phase 7 |
| `database-reviewer` | sonnet | Database query optimization, schema review | Phase 7 (if DB changes) |

### Stack-Specific Reviewers

Auto-selected based on detected tech stack:

| Agent | Language/Framework | Used In |
|-------|-------------------|---------|
| `python-reviewer` | Python | Phase 7 |
| `typescript-reviewer` | TypeScript/React | Phase 7 |
| `go-reviewer` | Go | Phase 7 |
| `rust-reviewer` | Rust | Phase 7 |
| `java-reviewer` | Java/Spring | Phase 7 |
| `kotlin-reviewer` | Kotlin | Phase 7 |
| `cpp-reviewer` | C++ | Phase 7 |
| `flutter-reviewer` | Flutter/Dart | Phase 7 |

---

## Superpowers Agents (4)

These agents are defined as prompt templates in the superpowers plugin.

| Agent | Purpose | Used In |
|-------|---------|---------|
| `spec-document-reviewer` | Validates spec quality before planning (no TODOs, no ambiguities) | Phase 3 |
| `plan-document-reviewer` | Validates plan completeness before execution | Phase 4 |
| `spec-reviewer` | Verifies implementation matches spec (independent of implementer) | Phase 7 |
| `code-quality-reviewer` | Verifies code is clean, tested, maintainable | Phase 7 |

---

## ECC Skills (as agent orchestrators)

These skills orchestrate agent dispatch patterns:

| Skill | Purpose | Used In |
|-------|---------|---------|
| `/prompt-optimize` | 6-phase prompt analysis pipeline | Phase 1 |
| `/product-lens` | Product validation, "why before building" | Phase 2 |
| `/brainstorm` | 9-step approach exploration | Phase 3 |
| `/blueprint` | Multi-session plan with adversarial review | Phase 4 |
| `/writing-plans` | Bite-sized task breakdown with code blocks | Phase 4 |
| `/team-builder` | Interactive agent selection per ticket type | Phase 6 |
| `/devfleet` | Parallel agent dispatch in isolated worktrees | Phase 6 |
| `/orchestrate` | Sequential dependent task chains with handoff | Phase 6 |
| `/subagent-driven-development` | Fresh subagent per task with 2-stage review | Phase 6 |
| `/dispatching-parallel-agents` | Independent parallel batch dispatch | Phase 6 |
| `/search-first` | Find existing solutions before coding | Phase 6 |
| `/tdd` | RED → GREEN → REFACTOR enforcement | Phase 6 |
| `/e2e` | Playwright test generation and execution | Phase 7 |
| `/security-review` | OWASP Top 10 vulnerability detection | Phase 7 |
| `/verification-loop` | Build, test, lint, typecheck, security | Phase 6, 7 |
| `/verification-before-completion` | Iron Law: evidence before claims | Phase 7 |
| `/simplify` | Code cleanup and simplification | Phase 7 |
| `/code-review` | PR review against plan | Phase 7 |
| `/learn-eval` | Extract reusable patterns | Phase 8 |

---

## Agent Dispatch by Phase

```
Phase 0:  (no agents — auto-detection only)
Phase 1:  /prompt-optimize ─── prompt-polisher (fallback)
Phase 2:  /product-lens
Phase 3:  /brainstorm ─── spec-document-reviewer
Phase 4:  /blueprint ─── architect ─── planner
          /writing-plans ─── plan-document-reviewer
Phase 5:  sprint-manager
Phase 6:  /team-builder ─── /devfleet ─── /orchestrate
          Per ticket: /search-first → /tdd (tdd-guide) → /verification-loop
          ticket-worker ─── doc-writer (for doc tickets)
Phase 7:  /verification-before-completion ─── /verification-loop
          e2e-runner ─── security-reviewer ─── code-reviewer
          spec-reviewer ─── code-quality-reviewer ─── {stack}-reviewer
          /simplify ─── doc-reviewer ─── doc-updater
Phase 8:  confluence-writer ─── claude-md-manager ─── /learn-eval
```

**Total: 30+ agents and skills dispatched across one full pipeline run.**
