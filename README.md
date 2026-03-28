# jnj-claude-configurator

Enterprise-grade, template-driven Claude Code configuration generator for multi-pod organizations. Inspired by [everything-claude-code](https://github.com/affaan-m/everything-claude-code), adapted for federated team structures with layered config assembly.

---

## Table of Contents

- [What This Does](#what-this-does)
- [Greenfield Project Setup](#greenfield-project-setup)
- [Brownfield Project Setup](#brownfield-project-setup)
- [How It Works](#how-it-works)
- [Daily Developer Experience](#daily-developer-experience)
- [Customizing Your Setup](#customizing-your-setup)
  - [Changing Workflows](#changing-workflows)
  - [Adding Pod-Specific Agents](#adding-pod-specific-agents)
  - [Adding Pod-Specific Commands](#adding-pod-specific-commands)
  - [Adding Pod-Specific Rules](#adding-pod-specific-rules)
  - [Adding CLAUDE.md Sections](#adding-claudemd-sections)
  - [Excluding Default Agents](#excluding-default-agents)
  - [Customizing Hooks](#customizing-hooks)
  - [Adding MCP Integrations](#adding-mcp-integrations)
- [Updating the Configurator](#updating-the-configurator)
- [What's Included](#whats-included)
- [Adding a New Stack](#adding-a-new-stack)
- [Adding a New Workflow](#adding-a-new-workflow)
- [Architecture](#architecture)
- [CLI Reference](#cli-reference)
- [Example Templates](#example-templates)
- [FAQ](#faq)
- [Credits](#credits)

---

## What This Does

Every developer using Claude Code in your org gets a different experience — different agents, rules, conventions, and quality gates. This configurator solves that by generating a consistent, tailored `.claude/` setup for each team (pod) from shared templates.

```
┌─────────────────────────────────────────────────────────┐
│                  jnj-claude-configurator                 │
│                                                         │
│  core/          stacks/          workflows/              │
│  ├── agents/    ├── python-spark/ ├── ci-quality-gate/  │
│  ├── commands/  ├── java-spring/  ├── tdd/              │
│  ├── rules/     ├── golang/       ├── incident-response/│
│  ├── contexts/  ├── rust/         ├── adr/              │
│  ├── hooks/     ├── typescript/   └── onboarding/       │
│  └── mcp/       └── 5 more...                           │
└──────────────────────┬──────────────────────────────────┘
                       │ claude-setup generate
                       ▼
┌─────────────────────────────────────────────────────────┐
│                    Your Pod Repo                         │
│                                                         │
│  .claude/           (GENERATED — don't hand-edit)        │
│  ├── agents/        core + stack + workflow + your own   │
│  ├── commands/      core + stack + workflow + your own   │
│  ├── rules/         core + stack + workflow              │
│  ├── contexts/      dev, review, research                │
│  ├── hooks/         session lifecycle                    │
│  ├── mcp-configs/   GitHub, Azure DevOps                 │
│  └── settings.json  auto-generated permissions           │
│                                                         │
│  .claude-local/     (YOUR overrides — hand-edit these)   │
│  ├── agents/        pod-specific agents                  │
│  ├── commands/      pod-specific commands                 │
│  ├── rules/         pod-specific rules                   │
│  └── CLAUDE.extra.md  architecture, extensions, refs     │
│                                                         │
│  claude-pod.yml     (YOUR config — stack, workflows)     │
│  CLAUDE.md          (GENERATED from template + config)   │
└─────────────────────────────────────────────────────────┘
```

**One config file → full Claude Code setup, tailored to your stack.**

---

## Greenfield Project Setup

Starting a brand new project? You'll have a fully-configured Claude Code setup in under 2 minutes.

### Step 1: Create your repo and add the configurator

```bash
mkdir my-new-service && cd my-new-service
git init

# Add configurator as a submodule
git submodule add <configurator-repo-url> .claude-configurator
```

### Step 2: Run the wizard

```bash
.claude-configurator/bin/claude-setup init
```

The wizard prompts you:

```
=== Claude Code Pod Setup ===

Pod name: order-service
Team name: Platform Engineering
Pod description: Order processing microservice with event sourcing

Available stacks:
  - python-spark (PySpark, Delta Lake, Databricks pipelines)
  - java-spring (Java, Spring Boot, Maven/Gradle)
  - typescript-react (TypeScript, React, Node.js)
  - golang (Go, microservices, gRPC)
  - rust (Rust, Axum/Actix, systems programming)
  - kotlin (Kotlin, Android, Kotlin Multiplatform)
  - cpp (C++20/23, systems programming)
  - flutter (Flutter, Dart, cross-platform mobile)
  - dotnet (.NET, C#, ASP.NET Core)
  - python-django (Python, Django, Django REST Framework)
Stack: golang

Available workflows:
  - ci-quality-gate (Lint, type check, test, security scan)
  - tdd (Test-driven development)
  - incident-response (Debugging and incident triage)
  - adr (Architecture Decision Records)
  - onboarding (New developer onboarding)
Workflows (comma-separated): ci-quality-gate,tdd,adr

Repo host (github/azure-devops/gitlab): github
Commit format: feat|fix|chore: <summary>
Coverage minimum (%): 80
Primary language: go
Test command: make test
Lint command: make lint
CI command: make ci

Generated .claude/ and CLAUDE.md successfully.
```

### Step 3: Commit everything

```bash
git add .gitmodules .claude-configurator .claude/ .claude-local/ claude-pod.yml CLAUDE.md
git commit -m "feat: add Claude Code configuration"
```

### Step 4: Start building

Open Claude Code. It already knows your stack, your conventions, and your quality gates. Every agent, command, and rule is configured.

```
You: "Set up the project structure for a Go gRPC service with PostgreSQL"
```

The **planner** and **architect** agents activate with Go-specific knowledge. The **go-reviewer** catches Go anti-patterns. The **tdd-guide** enforces test-first development.

---

## Brownfield Project Setup

Joining an existing project? The configurator adapts to your existing conventions.

### Step 1: Add the configurator submodule

```bash
cd existing-project
git submodule add <configurator-repo-url> .claude-configurator
```

### Step 2: Run the wizard

```bash
.claude-configurator/bin/claude-setup init
```

Answer the prompts based on your existing project's stack and conventions.

### Step 3: Move existing Claude Code files to .claude-local/

If you already have a `.claude/` directory with custom agents or commands:

```bash
# Move pod-specific agents (keep project-specific context)
mv .claude/agents/my-custom-agent.md .claude-local/agents/

# Move pod-specific commands
mv .claude/commands/my-custom-command.md .claude-local/commands/

# Move pod-specific rules
mv .claude/rules/my-custom-rule.md .claude-local/rules/
```

### Step 4: Reference them in claude-pod.yml

```yaml
overrides:
  agents:
    include:
      - .claude-local/agents/my-custom-agent.md
  commands:
    include:
      - .claude-local/commands/my-custom-command.md
  rules:
    include:
      - .claude-local/rules/my-custom-rule.md
```

### Step 5: Add your architecture context

Create `.claude-local/CLAUDE.extra.md` with project-specific sections:

```markdown
## Architecture

[Your architecture diagram and module descriptions]

## Extension Points

[How to add new features following your patterns]

## Reference Documents

[Links to ADRs, design docs, runbooks]
```

### Step 6: Regenerate and verify

```bash
.claude-configurator/bin/claude-setup generate
```

Review the generated `CLAUDE.md` and `.claude/` directory. Everything from the configurator (core agents, stack rules, workflow commands) plus your pod-specific overrides should be present.

### Step 7: Commit

```bash
git add .gitmodules .claude-configurator .claude/ .claude-local/ claude-pod.yml CLAUDE.md
git commit -m "feat: adopt Claude Code configurator"
```

---

## How It Works

The configurator assembles your `.claude/` directory from four layers, applied in order:

```
Layer 1: core/          Always included (22 agents, 18 commands, 8 rules, ...)
    ↓
Layer 2: stacks/{X}/    Your chosen stack (language-specific agents, rules, anti-patterns)
    ↓
Layer 3: workflows/{Y}/ Your chosen workflows (opt-in commands, agents, rules)
    ↓
Layer 4: .claude-local/ Your pod-specific overrides (custom agents, commands, rules)
```

Later layers override earlier ones on filename conflict. So if `core/` and your stack both have a `testing.md` rule, the stack version wins.

### What gets generated

| Generated File | Source |
|---------------|--------|
| `.claude/agents/*.md` | core + stack + workflow agents, minus excludes, plus includes |
| `.claude/commands/*.md` | core + stack + workflow commands, minus excludes, plus includes |
| `.claude/rules/*.md` | core + stack + workflow rules, minus excludes, plus includes |
| `.claude/contexts/*.md` | core contexts (dev, review, research) |
| `.claude/hooks/*` | core hooks (session lifecycle scripts) |
| `.claude/mcp-configs/*` | core MCP configs (GitHub, Azure DevOps templates) |
| `.claude/settings.json` | generated with your test/lint/ci commands allowed |
| `CLAUDE.md` | rendered from template + your vars + stack anti-patterns + extras |

### What you hand-edit

| Your File | Purpose |
|-----------|---------|
| `claude-pod.yml` | Your pod's config (stack, workflows, overrides, vars) |
| `.claude-local/agents/*.md` | Pod-specific agents |
| `.claude-local/commands/*.md` | Pod-specific commands |
| `.claude-local/rules/*.md` | Pod-specific rules |
| `.claude-local/CLAUDE.extra.md` | Architecture, extensions, reference docs |
| `.claude/settings.local.json` | User-specific permissions (not generated) |

---

## Daily Developer Experience

Once set up, developers don't need to know the configurator exists. They just use Claude Code — and it's smart about their codebase from the first interaction.

### Typical day

| Task | What Happens | Active Agents/Commands |
|------|-------------|----------------------|
| Start session | Hook loads previous context automatically | `session-start.sh` |
| "Explain this codebase" | Guided architecture walkthrough | `onboarding-guide`, `/explore` |
| "Fix the failing build" | Minimal fix, no refactoring | `build-error-resolver`, `{stack}-build-resolver` |
| "Add a new endpoint" | Plans → TDD → implements → reviews | `planner`, `tdd-guide`, `api-designer` |
| `/tdd` | Strict red-green-refactor cycle | `tdd-guide` + tdd-conventions rule |
| `/review-pr` | Multi-pass review (design → line-by-line → anti-patterns) | `code-reviewer`, `{stack}-reviewer` |
| `/validate` | Runs your team's lint + test + CI gate | Uses `vars.test_command`, `vars.ci_command` |
| "Is this SQL safe?" | Checks injection, indexes, N+1 | `database-reviewer`, `security-reviewer` |
| `/checkpoint` | Saves state before risky operations | `pre-compact.sh` hook |
| End session | Hook saves metadata for next time | `session-end.sh` |

### Context modes

Switch Claude's behavior based on what you're doing:

| Mode | Activate | Behavior |
|------|----------|----------|
| **Dev** | "Switch to dev mode" | Speed-focused, TDD, small commits, YAGNI |
| **Review** | "Switch to review mode" | Quality-focused, thorough, confidence-scored findings |
| **Research** | "Switch to research mode" | Read-only exploration, no changes, document findings |

### Rules enforced silently

These rules apply to every interaction without you asking:

- **git-workflow** — commit conventions, branch naming, PR size limits
- **security** — no hardcoded credentials, parameterized queries, input validation
- **testing** — every code path tested, behavior over implementation
- **performance** — no O(n^2), no blocking calls, batch operations
- **patterns** — composition over inheritance, DI, explicit over implicit
- **documentation** — CLAUDE.md current, comments explain WHY not WHAT
- Plus your **stack-specific rules** (e.g., no bare `col()` in PySpark, no field injection in Spring)

---

## Customizing Your Setup

All customization happens in two places: `claude-pod.yml` (config) and `.claude-local/` (files). After any change, run:

```bash
bash -c 'CONFIGURATOR_ROOT=.claude-configurator; source $CONFIGURATOR_ROOT/lib/parse_config.sh; source $CONFIGURATOR_ROOT/lib/generate.sh; parse_config claude-pod.yml; run_generate .'
```

Or if using a remote submodule:

```bash
.claude-configurator/bin/claude-setup generate
```

### Changing Workflows

Add or remove workflows in `claude-pod.yml`:

```yaml
workflows:
  - ci-quality-gate    # Lint, test, security scan
  - tdd                # Test-driven development
  - incident-response  # Debugging and incident triage
  - adr                # Architecture Decision Records
  - onboarding         # New developer onboarding
```

Remove a line to disable that workflow. Each workflow adds its agents, commands, and rules.

### Adding Pod-Specific Agents

1. Create `.claude-local/agents/my-domain-expert.md`:

```markdown
---
name: my-domain-expert
description: >
  Domain expert for [your specific area]. Use when working on [specific context].
tools:
  - Read
  - Grep
  - Glob
  - Bash
model: opus
---

You are a **[Role]** who specializes in [domain].

## Context

[Project-specific knowledge that generic agents don't have]

## Key Rules

[Domain-specific rules and anti-patterns]
```

2. Register it in `claude-pod.yml`:

```yaml
overrides:
  agents:
    include:
      - .claude-local/agents/my-domain-expert.md
```

3. Regenerate: `claude-setup generate`

### Adding Pod-Specific Commands

1. Create `.claude-local/commands/my-workflow.md`:

```markdown
---
description: Brief description shown in command list.
---

# My Workflow

## Steps

### 1. Step Name
[What to do]

### 2. Step Name
[What to do]
```

2. Register in `claude-pod.yml` under `overrides.commands.include`.

3. Regenerate. The command appears as `/my-workflow` in Claude Code.

### Adding Pod-Specific Rules

1. Create `.claude-local/rules/my-conventions.md`:

```markdown
---
paths:
  - src/**/*.ts
---

# My Team Conventions

- Rule 1
- Rule 2
```

2. Register in `claude-pod.yml` under `overrides.rules.include`.

3. Regenerate. The rule is automatically enforced.

### Adding CLAUDE.md Sections

Create or edit `.claude-local/CLAUDE.extra.md`:

```markdown
## Architecture

[Diagrams, module descriptions, data flow]

## Domain Model

[Key entities, relationships, business rules]

## Extension Points

[How to add new features following team patterns]

## Deployment

[How to deploy, environments, rollback procedures]

## Reference Documents

### Design Doc — `@docs/design/feature-x.md`
**Read when:** Working on feature X

### Runbook — `@docs/ops/runbook.md`
**Read when:** Debugging production issues
```

This content is appended to the generated `CLAUDE.md` automatically.

### Excluding Default Agents

If a core or stack agent doesn't apply to your pod:

```yaml
overrides:
  agents:
    exclude:
      - e2e-runner           # We don't have a frontend
      - onboarding-guide     # We use a custom onboarding flow
      - database-reviewer    # No database in this service
```

Same pattern for `rules.exclude` and `commands.exclude`. Use the filename without `.md`.

### Customizing Hooks

The default hooks are in `.claude/hooks/`. To customize:

1. Create `.claude-local/hooks/hooks.json` (pod-specific hooks are not auto-merged — copy from core and modify):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "bash .claude/hooks/session-start.sh 2>/dev/null || true"
      },
      {
        "type": "command",
        "command": "echo 'Reminder: check JIRA board before starting work'"
      }
    ],
    "Stop": [
      {
        "type": "command",
        "command": "bash .claude/hooks/session-end.sh 2>/dev/null || true"
      }
    ]
  }
}
```

2. Register in overrides or manually copy to `.claude/hooks/` after generate.

### Adding MCP Integrations

MCP configs in `.claude/mcp-configs/` are templates. To use them:

1. Copy the relevant config to your Claude Code settings:

```bash
# For GitHub integration
cp .claude/mcp-configs/github.json ~/.claude/mcp-servers.json

# Edit to add your token
# "GITHUB_PERSONAL_ACCESS_TOKEN": "your-token-here"
```

2. Or create project-level MCP config in `.claude-local/mcp-configs/`:

```json
{
  "mcpServers": {
    "your-service": {
      "command": "npx",
      "args": ["-y", "@your-org/mcp-server"],
      "env": {
        "API_KEY": "${YOUR_API_KEY}"
      }
    }
  }
}
```

---

## Updating the Configurator

When the shared configurator gets new agents, commands, or stacks:

```bash
# Pull latest configurator
cd .claude-configurator && git pull origin main && cd ..

# Or update submodule reference
git submodule update --remote .claude-configurator

# Regenerate — your pod-specific overrides are preserved
.claude-configurator/bin/claude-setup sync

# Review what changed
git diff .claude/ CLAUDE.md

# Commit the update
git add .claude-configurator .claude/ CLAUDE.md
git commit -m "chore: update Claude Code configurator"
```

The `sync` command shows a diff of what changed, so you can review before committing.

---

## What's Included

### Core Agents (22) — always included

| Agent | Model | Purpose |
|-------|-------|---------|
| `accessibility-tester` | opus | WCAG compliance, screen reader compat, keyboard navigation |
| `api-designer` | opus | REST/GraphQL API design, contracts, versioning |
| `architect` | sonnet | System design review and architectural decisions |
| `build-error-resolver` | sonnet | Fix build errors with minimal changes |
| `chief-of-staff` | sonnet | Workflow orchestration and task coordination |
| `code-reviewer` | sonnet | Multi-pass code review (design, quality, security) |
| `data-engineer` | opus | ETL pipelines, data warehouse, data quality |
| `database-reviewer` | sonnet | Query optimization, schema design, DB security |
| `debugger` | sonnet | Systematic debugging using scientific method |
| `doc-updater` | sonnet | Keep documentation current with codebase |
| `docs-lookup` | sonnet | Find and retrieve relevant documentation |
| `e2e-runner` | sonnet | End-to-end test creation and maintenance |
| `loop-operator` | sonnet | Manage iterative, multi-cycle workflows |
| `migration-specialist` | opus | Schema/data migrations, version upgrades |
| `onboarding-guide` | sonnet | Help new developers understand the codebase |
| `performance-engineer` | opus | Profiling, bottleneck identification, load testing |
| `planner` | sonnet | Create comprehensive implementation plans |
| `prompt-engineer` | opus | Prompt design, evaluation, optimization for LLM features |
| `refactor-cleaner` | sonnet | Dead code removal and safe refactoring |
| `security-reviewer` | sonnet | OWASP Top 10, injection, auth, secrets review |
| `tdd-guide` | sonnet | Test-driven development specialist |
| `technical-writer` | opus | API docs, user guides, runbooks, architecture docs |

### Core Commands (18)

| Command | Purpose |
|---------|---------|
| `/build-fix` | Fix build errors minimally |
| `/checkpoint` | Save work state before risky operations |
| `/e2e` | Generate and run E2E tests |
| `/eval` | Evaluate implementation against criteria |
| `/explore` | Systematic codebase exploration |
| `/multi-execute` | Execute coordinated multi-agent waves |
| `/multi-plan` | Decompose tasks across agents |
| `/orchestrate` | Coordinate multiple agents |
| `/plan` | Create implementation plans |
| `/refactor-clean` | Remove dead code and duplicates |
| `/review-pr` | Multi-pass PR review |
| `/sessions` | View and manage session history |
| `/setup-pod` | Refine pod configuration interactively |
| `/tdd` | Red-green-refactor cycle |
| `/test-coverage` | Analyze coverage gaps |
| `/update-docs` | Update docs to match codebase |
| `/validate` | Run project quality gate |
| `/verify` | Verify implementation matches requirements |

### Core Rules (8)

| Rule | Applies To | Enforces |
|------|-----------|----------|
| `git-workflow` | All files | Commit conventions, branch naming, PR size |
| `security` | Code files | No hardcoded creds, parameterized queries, input validation |
| `testing` | Test files | Every path tested, behavior over implementation, independence |
| `documentation` | All files | CLAUDE.md current, comments explain WHY, no dead comments |
| `performance` | All files | No O(n^2), no blocking calls, batch operations |
| `patterns` | All files | Composition over inheritance, DI, explicit over implicit |
| `agents` | Agent files | Use specific agents, provide full context, review output |
| `hooks` | Hook files | Fast, idempotent, silent on success, no code modification |

### Available Stacks (10)

| Stack | Agents | Anti-Patterns | Description |
|-------|--------|---------------|-------------|
| `python-spark` | 4 (databricks-developer, databricks-architect, python-reviewer, pytorch-build-resolver) | 10 | PySpark, Delta Lake, Databricks |
| `java-spring` | 2 (spring-reviewer, java-build-resolver) | 8 | Java, Spring Boot, Maven/Gradle |
| `typescript-react` | 2 (react-reviewer, typescript-reviewer) | 8 | TypeScript, React, Node.js |
| `golang` | 2 (go-reviewer, go-build-resolver) | 7 | Go, microservices, gRPC |
| `rust` | 2 (rust-reviewer, rust-build-resolver) | 6 | Rust, Axum/Actix, systems |
| `kotlin` | 2 (kotlin-reviewer, kotlin-build-resolver) | 8 | Kotlin, Android, KMP |
| `cpp` | 2 (cpp-reviewer, cpp-build-resolver) | 9 | C++20/23, systems |
| `flutter` | 1 (flutter-reviewer) | 8 | Flutter, Dart, mobile |
| `dotnet` | stub | 7 | .NET, C#, ASP.NET Core |
| `python-django` | stub | 7 | Python, Django, DRF |

### Available Workflows (5)

| Workflow | Adds | Description |
|----------|------|-------------|
| `ci-quality-gate` | `/ci-gate` command, ci-conventions rule | Lint + type check + test + security before merge |
| `tdd` | `/tdd` command, tdd-conventions rule | Red-green-refactor discipline |
| `incident-response` | incident-responder agent, `/debug-incident` command | Production debugging and triage |
| `adr` | `/new-adr` command | Architecture Decision Record management |
| `onboarding` | onboarding-buddy agent, `/explore-codebase` command | New developer orientation |

---

## Adding a New Stack

If your team uses a stack that isn't included:

1. Create a directory under `stacks/`:

```
stacks/your-stack/
├── agents/              # Stack-specific agents (optional)
│   ├── your-reviewer.md
│   └── your-build-resolver.md
├── commands/            # Stack-specific commands (optional)
├── rules/               # Stack-specific rules (optional)
│   ├── your-style.md
│   └── testing.md
├── manifest.yml         # Required: name, description, what it provides
└── CLAUDE.stack.md      # Required: anti-patterns injected into CLAUDE.md
```

2. Write `manifest.yml`:

```yaml
name: your-stack
description: Your Stack, Framework, Tools
provides:
  agents:
    - your-reviewer
    - your-build-resolver
  rules:
    - your-style
    - testing
  commands: []
```

3. Write `CLAUDE.stack.md` with stack-specific anti-patterns:

```markdown
- **No X** — reason why X is dangerous
- **No Y** — reason why Y causes issues
- **Always Z** — reason why Z is required
```

4. Add agents/rules following the format in `core/agents/` and `core/rules/`.

5. Test: set `stack: your-stack` in a test fixture and run `bash tests/run_tests.sh`.

6. Commit and push. Any pod can now use `stack: your-stack`.

---

## Adding a New Workflow

Workflows are opt-in modules that add agents, commands, and rules for specific practices:

1. Create a directory under `workflows/`:

```
workflows/your-workflow/
├── agents/           # Workflow agents (optional)
├── commands/         # Workflow commands (optional)
├── rules/            # Workflow rules (optional)
└── manifest.yml      # Required: name and description
```

2. Write `manifest.yml`:

```yaml
name: your-workflow
description: Brief description of what this workflow provides
```

3. Add content following the formats in `core/`.

4. Commit. Pods add it to their `workflows:` list to opt in.

---

## Architecture

### Layering Model

```
┌─────────────────────────────────────────────┐
│  Layer 4: .claude-local/ (pod overrides)     │  Highest priority
├─────────────────────────────────────────────┤
│  Layer 3: workflows/ (opt-in modules)        │
├─────────────────────────────────────────────┤
│  Layer 2: stacks/ (language-specific)        │
├─────────────────────────────────────────────┤
│  Layer 1: core/ (universal foundation)       │  Lowest priority
└─────────────────────────────────────────────┘
```

Files from higher layers overwrite files with the same name from lower layers. Excludes delete files. Includes add files.

### Generation Steps

1. Clear `.claude/` generated directories (preserve `.claude-local/`)
2. Copy `core/agents/`, `core/commands/`, `core/rules/`, `core/hooks/`, `core/contexts/`, `core/mcp-configs/`
3. Overlay `stacks/{stack}/*` (overwrites on filename conflict)
4. For each workflow: overlay `workflows/{name}/*`
5. Apply `overrides.exclude` — delete matching files
6. Apply `overrides.include` — copy from `.claude-local/`
7. Render `CLAUDE.md` from template + vars + stack anti-patterns + agent/command lists + extra sections
8. Render `settings.json` from template + vars

### Repository Structure

```
jnj-claude-configurator/
├── bin/claude-setup                  CLI entrypoint (init, generate, sync)
├── lib/
│   ├── parse_config.sh              YAML parser for claude-pod.yml
│   ├── generate.sh                  Layer assembly and template rendering
│   ├── init_wizard.sh               Interactive setup wizard
│   └── sync.sh                      Regeneration with diff display
├── core/                             Universal foundation
│   ├── agents/ (22)                  Core agents
│   ├── commands/ (18)                Core commands
│   ├── rules/ (8)                    Core rules
│   ├── contexts/ (3)                 Dev, review, research modes
│   ├── hooks/ (4)                    Session lifecycle hooks
│   └── mcp-configs/ (2)             GitHub, Azure DevOps templates
├── stacks/ (10)                      Language-specific layers
├── workflows/ (5)                    Opt-in workflow modules
├── templates/                        CLAUDE.md and settings.json templates
├── examples/ (4)                     Ready-to-use CLAUDE.md templates
├── tests/ (5 suites)                 Bash test suite
└── docs/ (4 guides)                  Detailed documentation
```

---

## CLI Reference

### `claude-setup init`

Interactive wizard that creates `claude-pod.yml`, `.claude-local/` skeleton, and runs `generate`.

```bash
.claude-configurator/bin/claude-setup init
```

### `claude-setup generate`

Reads `claude-pod.yml` and assembles `.claude/` and `CLAUDE.md` from layered templates.

```bash
.claude-configurator/bin/claude-setup generate
```

Validates that your `stack` and all `workflows` exist. Fails fast with clear error messages if not.

### `claude-setup sync`

Re-runs `generate` and shows a diff of what changed. Use after pulling a new configurator version.

```bash
.claude-configurator/bin/claude-setup sync
```

---

## Example Templates

Ready-to-use `CLAUDE.md` examples in `examples/` for common architectures:

| Template | Stack | Architecture |
|----------|-------|-------------|
| `saas-nextjs-CLAUDE.md` | TypeScript, Next.js 14, Supabase, Stripe | App Router, server actions, tRPC |
| `go-microservice-CLAUDE.md` | Go 1.22, gRPC, PostgreSQL, Redis | Hexagonal architecture, domain-driven |
| `django-api-CLAUDE.md` | Python 3.12, Django 5, DRF, Celery | Service layer, async tasks |
| `rust-api-CLAUDE.md` | Rust 1.77, Axum, SQLx, PostgreSQL | Handler → service → repository |

Use these as starting points for your `.claude-local/CLAUDE.extra.md`.

---

## FAQ

**Q: Do I need to understand the configurator to use Claude Code?**
No. Once set up, developers just use Claude Code normally. The configurator makes it smarter about their specific codebase automatically.

**Q: What if I don't want some core agents?**
Add them to `overrides.agents.exclude` in `claude-pod.yml`. They won't be generated.

**Q: Can two pods use different stacks?**
Yes. Each pod has its own `claude-pod.yml` with its own `stack` value. The configurator is a shared submodule, but each pod's config is independent.

**Q: What happens when the configurator is updated?**
Run `claude-setup sync`. Your `.claude-local/` overrides are preserved. Only the generated `.claude/` and `CLAUDE.md` change. Review the diff before committing.

**Q: Can I use this without git submodules?**
Yes. Clone the configurator anywhere, set `CONFIGURATOR_ROOT` to its path, and run the commands. Submodules are recommended for version pinning.

**Q: Do hooks require Node.js?**
No. All hooks are bash scripts — no Node.js dependency. Works on macOS, Linux, and WSL.

**Q: How do I add a stack or workflow for my team?**
See [Adding a Stack](#adding-a-new-stack) and [Adding a Workflow](#adding-a-new-workflow). Create a directory, add a manifest, and push to the configurator repo.

**Q: What model do agents use?**
Core agents use `sonnet` (fast, cost-effective) by default. Tier-1 specialist agents (api-designer, performance-engineer, etc.) use `opus` for deeper reasoning. Stack-specific agents use `sonnet`. You can override the model in any agent's frontmatter.

---

## Further Reading

- [Getting Started](docs/GETTING_STARTED.md) — setup guide for pod repos
- [Adding a Stack](docs/ADDING_A_STACK.md) — contribute a new language stack
- [Adding a Workflow](docs/ADDING_A_WORKFLOW.md) — contribute a new workflow module
- [Pod Customization](docs/POD_CUSTOMIZATION.md) — add pod-specific agents, rules, commands
- [Superpowers Integration](docs/SUPERPOWERS_INTEGRATION.md) — how Superpowers + Configurator work together

---

## Credits

Core agent designs inspired by [everything-claude-code](https://github.com/affaan-m/everything-claude-code) by Affaan M. Development methodology integration with [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent. Adapted for enterprise multi-pod use with layered configuration, stack specialization, and federated customization.
