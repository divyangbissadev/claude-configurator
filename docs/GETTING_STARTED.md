# Getting Started

## Prerequisites

- Bash 4+ (macOS: `brew install bash`)
- Git

## Setup (for pod repos)

### 1. Add the configurator as a submodule

```bash
git submodule add <configurator-repo-url> .claude-configurator
```

### 2. Run the wizard

```bash
.claude-configurator/bin/claude-setup init
```

This prompts for your pod name, tech stack, desired workflows, and project commands. It generates:
- `claude-pod.yml` — your pod's configuration
- `.claude-local/` — directory for pod-specific customizations
- `.claude/` — generated Claude Code setup
- `CLAUDE.md` — generated project instructions

### 3. Commit

```bash
git add .gitmodules .claude-configurator claude-pod.yml .claude-local/ .claude/ CLAUDE.md
git commit -m "feat: add Claude Code configuration"
```

### 4. Verify

Open Claude Code in your repo. It should pick up the generated `.claude/` agents, commands, and rules.

## Updating

When the configurator is updated:

```bash
git submodule update --remote .claude-configurator
.claude-configurator/bin/claude-setup sync
git add .claude/ CLAUDE.md
git commit -m "chore: update Claude Code configuration"
```

## Customizing

See [POD_CUSTOMIZATION.md](POD_CUSTOMIZATION.md) for adding pod-specific agents, rules, and commands.
