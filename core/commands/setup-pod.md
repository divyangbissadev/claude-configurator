---
description: Interactively refine this pod's Claude Code setup after initial generation.
---

# Setup Pod

Refine the current pod's Claude Code configuration interactively.

## Steps

### 1. Read Current Config

Read `claude-pod.yml` and show the current setup summary:
- Pod name, team, stack
- Active workflows
- Override counts (included/excluded agents, rules, commands)

### 2. Ask What to Change

Offer options:
- Add/remove workflows
- Add/remove agent overrides
- Add/remove rule overrides
- Update vars (test command, coverage minimum, etc.)
- Add a CLAUDE.extra.md section

### 3. Apply Changes

Update `claude-pod.yml` with the requested changes.

### 4. Regenerate

Run `.claude-configurator/bin/claude-setup generate` to rebuild `.claude/` and `CLAUDE.md`.

### 5. Show Diff

Show what changed in the generated output.
