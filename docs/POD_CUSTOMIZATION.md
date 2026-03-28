# Pod Customization

## Adding Pod-Specific Agents

1. Create the agent file in `.claude-local/agents/my-agent.md`
2. Add it to `claude-pod.yml`:

```yaml
overrides:
  agents:
    include:
      - .claude-local/agents/my-agent.md
```

3. Run `claude-setup generate` to rebuild.

## Adding Pod-Specific Rules

Same pattern — create in `.claude-local/rules/`, add to `overrides.rules.include`.

## Adding Pod-Specific Commands

Same pattern — create in `.claude-local/commands/`, add to `overrides.commands.include`.

## Excluding Default Agents/Rules/Commands

To remove a core or stack agent that doesn't apply:

```yaml
overrides:
  agents:
    exclude:
      - onboarding-guide    # Just the filename without .md
```

## Adding Extra CLAUDE.md Sections

Create `.claude-local/CLAUDE.extra.md` with any pod-specific sections (architecture diagrams, data models, extension points). This is appended to the generated CLAUDE.md.

## Updating After Changes

After modifying `claude-pod.yml` or files in `.claude-local/`:

```bash
.claude-configurator/bin/claude-setup generate
```
