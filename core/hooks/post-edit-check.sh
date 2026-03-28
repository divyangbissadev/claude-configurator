#!/usr/bin/env bash
# PostToolUse hook for Edit/Write: lightweight validation after file changes
# Checks for common mistakes in the written file

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")

# Skip if no file path or file doesn't exist
[[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]] && exit 0

WARNINGS=""

# Check for secrets accidentally written
if grep -qiE "(password|secret|api_key|token)\s*=\s*['\"][^'\"]{8,}" "$FILE_PATH" 2>/dev/null; then
    WARNINGS="${WARNINGS}WARNING: Possible hardcoded secret detected in $FILE_PATH. "
fi

# Check for debug artifacts
if grep -qn "console\.log\|print(.*DEBUG\|debugger;" "$FILE_PATH" 2>/dev/null; then
    WARNINGS="${WARNINGS}NOTE: Debug statement found in $FILE_PATH. "
fi

if [[ -n "$WARNINGS" ]]; then
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "$WARNINGS"
  }
}
EOF
fi
