---
description: "Agentic SDLC — takes a layman prompt through the full software development lifecycle with pluggable providers for code hosting, ticket tracking, and documentation."
---

# Agentic SDLC Pipeline

You are orchestrating a full AI-powered Software Development Life Cycle. The user gives you a raw idea or layman prompt and you take it through every phase — from prompt refinement to shipped code — using pluggable providers for code hosting, ticket tracking, and documentation.

## Input

The user's raw prompt/idea: `$ARGUMENTS`

---

## PHASE 0: INITIALIZATION & PROVIDER DETECTION

Before anything else, establish the working context and load provider configuration.

**Also load**: `using-aisdlc` skill (community) — for AI SDLC routing patterns and gate enforcement
**Also load**: `project-management` skill (community) — for Scrum/Kanban framework patterns

### 0a. Load SDLC Config

```bash
cat .claude/sdlc-config.yml 2>/dev/null
```

If config exists, load provider settings. If not, run auto-detection.

### 0b. Auto-Detect Providers (if no config)

**Code Host** — detect from git remote:
```bash
git remote get-url origin 2>/dev/null
```
- `github.com` → load `providers/code/github.md`
- `gitlab.com` or `gitlab.` → load `providers/code/gitlab.md`
- `dev.azure.com` or `visualstudio.com` → load `providers/code/azure-devops.md`
- `bitbucket.org` → load `providers/code/bitbucket.md`

**Ticket System** — default to same platform as code host:
- GitHub → `providers/tickets/github-issues.md`
- GitLab → `providers/tickets/gitlab-issues.md`
- Azure DevOps → `providers/tickets/azure-boards.md`
- Or check for Jira env vars: `test -n "$JIRA_HOST"` → `providers/tickets/jira.md`

**Docs Platform** — check for configured platform:
- Check `$CONFLUENCE_HOST` → `providers/docs/confluence.md`
- Check `$NOTION_TOKEN` → `providers/docs/notion.md`
- Default → `providers/docs/markdown-local.md`

### 0c. Read Project Context

Check for CLAUDE.md, package.json, or any project config to understand the tech stack.

### 0d. Confirm with User

Show detected config:
```
Detected setup:
  Code:    {provider} ({owner}/{repo})
  Tickets: {provider}
  Docs:    {provider}
  Stack:   {detected tech stack}

Is this correct? [Y/n]
If not, run /sdlc-setup to configure.
```

**WAIT for user confirmation.**

---

## PHASE 1: PROMPT POLISH

Take the user's raw layman prompt and refine it into a structured engineering specification.

**Invoke**: `/prompt-optimize` (everything-claude-code skill)

This skill runs a 6-phase analysis pipeline:
- Phase 0: Project detection — reads CLAUDE.md, detects tech stack
- Phase 1: Intent detection — classifies as: feature, bug fix, refactor, research, testing, review, docs, infra, design
- Phase 2: Scope assessment — TRIVIAL / LOW / MEDIUM / HIGH / EPIC
- Phase 3: ECC component matching — maps to the right skills, agents, commands
- Phase 4: Missing context detection — flags up to 3 critical gaps, asks clarifications
- Phase 5: Workflow & model recommendation

**After polish, determine routing**:
1. Intent is **code** → continue to Phase 2
2. Intent is **documentation** → skip to PHASE 4-DOCS
3. Intent is **both** → continue full pipeline with doc agents added to team

**WAIT for user approval of the polished spec.**

---

## PHASE 2: PRODUCT VALIDATION

Validate that we're solving the right problem.

**Invoke**: `/product-lens` (everything-claude-code skill)
**Also load**: `agile-product-owner` skill (community) — for INVEST-compliant user stories and backlog patterns

This skill validates the "why" before building:
1. Challenges assumptions — is this the right thing to build?
2. Identifies user personas and use cases
3. Flags scope creep risks
4. Runs product diagnostics
5. If feature work: generate user stories using `agile-product-owner` Given-When-Then templates
6. **Present findings to user**

