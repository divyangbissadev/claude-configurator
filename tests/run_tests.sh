#!/usr/bin/env bash
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS=0
FAIL=0
ERRORS=""

run_test_file() {
    local test_file="$1"
    local test_name
    test_name="$(basename "$test_file" .sh)"
    echo "--- Running $test_name ---"
    if bash "$test_file"; then
        echo "  PASS: $test_name"
        ((PASS++))
    else
        echo "  FAIL: $test_name"
        ((FAIL++))
        ERRORS="$ERRORS\n  - $test_name"
    fi
    echo ""
}

for test_file in "$TESTS_DIR"/test_*.sh; do
    [[ -f "$test_file" ]] || continue
    run_test_file "$test_file"
done

echo "========================="
echo "Results: $PASS passed, $FAIL failed"
if [[ $FAIL -gt 0 ]]; then
    echo -e "Failed tests:$ERRORS"
    exit 1
fi
