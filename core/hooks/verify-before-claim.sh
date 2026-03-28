#!/usr/bin/env bash
# Stop hook addition: reminds agent to verify claims before completing
# Injects a verification reminder into the conversation context

INPUT=$(cat)
STOP_HOOK_ACTIVE=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('stop_hook_active', False))" 2>/dev/null || echo "False")

# Don't create infinite loops
[[ "$STOP_HOOK_ACTIVE" == "True" ]] && exit 0

LAST_MSG=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('last_assistant_message','')[:500])" 2>/dev/null || echo "")

# Check for high-confidence claims without evidence patterns
NEEDS_CHECK=false

# Claims about files existing
if echo "$LAST_MSG" | grep -qiE "(this file|the file|located at|found in|exists at)" 2>/dev/null; then
    if ! echo "$LAST_MSG" | grep -qE ":[0-9]+" 2>/dev/null; then
        NEEDS_CHECK=true
    fi
fi

# Claims about features or behavior
if echo "$LAST_MSG" | grep -qiE "(the codebase (has|supports|includes)|this (function|method|class) (does|handles|returns))" 2>/dev/null; then
    NEEDS_CHECK=true
fi

# Claims about test results without showing output
if echo "$LAST_MSG" | grep -qiE "(all tests pass|tests are passing|build succeeds)" 2>/dev/null; then
    if ! echo "$LAST_MSG" | grep -qiE "(passed|PASS|Results:)" 2>/dev/null; then
        NEEDS_CHECK=true
    fi
fi

if [[ "$NEEDS_CHECK" == "true" ]]; then
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "VERIFICATION REMINDER: Your last response contains claims about the codebase. Please verify: (1) Any file paths referenced actually exist, (2) Any functions/methods mentioned are real, (3) Any test results claimed were actually observed. If you haven't verified, please do so now."
  }
}
EOF
fi
