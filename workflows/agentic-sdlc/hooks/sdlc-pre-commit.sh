#!/usr/bin/env bash
# SDLC Pre-Commit Hook
# Ensures commit messages reference a GitHub issue number when on a ticket branch

set -euo pipefail

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# Only enforce on ticket branches (feat/, fix/, chore/)
if [[ "$BRANCH" =~ ^(feat|fix|chore)/ ]]; then
  # Extract issue number from branch name
  ISSUE_NUM=$(echo "$BRANCH" | grep -oP '(?<=/)\d+' | head -1 || true)

  if [[ -n "$ISSUE_NUM" ]]; then
    COMMIT_MSG_FILE="$1"
    if [[ -f "$COMMIT_MSG_FILE" ]]; then
      # Check if commit message already references the issue
      if ! grep -qP "#${ISSUE_NUM}" "$COMMIT_MSG_FILE"; then
        echo "" >> "$COMMIT_MSG_FILE"
        echo "Refs #${ISSUE_NUM}" >> "$COMMIT_MSG_FILE"
      fi
    fi
  fi
fi

exit 0
