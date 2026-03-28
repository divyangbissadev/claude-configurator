#!/usr/bin/env bash
# Interactive wizard for initializing a pod's Claude Code config.

run_init() {
    local config_root="${CONFIGURATOR_ROOT:?CONFIGURATOR_ROOT must be set}"
    local pod_root="."

    echo "=== Claude Code Pod Setup ==="
    echo ""

    # Gather inputs
    read -rp "Pod name: " pod_name
    read -rp "Team name: " pod_team
    read -rp "Pod description: " pod_description

    # Show available stacks
    echo ""
    echo "Available stacks:"
    for stack_dir in "$config_root"/stacks/*/; do
        [[ -d "$stack_dir" ]] || continue
        local stack_name
        stack_name="$(basename "$stack_dir")"
        local stack_desc="$stack_name"
        if [[ -f "$stack_dir/manifest.yml" ]]; then
            stack_desc="$(sed -n 's/^description:[[:space:]]*//p' "$stack_dir/manifest.yml")"
        fi
        echo "  - $stack_name ($stack_desc)"
    done
    read -rp "Stack: " stack

    # Show available workflows
    echo ""
    echo "Available workflows:"
    for wf_dir in "$config_root"/workflows/*/; do
        [[ -d "$wf_dir" ]] || continue
        local wf_name
        wf_name="$(basename "$wf_dir")"
        local wf_desc="$wf_name"
        if [[ -f "$wf_dir/manifest.yml" ]]; then
            wf_desc="$(sed -n 's/^description:[[:space:]]*//p' "$wf_dir/manifest.yml")"
        fi
        echo "  - $wf_name ($wf_desc)"
    done
    read -rp "Workflows (comma-separated): " workflows_input

    # Vars
    echo ""
    read -rp "Repo host (github/azure-devops/gitlab): " repo_host
    read -rp "Commit format: " commit_format
    read -rp "Coverage minimum (%): " coverage_minimum
    read -rp "Primary language: " primary_language
    read -rp "Test command: " test_command
    read -rp "Lint command: " lint_command
    read -rp "CI command: " ci_command

    # Build workflows YAML
    local workflows_yaml=""
    IFS=',' read -ra wf_array <<< "$workflows_input"
    for wf in "${wf_array[@]}"; do
        wf="$(echo "$wf" | xargs)"
        workflows_yaml="$workflows_yaml  - $wf"$'\n'
    done

    # Write claude-pod.yml
    cat > "$pod_root/claude-pod.yml" <<EOF
pod:
  name: "$pod_name"
  team: "$pod_team"
  description: "$pod_description"

stack: "$stack"

workflows:
$workflows_yaml
overrides:
  agents:
    include: []
    exclude: []
  rules:
    include: []
    exclude: []
  commands:
    include: []
    exclude: []

vars:
  repo_name: "$pod_name"
  repo_host: "$repo_host"
  commit_format: "$commit_format"
  coverage_minimum: "$coverage_minimum"
  primary_language: "$primary_language"
  test_command: "$test_command"
  lint_command: "$lint_command"
  ci_command: "$ci_command"
EOF

    # Create .claude-local skeleton
    mkdir -p "$pod_root/.claude-local/agents" \
             "$pod_root/.claude-local/commands" \
             "$pod_root/.claude-local/rules"

    echo ""
    echo "Created claude-pod.yml and .claude-local/ skeleton."
    echo "Running generate..."

    # Run generate
    source "$config_root/lib/parse_config.sh"
    source "$config_root/lib/generate.sh"
    parse_config "$pod_root/claude-pod.yml"
    run_generate "$pod_root"

    echo ""
    echo "Done! Your .claude/ setup is ready."
    echo "Next steps:"
    echo "  - Add pod-specific agents to .claude-local/agents/"
    echo "  - Add pod-specific rules to .claude-local/rules/"
    echo "  - Run '.claude-configurator/bin/claude-setup generate' after changes"
}
