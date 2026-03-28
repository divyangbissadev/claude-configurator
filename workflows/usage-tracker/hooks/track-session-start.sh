#!/usr/bin/env bash
# Logs session start to usage CSV
# Called by SessionStart hook

USAGE_DIR=".claude/usage"
USAGE_LOG="$USAGE_DIR/usage-log.csv"
SESSION_ID="${CLAUDE_SESSION_ID:-$(date +%s)}"
PROJECT="$(basename "$(pwd)")"
TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

mkdir -p "$USAGE_DIR"

# Create header if file doesn't exist
if [[ ! -f "$USAGE_LOG" ]]; then
    echo "timestamp,session_id,event,project,model,agent,command,messages,tool_calls,estimated_input_tokens,estimated_output_tokens,estimated_cost_usd" > "$USAGE_LOG"
fi

# Log session start
echo "${TIMESTAMP},${SESSION_ID},session_start,${PROJECT},,,,0,0,0,0,0.00" >> "$USAGE_LOG"
