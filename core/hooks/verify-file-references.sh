#!/usr/bin/env bash
# PostToolUse hook for Edit/Write: verifies that referenced file paths actually exist
# Catches phantom file references in agent output

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "")

# Only check for Write and Edit tools
[[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]] && exit 0

FILE_PATH=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))" 2>/dev/null || echo "")

# For Edit: verify the file exists before editing
if [[ "$TOOL_NAME" == "Edit" && -n "$FILE_PATH" && ! -f "$FILE_PATH" ]]; then
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "HALLUCINATION WARNING: Edit target '$FILE_PATH' does not exist. The agent may be referencing a phantom file. Verify the path before proceeding."
  }
}
EOF
fi
