#!/usr/bin/env bash
# StopFailure hook for rate limits: logs and advises

USAGE_DIR=".claude/usage"
mkdir -p "$USAGE_DIR"

echo "$(date -u '+%Y-%m-%dT%H:%M:%SZ'),rate_limit" >> "$USAGE_DIR/errors.csv"

echo "Rate limit hit. Consider:"
echo "  - Using a cheaper model (haiku) for mechanical tasks"
echo "  - Reducing parallel agent dispatches"
echo "  - Waiting 60 seconds before retrying"