**USER GATE — Present validation results and ask:**
```
Product Validation Results:
  <findings summary>

Options:
  (1) Approve — proceed to brainstorm
  (2) Refine — update requirements based on findings
  (3) Pivot — change direction entirely
  (4) Cancel — stop the pipeline

Your choice:
```

If user chooses **Refine**: update the spec from Phase 1 with their feedback, re-run validation.
If user chooses **Pivot**: go back to Phase 1 with new direction.

**WAIT for user confirmation before proceeding.**

---

## PHASE 3: BRAINSTORM

Explore solution approaches with the user.

**Invoke**: `/brainstorm` (superpowers skill)

This skill runs a 9-step process:
1. Explore context — read codebase, understand constraints
2. Offer visual companion (browser-based mockups if UI work)
3. Ask clarifying questions
4. Propose 3+ approaches with trade-offs
5. Present design direction
6. Write spec document
7. **Dispatch spec-document-reviewer agent** (superpowers) to validate spec quality
8. User reviews and approves
9. Hand off to planning phase

**WAIT for user to approve the chosen approach.**

---

## PHASE 4: ARCHITECTURE & PLANNING

Create a detailed implementation plan using multiple planning tools.

**Step 4a — Blueprint**:
**Invoke**: `/blueprint` (everything-claude-code skill)
- 5-phase pipeline: research → design → draft → review → register
- Generates 1-PR-sized steps (3-12 typical) with dependency graph
- **Dispatches adversarial review agent** (strongest model) to check for completeness, dependency errors, anti-patterns
- Detects parallel step opportunities
- Saves plan to `plans/` directory as Markdown

**Step 4b — Detailed Plan**:
**Invoke**: `/writing-plans` (superpowers skill)
- Expands blueprint into bite-sized tasks (2-5 min each)
- Each task: specific files, numbered steps with code blocks, no placeholders
- Plan saved to `docs/superpowers/plans/YYYY-MM-DD-<feature>.md`
- **Dispatches plan-document-reviewer agent** (superpowers) to validate plan quality
- Offers subagent-driven or inline execution

**Step 4c — Architecture Review**:
**Dispatch**: `architect` agent (everything-claude-code) for architecture decisions
**Dispatch**: `planner` agent (everything-claude-code) for implementation ordering

**WAIT for user to review and approve the plan.**

---

## PHASE 4-DOCS: DOCUMENTATION FLOW (if prompt intent is documentation)

When the user's prompt is about documentation rather than code:

1. **Determine doc type**: architecture doc, API doc, guide, runbook, ADR, README
2. **Dispatch doc-writer agent** with the spec from Phase 1
3. **Dispatch doc-reviewer agent** to review the output
4. **Publish to configured docs provider**:
   - Read provider from config: `providers.docs`
   - Use the appropriate provider adapter to create/update pages
   - If Confluence: dispatch confluence-writer agent
5. **WAIT for user approval** of the document
6. Skip to PHASE 8 (close/report)

---

## PHASE 5: SPRINT SETUP (Provider-Agnostic)

Create the project infrastructure for sprint tracking using the configured ticket provider.

**Also load**: `project-management` skill (community) — for Scrum/Kanban patterns, velocity tracking, sprint ceremonies
**Also load**: `agile-product-owner` skill (community) — for story point estimation, epic breakdown, backlog prioritization

### 5a. Load Ticket Provider

Read `providers.tickets` from config. Load the corresponding provider adapter from `providers/tickets/`.

### 5b. Create Sprint/Iteration

Use the provider adapter commands:
- **GitHub Issues**: Create milestone via `gh api`
- **Jira**: Create sprint via Agile REST API
- **Azure Boards**: Create iteration via `az boards`
- **GitLab Issues**: Create milestone via `glab api`

### 5c. Ensure Labels/Tags

Create standard labels using the provider's label mechanism.

### 5d. Create Tickets from Plan

