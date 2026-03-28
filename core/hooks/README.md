# Hooks

Claude Code hooks are shell commands that run at lifecycle events.

## Available Events

| Event | When | Use Case |
|-------|------|----------|
| `SessionStart` | Session begins | Load context, check dependencies |
| `Stop` | Session ends | Save context, log activity |
| `PreToolUse` | Before tool runs | Validate, redirect |
| `PostToolUse` | After tool runs | Verify, log |

## Customization

Pods can override hooks via `.claude-local/hooks/hooks.json`. The generator
merges pod hooks with core hooks.

## Session Context

The default `SessionStart` hook loads `.claude/session-context.md` if it exists.
Use this file to persist important context between sessions:

```bash
# Save current context
echo "## Active Work\n- Working on feature X\n- Blocked by Y" > .claude/session-context.md
```
