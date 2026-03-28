#!/usr/bin/env bash
# SubagentStart hook: injects relevant memory into subagent context
# Reads agent memory and provides as additional context

INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('agent_type','unknown'))" 2>/dev/null || echo "unknown")

MEMORY_FILE=".claude/agent-memory/${AGENT_TYPE}/MEMORY.md"
SHARED_MEMORY=".claude/agent-memory/shared/MEMORY.md"

CONTEXT=""

# Load agent-specific memory
if [[ -f "$MEMORY_FILE" ]]; then
    ENTRY_COUNT=$(grep -c "^### " "$MEMORY_FILE" 2>/dev/null || echo "0")
    if [[ "$ENTRY_COUNT" -gt 0 ]]; then
        # Get last 10 entries (most recent, most relevant)
        CONTEXT="[Agent Memory: ${ENTRY_COUNT} entries loaded for ${AGENT_TYPE}] "
    fi
fi

# Load shared memory
if [[ -f "$SHARED_MEMORY" ]]; then
    SHARED_COUNT=$(grep -c "^### " "$SHARED_MEMORY" 2>/dev/null || echo "0")
    if [[ "$SHARED_COUNT" -gt 0 ]]; then
        CONTEXT="${CONTEXT}[Shared Memory: ${SHARED_COUNT} cross-agent entries loaded] "
    fi
fi

if [[ -n "$CONTEXT" ]]; then
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SubagentStart",
    "additionalContext": "$CONTEXT"
  }
}
EOF
fi