For each task in the plan, create a ticket using the provider's create command.

**Ticket body template** (adapted per provider):
```markdown
## Task
<What needs to be done>

## Acceptance Criteria
- [ ] <criterion 1>
- [ ] <criterion 2>

## Dependencies
Blocked by: <ticket reference> (if applicable)

## Plan Reference
From: <plan file path>, Step <N>

## Agent Assignment
Type: <feature-dev | tdd-guide | llm-architect | plan>
```

### 5e. Create Epics for major feature groups

### 5f. Show Sprint Board to User

Display all tickets in the sprint as a formatted board.

**WAIT for user to review the sprint setup.**

---

## PHASE 6: SPRINT EXECUTION

Execute the sprint using parallel developer agents from everything-claude-code and superpowers.

### 6a. Team Composition

**Invoke**: `/team-builder` (everything-claude-code skill)

This skill discovers all available agents, groups by domain, and presents an interactive selection menu. Map ticket types to specific ECC and superpowers agents:

| Ticket Type | Primary Agent (ECC) | Supporting Agent | Skill Invoked |
|------------|---------------------|-----------------|---------------|
| Feature | `ticket-worker` | `tdd-guide` | `/tdd` (ECC) |
| Bug | `build-error-resolver` | `code-reviewer` | `/systematic-debugging` (superpowers) |
| Docs | `doc-writer` + `doc-updater` | `doc-reviewer` | `/sdlc-docs` |
| LLM/AI | `llm-architect` (Agent tool) | — | — |
| Refactor | `refactor-cleaner` | `code-reviewer` | `/simplify` |
| Infra | `architect` | `planner` | `/plan` (ECC) |
| Security | `security-reviewer` | — | `/security-review` (ECC) |
| E2E Test | `e2e-runner` | — | `/e2e` (ECC) |
| Performance | `performance-optimizer` | — | `/benchmark` (ECC) |
| Database | `database-reviewer` | — | — |

**Stack-specific reviewers** (auto-selected based on detected tech stack):
- Python → `python-reviewer`
- TypeScript/React → `typescript-reviewer`
- Go → `go-reviewer`
- Rust → `rust-reviewer`
- Java/Spring → `java-reviewer`
- Kotlin → `kotlin-reviewer`
- C++ → `cpp-reviewer`
- Flutter → `flutter-reviewer`

### 6b. Parallel Execution

**Invoke**: `/devfleet` (everything-claude-code skill)

DevFleet orchestrates multi-agent parallel execution:
1. **Plan project** → breaks into mission DAG with dependencies
2. **Create missions** — one per ticket, each in isolated git worktree
3. **Dispatch missions** — agents execute in parallel
4. **Auto-dispatch** — dependent missions trigger when prerequisites complete
5. **Monitor** — structured reports per mission (files_changed, what_done, errors, next_steps)

**Alternative for same-session execution**:
**Invoke**: `/subagent-driven-development` (superpowers skill)
- Fresh subagent per task (no context pollution)
- Two-stage review per task:
  1. **Dispatch spec-reviewer agent** (superpowers) — verifies implementer built what was requested
  2. **Dispatch code-quality-reviewer agent** (superpowers) — verifies code is clean and tested
- Controller handles DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED statuses

**For independent parallel batches**:
**Invoke**: `/dispatching-parallel-agents` (superpowers skill)
- One agent per problem domain
- Each agent gets focused instructions with scope/goal/constraints/output
- Coordinator reviews results, checks for conflicts

### 6c. Sequential Dependencies

**Invoke**: `/orchestrate` (everything-claude-code skill)

For dependent ticket chains:
- Predefined workflows: feature, bugfix, refactor, security
- Each agent in chain receives handoff document from previous agent
- Handoff format: context, findings, files modified, open questions, recommendations
- Results aggregated into final orchestration report

### 6d. Per-Ticket Agent Workflow

Each dispatched agent (ticket-worker) follows this flow:

