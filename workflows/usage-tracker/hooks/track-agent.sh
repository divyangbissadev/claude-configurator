#!/usr/bin/env bash
# Logs agent dispatch events
# Called manually or via PostToolUse hook when Agent tool is used
# Usage: track-agent.sh <agent-name> <model> <tokens-reported>

USAGE_DIR=".claude/usage"
USAGE_LOG="$USAGE_DIR/usage-log.csv"
SESSION_ID="${CLAUDE_SESSION_ID:-$(date +%s)}"
PROJECT="$(basename "$(pwd)")"
TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

AGENT_NAME="${1:-unknown}"
MODEL="${2:-sonnet}"
TOKENS="${3:-0}"

mkdir -p "$USAGE_DIR"

if [[ ! -f "$USAGE_LOG" ]]; then
    echo "timestamp,session_id,event,project,model,agent,command,messages,tool_calls,estimated_input_tokens,estimated_output_tokens,estimated_cost_usd" > "$USAGE_LOG"
fi

# When agent reports tokens, log them
if [[ "$TOKENS" -gt 0 ]]; then
    EST_INPUT=$(( TOKENS * 40 / 100 ))  # ~40% input
    EST_OUTPUT=$(( TOKENS * 60 / 100 )) # ~60% output

    case "$MODEL" in
        opus*) COST=$(python3 -c "print(f'{($EST_INPUT * 15.0 / 1000000) + ($EST_OUTPUT * 75.0 / 1000000):.4f}')" 2>/dev/null || echo "0.0000") ;;
        haiku*) COST=$(python3 -c "print(f'{($EST_INPUT * 0.80 / 1000000) + ($EST_OUTPUT * 4.0 / 1000000):.4f}')" 2>/dev/null || echo "0.0000") ;;
        *) COST=$(python3 -c "print(f'{($EST_INPUT * 3.0 / 1000000) + ($EST_OUTPUT * 15.0 / 1000000):.4f}')" 2>/dev/null || echo "0.0000") ;;
    esac
else
    EST_INPUT=0
    EST_OUTPUT=0
    COST="0.0000"
fi

echo "${TIMESTAMP},${SESSION_ID},agent_dispatch,${PROJECT},${MODEL},${AGENT_NAME},,0,0,$EST_INPUT,$EST_OUTPUT,$COST" >> "$USAGE_LOG"
