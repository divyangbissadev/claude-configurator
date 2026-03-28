# Adding a New Workflow

## Steps

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

3. Add agents, commands, and/or rules following the formats in `core/`.

4. Test: add your workflow to a fixture config and run `tests/run_tests.sh`.

5. Commit and push. Pods can add it to their `workflows:` list.
