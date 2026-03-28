#!/usr/bin/env bash
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TESTS_DIR/.." && pwd)"
TMP_DIR="$TESTS_DIR/tmp/test_init"

rm -rf "$TMP_DIR"
mkdir -p "$TMP_DIR"
cd "$TMP_DIR"
git init --quiet

export CONFIGURATOR_ROOT="$ROOT_DIR"

# Test non-interactive mode (pipe answers)
printf 'my-pod\nMy Team\nA test pod\npython-spark\nci-quality-gate,tdd\ngithub\nfeat: <summary>\n80\npython\nmake test\nmake lint\nmake ci\n' | \
    bash "$ROOT_DIR/bin/claude-setup" init

# Assertions
if [[ ! -f "$TMP_DIR/claude-pod.yml" ]]; then
    echo "FAIL: claude-pod.yml not created"
    exit 1
fi

if [[ ! -d "$TMP_DIR/.claude-local" ]]; then
    echo "FAIL: .claude-local/ not created"
    exit 1
fi

if [[ ! -d "$TMP_DIR/.claude/agents" ]]; then
    echo "FAIL: .claude/ not generated"
    exit 1
fi

if ! grep -q "my-pod" "$TMP_DIR/claude-pod.yml"; then
    echo "FAIL: claude-pod.yml missing pod name"
    exit 1
fi

if ! grep -q "My Team" "$TMP_DIR/CLAUDE.md"; then
    echo "FAIL: CLAUDE.md missing team name"
    exit 1
fi

echo "All init tests passed."
rm -rf "$TMP_DIR"
