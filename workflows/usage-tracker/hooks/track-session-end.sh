#!/usr/bin/env bash
# Logs session end with estimated token usage
# Called by Stop hook
#
# Token estimation heuristic:
#   - Average message: ~500 input tokens, ~800 output tokens
#   - Average tool call: ~200 input tokens, ~300 output tokens
#   - These are rough estimates — actual usage varies widely
#
# Cost estimation (per 1M tokens):
#   - Claude Opus:   input $15.00, output $75.00
#   - Claude Sonnet:  input $3.00, output $15.00
#   - Claude Haiku:   input $0.80, output $4.00

USAGE_DIR=".claude/usage"
USAGE_LOG="$USAGE_DIR/usage-log.csv"
GLOBAL_LOG="${HOME}/.claude/usage/global-usage.csv"
SESSION_ID="${CLAUDE_SESSION_ID:-$(date +%s)}"
PROJECT="$(basename "$(pwd)")"
TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
MODEL="${CLAUDE_MODEL:-sonnet}"

mkdir -p "$USAGE_DIR"
mkdir -p "${HOME}/.claude/usage"

# Read today's stats from Claude Code's stats cache
STATS_FILE="${HOME}/.claude/stats-cache.json"
TODAY=$(date '+%Y-%m-%d')
MESSAGES=0
TOOL_CALLS=0

if [[ -f "$STATS_FILE" ]] && command -v python3 &>/dev/null; then
    read MESSAGES TOOL_CALLS <<< $(python3 -c "
import json, sys
try:
    with open('$STATS_FILE') as f:
        data = json.load(f)
    for entry in data.get('dailyActivity', []):
        if entry['date'] == '$TODAY':
            print(entry.get('messageCount', 0), entry.get('toolCallCount', 0))
            sys.exit(0)
    print('0 0')
except:
    print('0 0')
" 2>/dev/null)
fi

# Estimate tokens (heuristic)
EST_INPUT_TOKENS=$(( MESSAGES * 500 + TOOL_CALLS * 200 ))
EST_OUTPUT_TOKENS=$(( MESSAGES * 800 + TOOL_CALLS * 300 ))

# Estimate cost based on model
case "$MODEL" in
    opus|claude-opus*)
        COST=$(python3 -c "print(f'{($EST_INPUT_TOKENS * 15.0 / 1000000) + ($EST_OUTPUT_TOKENS * 75.0 / 1000000):.4f}')" 2>/dev/null || echo "0.0000")
        ;;
    sonnet|claude-sonnet*)
        COST=$(python3 -c "print(f'{($EST_INPUT_TOKENS * 3.0 / 1000000) + ($EST_OUTPUT_TOKENS * 15.0 / 1000000):.4f}')" 2>/dev/null || echo "0.0000")
        ;;
    haiku|claude-haiku*)
        COST=$(python3 -c "print(f'{($EST_INPUT_TOKENS * 0.80 / 1000000) + ($EST_OUTPUT_TOKENS * 4.0 / 1000000):.4f}')" 2>/dev/null || echo "0.0000")
        ;;
    *)
        COST=$(python3 -c "print(f'{($EST_INPUT_TOKENS * 3.0 / 1000000) + ($EST_OUTPUT_TOKENS * 15.0 / 1000000):.4f}')" 2>/dev/null || echo "0.0000")
        ;;
esac

# Create header if file doesn't exist
if [[ ! -f "$USAGE_LOG" ]]; then
    echo "timestamp,session_id,event,project,model,agent,command,messages,tool_calls,estimated_input_tokens,estimated_output_tokens,estimated_cost_usd" > "$USAGE_LOG"
fi

# Log to project-level
echo "${TIMESTAMP},${SESSION_ID},session_end,${PROJECT},${MODEL},,,$MESSAGES,$TOOL_CALLS,$EST_INPUT_TOKENS,$EST_OUTPUT_TOKENS,$COST" >> "$USAGE_LOG"

# Log to global (cross-project)
if [[ ! -f "$GLOBAL_LOG" ]]; then
    echo "timestamp,session_id,event,project,model,agent,command,messages,tool_calls,estimated_input_tokens,estimated_output_tokens,estimated_cost_usd" > "$GLOBAL_LOG"
fi
echo "${TIMESTAMP},${SESSION_ID},session_end,${PROJECT},${MODEL},,,$MESSAGES,$TOOL_CALLS,$EST_INPUT_TOKENS,$EST_OUTPUT_TOKENS,$COST" >> "$GLOBAL_LOG"

# Print summary to user
echo ""
echo "--- Session Usage Estimate ---"
echo "  Messages:      $MESSAGES"
echo "  Tool calls:    $TOOL_CALLS"
echo "  Est. input:    $(python3 -c "print(f'{$EST_INPUT_TOKENS:,}')" 2>/dev/null || echo $EST_INPUT_TOKENS) tokens"
echo "  Est. output:   $(python3 -c "print(f'{$EST_OUTPUT_TOKENS:,}')" 2>/dev/null || echo $EST_OUTPUT_TOKENS) tokens"
echo "  Est. cost:     \$$COST ($MODEL)"
echo "------------------------------"
