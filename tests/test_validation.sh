#!/usr/bin/env bash
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TESTS_DIR/.." && pwd)"
TMP_DIR="$TESTS_DIR/tmp/test_validation"

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"

export CONFIGURATOR_ROOT="$ROOT_DIR"
source "$ROOT_DIR/lib/parse_config.sh"
source "$ROOT_DIR/lib/generate.sh"

# Test 1: Invalid stack should fail
echo "Test: invalid stack should fail..."
cp "$TESTS_DIR/fixtures/invalid-stack-config.yml" "$TMP_DIR/claude-pod.yml"
cd "$TMP_DIR"
parse_config "$TMP_DIR/claude-pod.yml"
if run_generate "$TMP_DIR" 2>/dev/null; then
    echo "FAIL: generate should have failed for invalid stack"
    exit 1
fi
echo "  PASS: invalid stack correctly rejected"

# Test 2: Invalid workflow should fail
echo "Test: invalid workflow should fail..."
cp "$TESTS_DIR/fixtures/invalid-workflow-config.yml" "$TMP_DIR/claude-pod.yml"
parse_config "$TMP_DIR/claude-pod.yml"
if run_generate "$TMP_DIR" 2>/dev/null; then
    echo "FAIL: generate should have failed for invalid workflow"
    exit 1
fi
echo "  PASS: invalid workflow correctly rejected"

echo "All validation tests passed."
rm -rf "$TMP_DIR"
