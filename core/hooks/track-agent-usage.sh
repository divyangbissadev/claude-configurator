#!/usr/bin/env bash
# PostToolUse hook for Agent tool: tracks agent dispatches and token usage
# Receives tool response as JSON on stdin

USAGE_DIR=".claude/usage"
USAGE_LOG="$USAGE_DIR/usage-log.csv"
TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"
PROJECT="$(basename "$(pwd)")"

mkdir -p "$USAGE_DIR"

if [[ ! -f "$USAGE_LOG" ]]; then
    echo "timestamp,session_id,event,project,model,agent,command,messages,tool_calls,estimated_input_tokens,estimated_output_tokens,estimated_cost_usd" > "$USAGE_LOG"
fi

# Parse agent info from tool input/response
INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('subagent_type',d.get('tool_input',{}).get('description','unknown')))" 2>/dev/null || echo "unknown")
MODEL=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_input',{}).get('model','sonnet'))" 2>/dev/null || echo "sonnet")

# Extract token count from response if available
TOKENS=$(echo "$INPUT" | python3 -c "
import json,sys,re
d=json.load(sys.stdin)
resp=str(d.get('tool_response',''))
m=re.search(r'total_tokens:\s*(\d+)',resp)
print(m.group(1) if m else '0')
" 2>/dev/null || echo "0")

# Estimate cost
if [ "$TOKENS" -gt 0 ]; then
    EST_INPUT=$(( TOKENS * 40 / 100 ))
    EST_OUTPUT=$(( TOKENS * 60 / 100 ))
    case "$MODEL" in
        opus*) COST=$(python3 -c "print(f'{($EST_INPUT*15.0/1000000)+($EST_OUTPUT*75.0/1000000):.4f}')" 2>/dev/null || echo "0.0000") ;;
        haiku*) COST=$(python3 -c "print(f'{($EST_INPUT*0.80/1000000)+($EST_OUTPUT*4.0/1000000):.4f}')" 2>/dev/null || echo "0.0000") ;;
        *) COST=$(python3 -c "print(f'{($EST_INPUT*3.0/1000000)+($EST_OUTPUT*15.0/1000000):.4f}')" 2>/dev/null || echo "0.0000") ;;
    esac
else
    EST_INPUT=0; EST_OUTPUT=0; COST="0.0000"
fi

echo "${TIMESTAMP},${SESSION_ID},agent_dispatch,${PROJECT},${MODEL},${AGENT_TYPE},,0,0,$EST_INPUT,$EST_OUTPUT,$COST" >> "$USAGE_LOG"
