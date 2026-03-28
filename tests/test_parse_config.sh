#!/usr/bin/env bash
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TESTS_DIR/.." && pwd)"

source "$ROOT_DIR/lib/parse_config.sh"

assert_eq() {
    local label="$1" expected="$2" actual="$3"
    if [[ "$expected" != "$actual" ]]; then
        echo "FAIL: $label — expected '$expected', got '$actual'"
        exit 1
    fi
}

# Test: parse scalars
parse_config "$TESTS_DIR/fixtures/valid-config.yml"

assert_eq "pod.name" "robotics-wfl" "$CFG_POD_NAME"
assert_eq "pod.team" "Data Engineering" "$CFG_POD_TEAM"
assert_eq "stack" "python-spark" "$CFG_STACK"

# Test: parse vars
assert_eq "vars.repo_name" "jnj-pdp-robotics-wfl" "$(get_var repo_name)"
assert_eq "vars.repo_host" "azure-devops" "$(get_var repo_host)"
assert_eq "vars.ci_command" "make ci" "$(get_var ci_command)"

# Test: parse workflows array
assert_eq "workflows count" "3" "${#CFG_WORKFLOWS[@]}"
assert_eq "workflows[0]" "ci-quality-gate" "${CFG_WORKFLOWS[0]}"
assert_eq "workflows[1]" "tdd" "${CFG_WORKFLOWS[1]}"
assert_eq "workflows[2]" "incident-response" "${CFG_WORKFLOWS[2]}"

# Test: parse overrides
assert_eq "agents.include count" "2" "${#CFG_OVERRIDE_AGENTS_INCLUDE[@]}"
assert_eq "agents.include[0]" ".claude-local/agents/databricks-developer.md" "${CFG_OVERRIDE_AGENTS_INCLUDE[0]}"
assert_eq "agents.exclude count" "1" "${#CFG_OVERRIDE_AGENTS_EXCLUDE[@]}"
assert_eq "agents.exclude[0]" "onboarding-guide" "${CFG_OVERRIDE_AGENTS_EXCLUDE[0]}"

echo "All parse_config tests passed."
