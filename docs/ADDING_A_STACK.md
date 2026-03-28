# Adding a New Stack

## Steps

1. Create a directory under `stacks/`:

```
stacks/your-stack/
├── agents/           # Stack-specific agents (optional)
├── commands/         # Stack-specific commands (optional)
├── rules/            # Stack-specific rules (optional)
├── manifest.yml      # Required: name and description
└── CLAUDE.stack.md   # Required: anti-patterns for CLAUDE.md
```

2. Write `manifest.yml`:

```yaml
name: your-stack
description: Brief description of the technology stack
provides:
  agents:
    - agent-name
  commands:
    - command-name
  rules:
    - rule-name
```

3. Write `CLAUDE.stack.md` with stack-specific anti-patterns:

```markdown
- **No X** — reason
- **No Y** — reason
- **Always Z** — reason
```

4. Add agents, commands, and rules following the formats in `core/`.

5. Test: create a fixture config with your stack and run `tests/run_tests.sh`.

6. Commit and push. Pods can immediately use `stack: your-stack`.
