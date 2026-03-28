#!/usr/bin/env bash
# PreToolUse hook: blocks destructive commands
# Receives tool input as JSON on stdin

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

BLOCKED=false
REASON=""

# Check for destructive patterns
case "$COMMAND" in
    *"rm -rf /"*|*"rm -rf ~"*|*"rm -rf ."*)
        BLOCKED=true
        REASON="Recursive delete on root/home/current directory blocked"
        ;;
    *"git push --force"*|*"git push -f "*)
        BLOCKED=true
        REASON="Force push blocked — use --force-with-lease if necessary"
        ;;
    *"git reset --hard"*)
        BLOCKED=true
        REASON="Hard reset blocked — uncommitted work would be lost"
        ;;
    *"git clean -fd"*|*"git clean -fx"*)
        BLOCKED=true
        REASON="Git clean blocked — untracked files would be permanently deleted"
        ;;
    *"DROP TABLE"*|*"DROP DATABASE"*|*"TRUNCATE"*)
        BLOCKED=true
        REASON="Destructive SQL blocked — requires explicit user confirmation"
        ;;
esac

if [ "$BLOCKED" = true ]; then
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "$REASON"
  }
}
EOF
fi
