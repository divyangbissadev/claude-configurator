# Superpowers + Configurator Integration Guide

## Overview

The configurator and [Superpowers](https://github.com/obra/superpowers) are complementary systems that together provide a complete enterprise development experience.

| System | What It Does | Scope |
|--------|-------------|-------|
| **Superpowers** | Enforces development methodology (brainstorm → plan → TDD → review) | Per-developer plugin |
| **Configurator** | Provides stack-specific knowledge (agents, rules, anti-patterns) | Per-repo submodule |

Superpowers controls **how** you develop. The configurator controls **what** Claude knows about your codebase.

## The Combined Workflow

```
Developer: "Add a cancel order endpoint"
     │
     ▼
┌─────────────────────────────────────────────────────────┐
│  SUPERPOWERS: brainstorming skill activates              │
│  ─ Asks clarifying questions one at a time               │
│  ─ Proposes 2-3 approaches with trade-offs               │
│  ─ Presents design section by section                    │
│                                                         │
│  CONFIGURATOR provides:                                  │
│  ─ api-designer agent (REST conventions, HTTP methods)   │
│  ─ Stack anti-patterns ("no business logic in controllers│
│  ─ CLAUDE.extra.md (your architecture, extension points) │
└──────────────────────┬──────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────┐
│  SUPERPOWERS: writing-plans skill activates               │
│  ─ Breaks work into 2-5 minute tasks                     │
│  ─ Exact file paths, complete code, test commands         │
│                                                         │
│  CONFIGURATOR provides:                                  │
│  ─ planner agent (knows your patterns)                   │
│  ─ Stack rules (constructor injection, DTO records)      │
│  ─ vars.test_command, vars.commit_format                 │
└──────────────────────┬──────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────┐
│  SUPERPOWERS: using-git-worktrees skill                   │
│  ─ Creates isolated branch                               │
│  ─ Clean workspace for implementation                    │
└──────────────────────┬──────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────┐
│  SUPERPOWERS: subagent-driven-development                 │
│  ─ Fresh subagent per task                               │
│  ─ Two-stage review after each task                      │
│                                                         │
│  For each task:                                          │
│  ┌───────────────────────────────────────────┐           │
│  │ SUPERPOWERS: TDD skill enforces           │           │
│  │  1. Write failing test (RED)              │           │
│  │  2. Write minimal implementation (GREEN)  │           │
│  │  3. Refactor (IMPROVE)                    │           │
│  │                                           │           │
│  │ CONFIGURATOR provides:                    │           │
│  │  ─ tdd-guide agent (test conventions)     │           │
│  │  ─ Stack testing rules (JUnit 5, fixtures)│           │
│  │  ─ tdd-conventions rule (test first)      │           │
│  └───────────────────────────────────────────┘           │
│                                                         │
│  After each task:                                        │
│  ┌───────────────────────────────────────────┐           │
│  │ SUPERPOWERS: spec compliance review       │           │
│  │  ─ Did we build what was requested?       │           │
│  │                                           │           │
│  │ SUPERPOWERS: code quality review          │           │
│  │  ─ Is the implementation well-built?      │           │
│  │                                           │           │
│  │ CONFIGURATOR provides:                    │           │
│  │  ─ code-reviewer agent (multi-pass)       │           │
│  │  ─ {stack}-reviewer (Spring/Go/Rust/etc.) │           │
│  │  ─ security-reviewer (OWASP, injection)   │           │
│  │  ─ Stack anti-patterns for scanning       │           │
│  └───────────────────────────────────────────┘           │
└──────────────────────┬──────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────┐
│  SUPERPOWERS: verification-before-completion              │
│  ─ Run verification commands, confirm output             │
│                                                         │
│  CONFIGURATOR provides:                                  │
│  ─ /validate command (runs vars.ci_command)              │
│  ─ ci-conventions rule (all checks must pass)            │
└──────────────────────┬──────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────┐
│  SUPERPOWERS: finishing-a-development-branch              │
│  ─ Merge, PR, keep, or discard options                   │
│                                                         │
│  CONFIGURATOR provides:                                  │
│  ─ git-workflow rule (commit format, branch naming)      │
│  ─ vars.commit_format for consistent messages            │
└─────────────────────────────────────────────────────────┘
```

## Installation

### Prerequisites

1. **Claude Code** installed
2. **Superpowers** plugin installed:
   ```
   /plugin install superpowers@claude-plugins-official
   ```
3. **Configurator** submodule in your repo (see main README)

### Verification

Superpowers skills should appear in Claude Code's skill list:
- `superpowers:brainstorming`
- `superpowers:writing-plans`
- `superpowers:executing-plans`
- `superpowers:subagent-driven-development`
- `superpowers:test-driven-development`
- `superpowers:systematic-debugging`
- `superpowers:verification-before-completion`
- `superpowers:requesting-code-review`
- `superpowers:finishing-a-development-branch`
- `superpowers:using-git-worktrees`

Configurator agents should appear via `.claude/agents/`:
- Core agents (22)
- Stack agents (varies by stack)
- Workflow agents (varies by opt-in workflows)

Both active simultaneously — no conflict, no configuration needed.

## What Each System Handles

### Superpowers owns the PROCESS

| Concern | Superpowers Skill |
|---------|-------------------|
| "Should we build this?" | `brainstorming` — explores alternatives, presents designs |
| "What's the plan?" | `writing-plans` — 2-5 min tasks with exact code |
| "How do we execute?" | `subagent-driven-development` — fresh agent per task |
| "Tests first?" | `test-driven-development` — RED-GREEN-REFACTOR enforced |
| "Is it actually done?" | `verification-before-completion` — evidence before assertions |
| "What went wrong?" | `systematic-debugging` — scientific method, trace-based |
| "Is the code good?" | `requesting-code-review` — pre-review checklist |
| "How do we merge?" | `finishing-a-development-branch` — merge/PR/cleanup options |

### Configurator owns the KNOWLEDGE

| Concern | Configurator Component |
|---------|----------------------|
| "What stack are we using?" | `stacks/{stack}/` — agents, rules, anti-patterns |
| "What are our conventions?" | `core/rules/` — git, security, testing, performance |
| "How do we build/test/lint?" | `vars` in claude-pod.yml — test_command, ci_command |
| "What mistakes do we avoid?" | `CLAUDE.stack.md` — stack-specific anti-patterns |
| "Who reviews what?" | `core/agents/` — specialized reviewers per domain |
| "How is our code organized?" | `CLAUDE.extra.md` — architecture, extensions, references |
| "What workflows do we follow?" | `workflows/` — CI gate, TDD, incident response, ADR |
| "What context do we persist?" | `hooks/` — session start/end, pre-compaction |

### Neither system duplicates the other

- Superpowers has a `brainstorming` skill but no stack-specific knowledge → configurator provides it
- Configurator has a `tdd-guide` agent but no process enforcement → Superpowers enforces TDD order
- Superpowers dispatches subagents but doesn't know your anti-patterns → configurator's rules apply
- Configurator generates CLAUDE.md but doesn't enforce reading it → Superpowers' plan generation reads it

## Scenarios

### Scenario 1: Bug Fix

```
You: "The /api/orders endpoint returns 500 when order has no items"

Superpowers activates: systematic-debugging
  Phase 1: Reproduce (get exact error)
  Phase 2: Hypothesize (form theories)
  Phase 3: Trace (follow the code path)
  Phase 4: Fix (minimal change)

Configurator provides:
  ─ debugger agent (scientific method)
  ─ {stack}-build-resolver (if build breaks)
  ─ Stack anti-patterns (catches common mistakes)
  ─ /validate command (verify fix doesn't break anything)

Superpowers activates: verification-before-completion
  ─ Run tests, confirm fix works
  ─ Evidence before claiming "fixed"
```

### Scenario 2: New Feature

```
You: "Add order cancellation with refund"

Superpowers: brainstorming → writing-plans → worktree → subagent-driven-development
Configurator: api-designer + planner + stack agents + rules + anti-patterns

Each task in the plan:
  Superpowers: TDD (write test → implement → refactor)
  Configurator: tdd-guide + stack testing conventions

After each task:
  Superpowers: spec review → code quality review
  Configurator: code-reviewer + stack-reviewer + security-reviewer

All tasks done:
  Superpowers: verification → finishing-branch
  Configurator: /validate → git-workflow rules
```

### Scenario 3: Code Review

```
You: "/review-pr"

Superpowers: requesting-code-review skill activates
  ─ Pre-review checklist
  ─ Runs implementation against plan

Configurator provides:
  ─ code-reviewer agent (multi-pass: design → line-by-line → anti-patterns)
  ─ {stack}-reviewer (Spring/Go/Rust-specific checks)
  ─ security-reviewer (OWASP, injection, credentials)
  ─ database-reviewer (if SQL involved)
  ─ Stack anti-patterns for automated scanning
```

## Configuration Tips

### 1. Don't duplicate between systems

Superpowers already enforces TDD order — you don't need the `tdd` workflow from the configurator for process enforcement. But the workflow adds `tdd-conventions` rules (test naming, independence) that Superpowers doesn't cover.

**Recommendation:** Keep both. They handle different aspects.

### 2. Use contexts with Superpowers phases

| Superpowers Phase | Configurator Context |
|---|---|
| Brainstorming | `research` (exploration, no changes) |
| Planning | `dev` (speed, focus) |
| Implementation | `dev` (TDD, small commits) |
| Review | `review` (quality, thoroughness) |

### 3. Hooks complement Superpowers' session model

Superpowers manages session workflow. Configurator hooks manage session persistence:
- `session-start.sh` loads context from previous sessions
- `session-end.sh` saves metadata
- `pre-compact.sh` checkpoints before context compaction

These run automatically — Superpowers doesn't need to know about them.

### 4. Stack agents enhance Superpowers' subagent dispatch

When Superpowers dispatches a subagent for implementation:
- The subagent inherits the `.claude/` directory with all configurator agents and rules
- Stack anti-patterns are enforced automatically via rules
- The code-reviewer subagent (dispatched by Superpowers for quality review) uses the stack-specific reviewer

No configuration needed — it works by both being present in the same repo.

## Troubleshooting

### "Superpowers skills don't see my configurator agents"

Verify `.claude/agents/` contains the generated agents:
```bash
ls .claude/agents/
```

If empty, regenerate:
```bash
.claude-configurator/bin/claude-setup generate
```

### "Superpowers brainstorming doesn't know my architecture"

Ensure `.claude-local/CLAUDE.extra.md` exists with your architecture description. The generated `CLAUDE.md` is loaded into every Claude Code session — Superpowers reads it during brainstorming.

### "Reviews don't catch stack-specific issues"

Verify your stack is correctly set in `claude-pod.yml` and the stack-specific reviewer is present:
```bash
grep "stack:" claude-pod.yml
ls .claude/agents/ | grep reviewer
```

### "I get duplicate TDD guidance"

The `tdd` workflow adds rules and a command. Superpowers enforces the TDD process. They don't conflict — rules are passive (applied when relevant), and the Superpowers skill is active (enforces ordering). If you find it redundant, exclude the `tdd` workflow:

```yaml
workflows:
  - ci-quality-gate
  # - tdd          # Superpowers handles TDD process
  - incident-response
```

But keeping both is fine — the rules add naming conventions and independence requirements that Superpowers doesn't cover.
