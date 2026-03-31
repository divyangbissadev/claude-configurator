# Pipeline Reference

Complete reference for all 10 phases, user gates, and agent dispatch patterns in the Agentic SDLC.

---

## Phase Overview

```
Phase 0: Init         ──→ [GATE] ──→
Phase 1: Polish       ──→ [GATE] ──→
Phase 2: Validate     ──→ [GATE] ──→
Phase 3: Brainstorm   ──→ [GATE] ──→
Phase 4: Plan         ──→ [GATE] ──→
Phase 5: Sprint Setup ──→ [GATE] ──→
Phase 6: Execute      ──→ [GATE per batch] ──→
Phase 7: Quality      ──→ [GATE] ──→
Phase 8a: Merge       ──→ [GATE] ──→
Phase 8b: Retro       ──→ [GATE] ──→ DONE
```

---

## Phase 0: Initialization & Provider Detection

**Purpose**: Establish working context and load provider configuration.

**Steps**:
1. Read `.claude/sdlc-config.yml` — if exists, load provider settings
2. Auto-detect code host from `git remote get-url origin`
3. Auto-detect ticket system (defaults to code host's native issues, or Jira if `$JIRA_HOST` set)
4. Auto-detect docs platform (Confluence if `$CONFLUENCE_HOST` set, else local markdown)
5. Read project context: CLAUDE.md, package.json, tech stack

**User Gate**:
```
Detected setup:
  Code:    {provider} ({owner}/{repo})
  Tickets: {provider}
  Docs:    {provider}
  Stack:   {detected tech stack}

Is this correct? [Y/n]
```

**Options**: Confirm | Run `/sdlc-setup` to change

---

## Phase 1: Prompt Polish

**Purpose**: Refine layman prompt into structured engineering specification.

**Skills/Agents**:
- `/prompt-optimize` (everything-claude-code) — 6-phase analysis pipeline
- Fallback: `prompt-polisher` agent (agentic-sdlc)

**Process**:
1. Project detection — reads CLAUDE.md, detects tech stack
2. Intent detection — feature, bug, refactor, research, testing, review, docs, infra, design
3. Scope assessment — TRIVIAL / LOW / MEDIUM / HIGH / EPIC
4. ECC component matching — maps to right skills, agents, commands
5. Missing context detection — flags up to 3 critical gaps, asks user
6. Workflow & model recommendation

**Routing Decision**:
- Intent = **code** → continue to Phase 2
- Intent = **documentation** → skip to Phase 4-DOCS
- Intent = **both** → full pipeline + doc agents

**Output**: Structured spec with problem statement, requirements, acceptance criteria, constraints.

**User Gate**:
```
Options:
  (1) Approve — proceed with this spec
  (2) Refine — adjust requirements
  (3) Cancel — stop pipeline
```

---

## Phase 2: Product Validation

**Purpose**: Validate we're solving the right problem before investing in design.

**Skills/Agents**:
- `/product-lens` (everything-claude-code)

**Process**:
1. Challenge assumptions — is this the right thing to build?
2. Identify user personas and use cases
3. Flag scope creep risks
4. Run product diagnostics

**User Gate**:
```
Options:
  (1) Approve — proceed to brainstorm
  (2) Refine — update requirements based on findings
  (3) Pivot — change direction entirely
  (4) Cancel — stop the pipeline
```

---

## Phase 3: Brainstorm

**Purpose**: Explore multiple solution approaches, let user pick direction.

**Skills/Agents**:
- `/brainstorm` (superpowers) — 9-step exploration process
- `spec-document-reviewer` agent (superpowers) — validates spec after brainstorm

**Process**:
1. Explore context — read codebase, constraints
2. Offer visual companion (browser mockups for UI work)
3. Ask clarifying questions
4. Propose 3+ approaches with trade-offs
5. Present design direction
6. Write spec document
7. Spec reviewer validates spec quality
8. User reviews and approves

**User Gate**:
```
Options:
  (1) Approve approach N — proceed to planning
  (2) Explore more — generate additional approaches
  (3) Combine — merge aspects of multiple approaches
  (4) Pivot — go back to Phase 1 with new direction
```

---

## Phase 4: Architecture & Planning

**Purpose**: Create detailed, actionable implementation plan.

**Skills/Agents**:
- `/blueprint` (everything-claude-code) — multi-session construction plan
  - Adversarial review agent validates plan
- `/writing-plans` (superpowers) — bite-sized task breakdown
  - `plan-document-reviewer` agent validates plan quality
- `architect` agent (ECC) — architecture decisions
- `planner` agent (ECC) — implementation ordering

**Process**:
1. Blueprint generates 1-PR-sized steps with dependency graph
2. Writing-plans expands into 2-5 min tasks with code blocks
3. Plan reviewer validates for completeness, no placeholders
4. Plan saved to `docs/superpowers/plans/` or `plans/`

**User Gate**:
```
Options:
  (1) Approve plan — proceed to sprint setup
  (2) Adjust scope — modify/add/remove tasks
  (3) Different approach — go back to brainstorm
  (4) Cancel — stop pipeline
```

---

## Phase 4-DOCS: Documentation Flow

**Purpose**: Dedicated pipeline for documentation-only prompts.

**Skills/Agents**:
- `doc-writer` agent — creates technical documentation
- `doc-reviewer` agent — validates accuracy against codebase
- `confluence-writer` agent — Confluence-specific publishing
- `doc-updater` agent (ECC) — codemap and doc freshness

**Process**:
1. Determine doc type: architecture, API, guide, runbook, ADR, README
2. doc-writer generates content adapted to target platform format
3. doc-reviewer checks accuracy, completeness, stale references
4. Publish to configured docs provider
5. Skip to Phase 8

**User Gate**:
```
Options:
  (1) Approve — publish document
  (2) Revise — request specific changes
  (3) Cancel — discard draft
```

---

## Phase 5: Sprint Setup

**Purpose**: Create sprint infrastructure in the configured ticket provider.

**Skills/Agents**:
- `sprint-manager` agent (agentic-sdlc)
- Ticket provider adapter (GitHub Issues / Jira / Azure Boards / GitLab Issues)

**Process**:
1. Create sprint/milestone/iteration via provider
2. Create standard labels (feature, bug, chore, infra, docs, epic, blocked, in-progress, ready)
3. Create tickets from plan — each with acceptance criteria, dependencies, agent assignment
4. Create epic issues for major feature groups
5. Display sprint board

**User Gate**:
```
Sprint Board:
  Sprint 1 - <Name> | Due: <date> | 0/N tickets

  TODO
  ────
  #1  feat: <title>    [feature]
  #2  feat: <title>    [feature]
  ...

Options:
  (1) Approve — proceed to execution
  (2) Modify — add/remove/reorder tickets
  (3) Adjust plan — go back to Phase 4
```

---

## Phase 6: Sprint Execution

**Purpose**: Execute tickets using parallel developer agents.

**Skills/Agents**:
- `/team-builder` (ECC) — compose agent teams per ticket type
- `/devfleet` (ECC) — parallel agent dispatch in isolated worktrees
- `/subagent-driven-development` (superpowers) — same-session alternative
- `/dispatching-parallel-agents` (superpowers) — independent batch dispatch
- `/orchestrate` (ECC) — sequential dependent chains with handoff
- `/tdd` (ECC) + `tdd-guide` agent — test-driven development
- `/search-first` (ECC) — find existing solutions before coding
- `/verification-loop` (ECC) — build, test, lint, typecheck
- `ticket-worker` agent (agentic-sdlc) — end-to-end ticket implementation

**Agent Mapping**:

| Ticket Label | Primary Agent | Supporting Agent | Skill |
|-------------|---------------|-----------------|-------|
| feature | ticket-worker | tdd-guide | /tdd |
| bug | build-error-resolver | code-reviewer | /systematic-debugging |
| docs | doc-writer + doc-updater | doc-reviewer | /sdlc-docs |
| chore | ticket-worker | — | — |
| infra | architect | planner | /plan |
| security | security-reviewer | — | /security-review |
| e2e | e2e-runner | — | /e2e |
| performance | performance-optimizer | — | /benchmark |

**Stack-specific reviewers** (auto-selected):
Python, TypeScript, Go, Rust, Java, Kotlin, C++, Flutter

**Execution Pattern**:
1. Build dependency graph from ticket references
2. Group independent tickets into parallel batches
3. Dispatch batch → agents work in isolated worktrees
4. Each agent: read ticket → branch → TDD → verify → PR → comment on ticket
5. After batch: checkpoint with user

**User Gate (per batch)**:
```
Batch N complete: X/Y missions done

Options:
  (1) Continue — proceed to next batch
  (2) Review — inspect specific PRs before continuing
  (3) Adjust — modify plan for remaining tickets
  (4) Pause — stop execution, resume later with /sprint run
```

---

## Phase 7: Quality Gates

**Purpose**: Multi-layer review of all PRs before merge.

**Skills/Agents**:

| Check | Skill/Agent | Source |
|-------|------------|--------|
| Verification | `/verification-before-completion` | superpowers |
| Verification | `/verification-loop` | ECC |
| E2E Tests | `/e2e` + `e2e-runner` | ECC |
| Security | `/security-review` + `security-reviewer` | ECC |
| Code Review L1 | `code-reviewer` agent | ECC |
| Spec Compliance | `spec-reviewer` agent | superpowers |
| Code Quality | `code-quality-reviewer` agent | superpowers |
| Stack Review | `{lang}-reviewer` agent | ECC |
| Simplification | `/simplify` | code-simplifier |
| Doc Review | `doc-reviewer` + `doc-updater` | agentic-sdlc + ECC |

**User Gate**:
```
Quality Gate Results:
  PR #6  Hero Section       VERDICT: ✅ PASS
  PR #7  Features Grid      VERDICT: ✅ PASS (1 suggestion)
  PR #8  Pricing Table      VERDICT: ✅ PASS

Options:
  (1) Approve all — proceed to merge
  (2) Fix suggestions — address feedback, re-run gates
  (3) Request changes — provide specific feedback
  (4) Re-review — run quality gates again
```

---

## Phase 8a: Merge

**Purpose**: Merge approved PRs to main branch.

**User Gate**:
```
Options:
  (1) Merge all — squash merge all PRs
  (2) Merge selected — choose which PRs
  (3) Hold — keep PRs open
  (4) Request changes — go back to Phase 7
```

---

## Phase 8b: Sprint Close & Retrospective

**Purpose**: Close sprint, publish report, capture learnings.

**Skills/Agents**:
- `confluence-writer` / docs provider — publish sprint report
- `claude-md-manager` — update CLAUDE.md
- `/learn-eval` (ECC) — capture reusable patterns

**Process**:
1. Close sprint/milestone via ticket provider
2. Generate velocity report
3. Publish to docs provider
4. Update CLAUDE.md with new project context
5. Retrospective with user

**User Gate**:
```
Sprint Complete!

Retrospective:
  1. What went well?
  2. What should change?
  3. Patterns to save?

Your feedback (or skip):
```

---

## Gate Options (Consistent Across All Phases)

Every gate offers these base options:

| Option | Effect |
|--------|--------|
| **(1) Approve** | Proceed to next phase |
| **(2) Refine** | Update output, re-run current phase |
| **(3) Pivot** | Go back to a previous phase with new direction |
| **(4) Cancel** | Stop pipeline (work preserved in tickets/branches) |

**Nothing ships without explicit user approval at every step.**
