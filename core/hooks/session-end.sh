#!/usr/bin/env bash
# Stop hook: saves session metadata for next session
# Appends timestamp and session info to session log

SESSION_LOG=".claude/session-log.txt"
CONTEXT_FILE=".claude/session-context.md"

mkdir -p .claude

# Log session end
echo "Session ended: $(date '+%Y-%m-%d %H:%M:%S')" >> "$SESSION_LOG"

# If session-context.md exists, note it was loaded
if [[ -f "$CONTEXT_FILE" ]]; then
    echo "  Context was loaded from: $CONTEXT_FILE" >> "$SESSION_LOG"
fi