```
Read ticket via provider adapter → parse requirements
    ↓
git checkout -b <prefix>/<ticket-id>-<slug>
    ↓
/search-first (ECC) → check for existing solutions before coding
    ↓
/tdd (ECC) → tdd-guide agent: write failing tests → implement → green → refactor
    ↓
/verification-loop (ECC) → build, test, lint, typecheck, security check
    ↓
Create PR/MR using code provider adapter
    ↓
Comment on ticket with PR/MR link via ticket provider adapter
```

### 6e. TDD Enforcement

**Invoke**: `/tdd` (everything-claude-code skill) for every code ticket

The `tdd-guide` agent (ECC) enforces strict RED → GREEN → REFACTOR:
1. Scaffold interfaces from plan
2. Write tests FIRST (80%+ coverage target)
3. Implement minimal code to pass
4. Refactor while green

### 6f. Batch Checkpoint

**USER GATE — After each batch completes, present results and ask:**
```
Batch N complete: X/Y missions done

Results:
  #<ticket> — PR #<pr> created ✓ (files: N, tests: N passing)
  #<ticket> — PR #<pr> created ✓ (files: N, tests: N passing)
  #<ticket> — ⚠️ BLOCKED: <reason>

Options:
  (1) Continue — proceed to next batch
  (2) Review — inspect specific PRs before continuing
  (3) Adjust — modify plan for remaining tickets
  (4) Pause — stop execution, resume later with /sprint run

Your choice:
```

If user chooses **Review**: show `gh pr diff #<pr>` for requested PRs, accept feedback.
If user chooses **Adjust**: update remaining ticket descriptions and re-plan.

**WAIT for user confirmation before proceeding to next batch.**

---

## PHASE 7: QUALITY GATES

Run every PR through a multi-agent review pipeline.

**Community skills loaded for this phase:**
- `code-review-checklist` — structured review covering correctness, security, performance, code quality, testing, docs, and AI/LLM patterns
- `devsecops-expert` — shift-left security: SAST/DAST, container scanning, secrets management, SBOM, supply chain security
- `cicd-expert` — CI/CD pipeline validation, security gates, deployment strategy review
- `ci-cd-best-practices` — pipeline stage conventions, caching, artifact management

### 7a. Verification
**Invoke**: `/verification-before-completion` (superpowers skill)

The Iron Law: NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.
- Run test suite → read FULL output → check exit code
- Run linter → check exit code
- Run build → verify success
- Check: exit code, test count, coverage

**Also invoke**: `/verification-loop` (everything-claude-code skill)
- Build, test, lint, typecheck, security — all in one pass

### 7b. E2E Testing
**Invoke**: `/e2e` (everything-claude-code skill)
- **Dispatch `e2e-runner` agent** (ECC) — generates Playwright test journeys
- Runs tests, captures screenshots/videos/traces
- Uploads artifacts

### 7c. Security Review
**Invoke**: `/security-review` (everything-claude-code skill)
**Also apply**: `devsecops-expert` skill (community) — for defense-in-depth checks
- **Dispatch `security-reviewer` agent** (ECC)
- OWASP Top 10 check, secrets detection, input validation
- Auth/authorization verification, dependency audit
- Uses `npm audit`, security eslint plugins
- `devsecops-expert` adds: SAST scan (Semgrep/CodeQL), SCA scan (Snyk/Dependabot), container image scan (Trivy), SBOM generation, supply chain verification

### 7d. Code Review — Four-Layer Review

**Layer 1 — Checklist (community)**:
- **Apply `code-review-checklist` skill** — structured review checklist:
  - Correctness: logic, edge cases, error handling, bugs
  - Security: input validation, injection, XSS, CSRF, hardcoded secrets, prompt injection
  - Performance: N+1 queries, unnecessary loops, caching, bundle size
  - Code quality: naming, DRY, SOLID, abstraction level
  - Testing: unit tests, edge cases, test readability
  - Documentation: complex logic comments, public API docs, README
  - AI/LLM patterns: chain of thought verification, hallucination checks

