#!/usr/bin/env bash
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TESTS_DIR/.." && pwd)"
TMP_DIR="$TESTS_DIR/tmp/test_generate"

# Clean up
rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

# Set up a fake pod repo
cp "$TESTS_DIR/fixtures/minimal-config.yml" "$TMP_DIR/claude-pod.yml"

# Run generate
export CONFIGURATOR_ROOT="$ROOT_DIR"
source "$ROOT_DIR/lib/parse_config.sh"
source "$ROOT_DIR/lib/generate.sh"

cd "$TMP_DIR"
parse_config "$TMP_DIR/claude-pod.yml"
run_generate "$TMP_DIR"

# Assertions
assert_file_exists() {
    if [[ ! -f "$1" ]]; then
        echo "FAIL: Expected file not found: $1"
        exit 1
    fi
}

assert_file_contains() {
    if ! grep -q "$2" "$1"; then
        echo "FAIL: $1 does not contain '$2'"
        exit 1
    fi
}

# Core agents should be present
assert_file_exists "$TMP_DIR/.claude/agents/code-reviewer.md"
assert_file_exists "$TMP_DIR/.claude/agents/debugger.md"
assert_file_exists "$TMP_DIR/.claude/agents/architect.md"
assert_file_exists "$TMP_DIR/.claude/agents/security-reviewer.md"
assert_file_exists "$TMP_DIR/.claude/agents/onboarding-guide.md"

# Core commands should be present
assert_file_exists "$TMP_DIR/.claude/commands/review-pr.md"
assert_file_exists "$TMP_DIR/.claude/commands/tdd.md"

# Core rules should be present
assert_file_exists "$TMP_DIR/.claude/rules/git-workflow.md"
assert_file_exists "$TMP_DIR/.claude/rules/security.md"

# Stack agents should be overlaid (python-spark)
assert_file_exists "$TMP_DIR/.claude/agents/databricks-developer.md"

# Workflow commands should be overlaid (ci-quality-gate)
assert_file_exists "$TMP_DIR/.claude/commands/ci-gate.md"

# CLAUDE.md should be generated with vars substituted
assert_file_exists "$TMP_DIR/CLAUDE.md"
assert_file_contains "$TMP_DIR/CLAUDE.md" "test-repo"
assert_file_contains "$TMP_DIR/CLAUDE.md" "Test Team"
assert_file_contains "$TMP_DIR/CLAUDE.md" "make test"
assert_file_contains "$TMP_DIR/CLAUDE.md" "make ci"

# settings.json should be generated
assert_file_exists "$TMP_DIR/.claude/settings.json"
assert_file_contains "$TMP_DIR/.claude/settings.json" "make test"

echo "All generate tests passed."

# Clean up
rm -rf "$TMP_DIR"
