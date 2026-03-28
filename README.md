# jnj-claude-configurator

Enterprise-grade, template-driven Claude Code configuration generator for multi-pod organizations. Inspired by [everything-claude-code](https://github.com/affaan-m/everything-claude-code), adapted for federated team structures with layered config assembly.

## Quick Start

```bash
# In your pod repo:
git submodule add <this-repo-url> .claude-configurator

# Initialize (interactive wizard)
.claude-configurator/bin/claude-setup init

# Regenerate after config changes
.claude-configurator/bin/claude-setup generate

# Update after pulling new configurator version
.claude-configurator/bin/claude-setup sync
```

## How It Works

1. Add this repo as a git submodule in your pod repo
2. Run `claude-setup init` to generate a `claude-pod.yml` config
3. The CLI assembles `.claude/` from layered templates:
   - **core/** — universal agents, commands, rules, contexts, hooks, MCP configs (always included)
   - **stacks/{stack}/** — language/framework-specific (one per pod)
   - **workflows/{name}/** — opt-in workflow modules
   - **.claude-local/** — pod-specific overrides

## What's Included

### Core (always included)

**15 Agents:**
| Agent | Purpose |
|-------|---------|
| `architect` | System design review and architectural decisions |
| `build-error-resolver` | Fix build errors with minimal changes |
| `chief-of-staff` | Workflow orchestration and task coordination |
| `code-reviewer` | Multi-pass code review (design, quality, security) |
| `database-reviewer` | Query optimization, schema design, DB security |
| `debugger` | Systematic debugging using scientific method |
| `doc-updater` | Keep documentation current with codebase |
| `docs-lookup` | Find and retrieve relevant documentation |
| `e2e-runner` | End-to-end test creation and maintenance |
| `loop-operator` | Manage iterative, multi-cycle workflows |
| `onboarding-guide` | Help new developers understand the codebase |
| `planner` | Create comprehensive implementation plans |
| `refactor-cleaner` | Dead code removal and safe refactoring |
| `security-reviewer` | OWASP Top 10, injection, auth, secrets review |
| `tdd-guide` | Test-driven development specialist |

**18 Commands:**
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

**8 Rules:** git-workflow, security, testing, documentation, performance, patterns, agents, hooks

**3 Contexts:** dev (speed-focused), review (quality-focused), research (exploration-focused)

**Hooks:** Session start (load context), session end (save metadata), pre-compaction (checkpoint state)

**MCP Configs:** GitHub, Azure DevOps (templates)

### Available Stacks (10)

| Stack | Agents | Description |
|-------|--------|-------------|
| `python-spark` | databricks-developer, databricks-architect, python-reviewer, pytorch-build-resolver | PySpark, Delta Lake, Databricks |
| `java-spring` | spring-reviewer, java-build-resolver | Java, Spring Boot, Maven/Gradle |
| `typescript-react` | react-reviewer, typescript-reviewer | TypeScript, React, Node.js |
| `golang` | go-reviewer, go-build-resolver | Go, microservices, gRPC |
| `rust` | rust-reviewer, rust-build-resolver | Rust, Axum/Actix, systems programming |
| `kotlin` | kotlin-reviewer, kotlin-build-resolver | Kotlin, Android, KMP |
| `cpp` | cpp-reviewer, cpp-build-resolver | C++20/23, systems programming |
| `flutter` | flutter-reviewer | Flutter, Dart, cross-platform mobile |
| `dotnet` | (stub) | .NET, C#, ASP.NET Core |
| `python-django` | (stub) | Python, Django, DRF |

### Available Workflows (5)

| Workflow | Includes | Description |
|----------|----------|-------------|
| `ci-quality-gate` | `/ci-gate` command, ci-conventions rule | Lint, type check, test, security scan |
| `tdd` | `/tdd` command, tdd-conventions rule | Test-driven development workflow |
| `incident-response` | incident-responder agent, `/debug-incident` command | Debugging and incident triage |
| `adr` | `/new-adr` command | Architecture Decision Records |
| `onboarding` | onboarding-buddy agent, `/explore-codebase` command | New developer onboarding |

### Example Templates (4)

Ready-to-use `CLAUDE.md` templates in `examples/`:
- `saas-nextjs-CLAUDE.md` — Next.js + Supabase + Stripe
- `go-microservice-CLAUDE.md` — Go gRPC + PostgreSQL
- `django-api-CLAUDE.md` — Django REST + Celery
- `rust-api-CLAUDE.md` — Rust Axum + SQLx

## Pod Configuration

Each pod declares its setup in `claude-pod.yml`:

```yaml
pod:
  name: "my-service"
  team: "Platform Engineering"
  description: "Order processing microservice"

stack: "golang"

workflows:
  - ci-quality-gate
  - tdd
  - incident-response

overrides:
  agents:
    include:
      - .claude-local/agents/my-custom-agent.md
    exclude:
      - onboarding-guide
  rules:
    include: []
    exclude: []
  commands:
    include: []
    exclude: []

vars:
  repo_name: "myorg/order-service"
  repo_host: "github"
  commit_format: "feat|fix|chore: <summary>"
  coverage_minimum: "80"
  primary_language: "go"
  test_command: "make test"
  lint_command: "make lint"
  ci_command: "make ci"
```

## Documentation

- [Getting Started](docs/GETTING_STARTED.md)
- [Adding a Stack](docs/ADDING_A_STACK.md)
- [Adding a Workflow](docs/ADDING_A_WORKFLOW.md)
- [Pod Customization](docs/POD_CUSTOMIZATION.md)

## Credits

Core agent designs inspired by [everything-claude-code](https://github.com/affaan-m/everything-claude-code) by Affaan M. Adapted for enterprise multi-pod use with layered configuration, stack specialization, and federated customization.
