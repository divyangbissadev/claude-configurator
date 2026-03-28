#!/usr/bin/env bash
# SessionStart hook: detects current JIRA ticket from branch name or prompts
# Logs session start time against the ticket

JIRA_DIR=".claude/jira"
SESSION_LOG="$JIRA_DIR/session-log.csv"
TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
EPOCH="$(date +%s)"
SESSION_ID="${CLAUDE_SESSION_ID:-$(date +%s)}"

mkdir -p "$JIRA_DIR"

# Try to detect JIRA ticket from git branch
BRANCH="$(git branch --show-current 2>/dev/null || echo "")"
TICKET=""

# Match patterns: feature/PR-557-description, PR-557/description, PR-557, PROJ-123
if [[ "$BRANCH" =~ ([A-Z][A-Z0-9]+-[0-9]+) ]]; then
    TICKET="${BASH_REMATCH[1]}"
fi

# If no ticket from branch, check last commit message
if [[ -z "$TICKET" ]]; then
    LAST_COMMIT="$(git log -1 --format='%s' 2>/dev/null || echo "")"
    if [[ "$LAST_COMMIT" =~ ([A-Z][A-Z0-9]+-[0-9]+) ]]; then
        TICKET="${BASH_REMATCH[1]}"
    fi
fi

# Create CSV header if new
if [[ ! -f "$SESSION_LOG" ]]; then
    echo "timestamp,session_id,event,ticket,branch,epoch" > "$SESSION_LOG"
fi

# Log session start
echo "${TIMESTAMP},${SESSION_ID},session_start,${TICKET:-unlinked},${BRANCH:-none},${EPOCH}" >> "$SESSION_LOG"

# Save current ticket for session-end to reference
echo "$TICKET" > "$JIRA_DIR/.current-ticket"
echo "$EPOCH" > "$JIRA_DIR/.session-start-epoch"

if [[ -n "$TICKET" ]]; then
    echo "JIRA: Session linked to $TICKET (from branch: $BRANCH)"
else
    echo "JIRA: No ticket detected. Use /jira-link <TICKET-ID> to link this session."
fi
