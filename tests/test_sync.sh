#!/usr/bin/env bash
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TESTS_DIR/.." && pwd)"
TMP_DIR="$TESTS_DIR/tmp/test_sync"

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

# Set up a fake pod repo with existing generated output
cp "$TESTS_DIR/fixtures/minimal-config.yml" "$TMP_DIR/claude-pod.yml"
mkdir -p "$TMP_DIR/.claude/agents"
echo "old content" > "$TMP_DIR/.claude/agents/code-reviewer.md"
echo "old CLAUDE.md" > "$TMP_DIR/CLAUDE.md"

export CONFIGURATOR_ROOT="$ROOT_DIR"
cd "$TMP_DIR"

source "$ROOT_DIR/lib/parse_config.sh"
source "$ROOT_DIR/lib/sync.sh"
parse_config "$TMP_DIR/claude-pod.yml"
run_sync "$TMP_DIR"

# The code-reviewer should now have the real content (not "old content")
if grep -q "old content" "$TMP_DIR/.claude/agents/code-reviewer.md"; then
    echo "FAIL: sync did not regenerate agents"
    exit 1
fi

if grep -q "old CLAUDE.md" "$TMP_DIR/CLAUDE.md"; then
    echo "FAIL: sync did not regenerate CLAUDE.md"
    exit 1
fi

echo "All sync tests passed."
rm -rf "$TMP_DIR"
