#!/usr/bin/env bash
# SubagentStop hook: captures learnings from completed subagent
# Logs agent completion and prompts for memory writes

INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('agent_type','unknown'))" 2>/dev/null || echo "unknown")
AGENT_ID=$(echo "$INPUT" | python3 -c "import json,sys; print(json.load(sys.stdin).get('agent_id','unknown'))" 2>/dev/null || echo "unknown")

# Log completion
USAGE_DIR=".claude/usage"
mkdir -p "$USAGE_DIR"
echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ'),${AGENT_ID},agent_complete,${AGENT_TYPE}" >> "$USAGE_DIR/agent-completions.csv"
