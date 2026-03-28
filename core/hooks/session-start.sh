#!/usr/bin/env bash
# SessionStart hook: loads persisted session context
# Place in .claude/hooks/ and reference from hooks.json

CONTEXT_FILE=".claude/session-context.md"

if [[ -f "$CONTEXT_FILE" ]]; then
    echo "=== Restored Session Context ==="
    cat "$CONTEXT_FILE"
    echo "================================"
else
    echo "No previous session context found."
fi
