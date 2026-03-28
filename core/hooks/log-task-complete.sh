#!/usr/bin/env bash
# TaskCompleted hook: logs task completions for productivity tracking

INPUT=$(cat)
TASK_ID=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('task_id','unknown'))" 2>/dev/null || echo "unknown")
TASK_SUBJECT=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('task_subject','unknown'))" 2>/dev/null || echo "unknown")

USAGE_DIR=".claude/usage"
TASK_LOG="$USAGE_DIR/task-completions.csv"
TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

mkdir -p "$USAGE_DIR"

if [[ ! -f "$TASK_LOG" ]]; then
    echo "timestamp,task_id,task_subject" > "$TASK_LOG"
fi

echo "${TIMESTAMP},${TASK_ID},${TASK_SUBJECT}" >> "$TASK_LOG"
