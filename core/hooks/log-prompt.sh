#!/usr/bin/env bash
# UserPromptSubmit hook: logs prompts for usage tracking
# Receives prompt as JSON on stdin

USAGE_DIR=".claude/usage"
PROMPT_LOG="$USAGE_DIR/prompt-log.csv"
TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"

mkdir -p "$USAGE_DIR"

if [[ ! -f "$PROMPT_LOG" ]]; then
    echo "timestamp,session_id,prompt_length" > "$PROMPT_LOG"
fi

# Get prompt length (not content — privacy)
INPUT=$(cat)
PROMPT_LEN=$(echo "$INPUT" | python3 -c "import json,sys; print(len(json.load(sys.stdin).get('prompt','')))" 2>/dev/null || echo "0")

echo "${TIMESTAMP},${SESSION_ID},${PROMPT_LEN}" >> "$PROMPT_LOG"