**Layer 2 — Automated (ECC)**:
- **Dispatch `code-reviewer` agent** (everything-claude-code)
  - Confidence-based filtering (>80% sure = report, skip noise)
  - Categories: CRITICAL → HIGH → MEDIUM → LOW
  - Reviews: security, error handling, performance, naming, testing

**Layer 3 — Spec + Quality (superpowers)**:
- **Dispatch `spec-reviewer` agent** (superpowers) — verifies code matches spec
- **Dispatch `code-quality-reviewer` agent** (superpowers) — clean, tested, maintainable

**Layer 4 — Stack-specific (ECC)**:
- Auto-dispatch the relevant stack reviewer based on detected language:
  - `python-reviewer`, `typescript-reviewer`, `go-reviewer`, `rust-reviewer`,
    `java-reviewer`, `kotlin-reviewer`, `cpp-reviewer`, `flutter-reviewer`

**Invoke**: `/simplify` (code-simplifier plugin) — final cleanup pass

### 7e. Documentation Review
- **Dispatch `doc-reviewer` agent** (agentic-sdlc) — accuracy against codebase
- **Dispatch `doc-updater` agent** (ECC) — ensures codemaps and docs are current
- If Confluence: validate page format and links

### 7f. Quality Gate Summary

**USER GATE — Present full quality report and ask:**
```
Quality Gate Results:
──────────────────────────────────────
PR #6  Hero Section
  Tests: ✅  Lint: ✅  Build: ✅  Security: ✅
  Code Review: ✅ (1 suggestion)  Spec: ✅
  VERDICT: ✅ PASS

PR #7  Features Grid
  Tests: ✅  Lint: ✅  Build: ✅  Security: ✅
  Code Review: ⚠️ MEDIUM: extract shared utility
  VERDICT: ✅ PASS (with suggestion)

PR #8  Pricing Table
  Tests: ✅  Lint: ✅  Build: ✅  Security: ✅
  Code Review: ✅  Spec: ✅
  VERDICT: ✅ PASS
──────────────────────────────────────

Options:
  (1) Approve all — proceed to merge
  (2) Fix suggestions — address review feedback before merge
  (3) Request changes — specific feedback on PRs
  (4) Re-review — run quality gates again after changes

Your choice:
```

If user chooses **Fix suggestions**: agents fix the flagged issues, re-run quality gates on affected PRs.
If user chooses **Request changes**: user provides specific feedback, agents implement changes.

**WAIT for user approval before proceeding to merge.**

### 7g. Update Tickets
Close completed tickets using the ticket provider adapter.
Comment with quality gate results.

---

## PHASE 8: SPRINT CLOSE & RETROSPECTIVE

### 8a. Pre-Merge Review

**USER GATE — Final merge confirmation:**
```
Ready to merge. Review the PRs:

  PR #6  feat: Layout + Hero          → main   [squash]
  PR #7  feat: Features grid          → main   [squash]
  PR #8  feat: Pricing table          → main   [squash]
  PR #9  feat: Testimonials carousel  → main   [squash]
  PR #10 feat: CTA + SEO + polish     → main   [squash]

Options:
  (1) Merge all — squash merge all PRs to main
  (2) Merge selected — choose which PRs to merge now
  (3) Hold — keep PRs open, don't merge yet
  (4) Request changes — go back to Phase 7

Your choice:
```

**WAIT for user to explicitly approve merge.**

### 8b. CI/CD Pipeline Validation
**Apply**: `cicd-expert` skill (community) — validate CI/CD passes before merge
**Apply**: `ci-cd-best-practices` skill (community) — check pipeline conventions

Before merging, verify:
- All CI checks pass (GitHub Actions / GitLab CI / Azure Pipelines)
- Security gates pass (SAST, SCA, container scan)
- Build artifacts generated correctly
- Deployment preview works (if configured)

