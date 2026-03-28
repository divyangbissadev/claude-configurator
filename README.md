# jnj-claude-configurator

Template-driven Claude Code configuration generator for multi-pod organizations.

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
   - **core/** — universal agents, commands, rules (always included)
   - **stacks/{stack}/** — language/framework-specific (one per pod)
   - **workflows/{name}/** — opt-in workflow modules
   - **.claude-local/** — pod-specific overrides

## Available Stacks

| Stack | Description |
|-------|-------------|
| `python-spark` | PySpark, Delta Lake, Databricks |
| `java-spring` | Java, Spring Boot, Maven/Gradle |
| `typescript-react` | TypeScript, React, Node.js |

## Available Workflows

| Workflow | Description |
|----------|-------------|
| `ci-quality-gate` | Lint, type check, test, security scan |
| `tdd` | Test-driven development workflow |
| `incident-response` | Debugging and incident triage |
| `adr` | Architecture Decision Records |
| `onboarding` | New developer onboarding |
