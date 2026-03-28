#!/usr/bin/env bash
# Stop hook: logs session end and calculates time spent on JIRA ticket

JIRA_DIR=".claude/jira"
SESSION_LOG="$JIRA_DIR/session-log.csv"
TIME_LOG="$JIRA_DIR/time-log.csv"
TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
EPOCH="$(date +%s)"
SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"

mkdir -p "$JIRA_DIR"

# Read current ticket and start time
TICKET="$(cat "$JIRA_DIR/.current-ticket" 2>/dev/null || echo "unlinked")"
START_EPOCH="$(cat "$JIRA_DIR/.session-start-epoch" 2>/dev/null || echo "0")"
BRANCH="$(git branch --show-current 2>/dev/null || echo "none")"

# Calculate duration
if [[ "$START_EPOCH" -gt 0 ]]; then
    DURATION_SECS=$(( EPOCH - START_EPOCH ))
    DURATION_MINS=$(( DURATION_SECS / 60 ))
    DURATION_HOURS=$(python3 -c "print(f'{$DURATION_SECS / 3600:.2f}')" 2>/dev/null || echo "0.00")
else
    DURATION_SECS=0
    DURATION_MINS=0
    DURATION_HOURS="0.00"
fi

# Log session end
echo "${TIMESTAMP},${SESSION_ID},session_end,${TICKET},${BRANCH},${EPOCH}" >> "$SESSION_LOG"

# Log time entry
if [[ ! -f "$TIME_LOG" ]]; then
    echo "date,session_id,ticket,branch,duration_secs,duration_mins,duration_hours" > "$TIME_LOG"
fi
echo "$(date '+%Y-%m-%d'),${SESSION_ID},${TICKET},${BRANCH},${DURATION_SECS},${DURATION_MINS},${DURATION_HOURS}" >> "$TIME_LOG"

# Also log to global time tracker
GLOBAL_TIME_LOG="${HOME}/.claude/jira/global-time-log.csv"
mkdir -p "${HOME}/.claude/jira"
if [[ ! -f "$GLOBAL_TIME_LOG" ]]; then
    echo "date,session_id,ticket,project,branch,duration_secs,duration_mins,duration_hours" > "$GLOBAL_TIME_LOG"
fi
PROJECT="$(basename "$(pwd)")"
echo "$(date '+%Y-%m-%d'),${SESSION_ID},${TICKET},${PROJECT},${BRANCH},${DURATION_SECS},${DURATION_MINS},${DURATION_HOURS}" >> "$GLOBAL_TIME_LOG"

# Print summary
if [[ "$TICKET" != "unlinked" && "$DURATION_MINS" -gt 0 ]]; then
    echo ""
    echo "--- JIRA Time Log ---"
    echo "  Ticket:   $TICKET"
    echo "  Duration: ${DURATION_MINS}m (${DURATION_HOURS}h)"
    echo "  Branch:   $BRANCH"
    echo "---------------------"
fi

# Clean up temp files
rm -f "$JIRA_DIR/.current-ticket" "$JIRA_DIR/.session-start-epoch"
