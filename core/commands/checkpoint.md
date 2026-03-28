---
description: Save current work state as a checkpoint before risky operations.
---

# Checkpoint

Save a snapshot of current work state for recovery.

## Steps

1. **Capture git state**: current branch, commit SHA, dirty files
2. **Save context**: write `.claude/session-context.md` with:
   - What you're working on
   - What's done, what's left
   - Any blockers or decisions made
3. **Stage safeguard**: `git stash` if there are uncommitted changes
4. **Report**: confirm checkpoint saved with recovery instructions