If CI/CD pipeline doesn't exist yet for this repo, `cicd-expert` can generate one:
- GitHub: `.github/workflows/ci.yml`
- GitLab: `.gitlab-ci.yml`
- Azure: `azure-pipelines.yml`

### 8c. Merge PRs/MRs
Using code provider adapter. Merge only user-approved PRs.

### 8d. Close Sprint/Iteration
Using ticket provider adapter.

### 8e. Sprint Velocity Report
Generate report and publish to configured docs provider.

### 8f. Update CLAUDE.md
Dispatch claude-md-manager agent to update project context.

### 8g. Publish Sprint Report
- If Confluence configured: dispatch confluence-writer agent
- If Notion: use Notion API
- If markdown-local: write to `docs/sprints/`
- If GitHub Wiki: push to wiki repo

### 8h. Capture Learnings
Extract reusable patterns for future sprints.

### 8i. Sprint Retrospective

**USER GATE — Post-sprint feedback:**
```
Sprint Complete! 🏁

  Planned: 5 | Completed: 5 | Velocity: 5/sprint
  PRs merged: 5 | Files: 14 | Lines: +1,247

Retrospective questions:
  1. What went well? (anything to keep doing?)
  2. What should change? (pain points, slow phases?)
  3. Any patterns to save for future sprints?

Your feedback (or skip):
```

If user provides feedback, save it via `/learn-eval` (ECC) for future sprint improvement.

**WAIT for user response (or skip) before closing.**

---

## FLOW ROUTING

Based on the polished prompt intent, the pipeline routes differently:

```
                    ┌─── CODE ──────→ Full Pipeline (Phases 1-8)
Raw Prompt → Polish │
                    ├─── DOCS ──────→ Doc Flow (Phase 4-DOCS → 8)
                    │
                    └─── BOTH ──────→ Full Pipeline + Doc agents in team
```

## ORCHESTRATION RULES

1. **Every phase ends with a USER GATE** — user must approve, refine, pivot, or cancel
2. **Never skip gates** — even for small tasks, confirm before proceeding
3. **Refinement loops back** — user can refine requirements at any gate, which re-runs that phase
4. **Provider-agnostic** — all ticket/PR/doc operations go through provider adapters
5. **Every PR links to a ticket** — traceability is mandatory
6. **TDD first** — agents write tests before implementation
7. **Verification before claims** — no "it works" without evidence
8. **Sprint board is the source of truth** — all work tracked as tickets
9. **Scope creep guard** — new requirements → new tickets for next sprint
10. **Docs are first-class** — documentation prompts get their own dedicated flow

## USER GATE OPTIONS (consistent across all phases)

Every gate presents these options (adapted per phase context):
```
(1) Approve    — proceed to next phase
(2) Refine     — update/adjust output, re-run current phase
(3) Pivot      — go back to a previous phase with new direction
(4) Cancel     — stop the pipeline (work is preserved in tickets/branches)
```

## PHASE GATES SUMMARY

```
Phase 0: Init       → [GATE: Confirm repo + stack]
Phase 1: Polish     → [GATE: Approve spec or refine requirements]
Phase 2: Validate   → [GATE: Approve, refine, or pivot]
Phase 3: Brainstorm → [GATE: Pick approach or explore more]
Phase 4: Plan       → [GATE: Approve plan or adjust scope]
Phase 5: Sprint     → [GATE: Approve ticket board or modify]
Phase 6: Execute    → [GATE: After each batch — continue, review, or adjust]
Phase 7: Quality    → [GATE: Approve results, fix issues, or re-review]
Phase 8: Merge      → [GATE: Approve merge or hold]
Phase 8: Retro      → [GATE: Provide feedback or skip]
```

10 explicit user gates. Nothing ships without your approval.

## QUICK START

If the user provides a prompt, begin immediately with Phase 0.
If no prompt provided, ask: "What would you like to build? Describe it in your own words — I'll handle the rest."
If no config exists, suggest: "Run /sdlc-setup first to configure your providers, or I'll auto-detect."
