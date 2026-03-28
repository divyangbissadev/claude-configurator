#!/usr/bin/env bash
# Generates .claude/ directory and CLAUDE.md from parsed config.
# Requires: parse_config.sh already sourced and parse_config() already called.

run_generate() {
    local pod_root="${1:-.}"
    local config_root="${CONFIGURATOR_ROOT:?CONFIGURATOR_ROOT must be set}"

    # Validate stack exists
    if [[ ! -d "$config_root/stacks/$CFG_STACK" ]]; then
        echo "Error: Stack '$CFG_STACK' not found in $config_root/stacks/" >&2
        echo "Available stacks:" >&2
        ls "$config_root/stacks/" 2>/dev/null >&2 || echo "  (none)" >&2
        return 1
    fi

    # Validate workflows exist
    for wf in "${CFG_WORKFLOWS[@]}"; do
        if [[ ! -d "$config_root/workflows/$wf" ]]; then
            echo "Error: Workflow '$wf' not found in $config_root/workflows/" >&2
            echo "Available workflows:" >&2
            ls "$config_root/workflows/" 2>/dev/null >&2 || echo "  (none)" >&2
            return 1
        fi
    done

    # Step 1: Clear .claude/ generated dirs (preserve .claude-local/)
    rm -rf "$pod_root/.claude/agents" "$pod_root/.claude/commands" \
           "$pod_root/.claude/rules" "$pod_root/.claude/hooks" \
           "$pod_root/.claude/contexts" "$pod_root/.claude/mcp-configs" \
           "$pod_root/.claude/settings.json"
    mkdir -p "$pod_root/.claude/agents" "$pod_root/.claude/commands" \
             "$pod_root/.claude/rules" "$pod_root/.claude/hooks" \
             "$pod_root/.claude/contexts" "$pod_root/.claude/mcp-configs" \
             "$pod_root/.claude/agent-memory/shared"

    # Step 2-5: Copy core
    copy_layer "$config_root/core" "$pod_root/.claude"

    # Step 6: Overlay stack
    copy_layer "$config_root/stacks/$CFG_STACK" "$pod_root/.claude"

    # Step 7: Overlay workflows
    for wf in "${CFG_WORKFLOWS[@]}"; do
        copy_layer "$config_root/workflows/$wf" "$pod_root/.claude"
    done

    # Step 8: Apply excludes
    apply_excludes "$pod_root/.claude/agents" "${CFG_OVERRIDE_AGENTS_EXCLUDE[@]+"${CFG_OVERRIDE_AGENTS_EXCLUDE[@]}"}"
    apply_excludes "$pod_root/.claude/rules" "${CFG_OVERRIDE_RULES_EXCLUDE[@]+"${CFG_OVERRIDE_RULES_EXCLUDE[@]}"}"
    apply_excludes "$pod_root/.claude/commands" "${CFG_OVERRIDE_COMMANDS_EXCLUDE[@]+"${CFG_OVERRIDE_COMMANDS_EXCLUDE[@]}"}"

    # Step 9: Apply includes
    apply_includes "$pod_root" "$pod_root/.claude/agents" "${CFG_OVERRIDE_AGENTS_INCLUDE[@]+"${CFG_OVERRIDE_AGENTS_INCLUDE[@]}"}"
    apply_includes "$pod_root" "$pod_root/.claude/rules" "${CFG_OVERRIDE_RULES_INCLUDE[@]+"${CFG_OVERRIDE_RULES_INCLUDE[@]}"}"
    apply_includes "$pod_root" "$pod_root/.claude/commands" "${CFG_OVERRIDE_COMMANDS_INCLUDE[@]+"${CFG_OVERRIDE_COMMANDS_INCLUDE[@]}"}"

    # Step 9.5: Scaffold agent memory directories
    mkdir -p "$pod_root/.claude/agent-memory/shared"
    for agent_file in "$pod_root/.claude/agents"/*.md; do
        [[ -f "$agent_file" ]] || continue
        local agent_name
        agent_name="$(basename "$agent_file" .md)"
        mkdir -p "$pod_root/.claude/agent-memory/$agent_name"
        # Create MEMORY.md from template if it doesn't exist
        if [[ ! -f "$pod_root/.claude/agent-memory/$agent_name/MEMORY.md" ]]; then
            if [[ -f "$config_root/core/agent-memory/templates/MEMORY.md.tmpl" ]]; then
                sed "s/{{AGENT_NAME}}/$agent_name/g" "$config_root/core/agent-memory/templates/MEMORY.md.tmpl" \
                    > "$pod_root/.claude/agent-memory/$agent_name/MEMORY.md"
            fi
        fi
    done
    # Copy shared memory template if it doesn't exist
    if [[ ! -f "$pod_root/.claude/agent-memory/shared/MEMORY.md" ]]; then
        if [[ -f "$config_root/core/agent-memory/shared/MEMORY.md" ]]; then
            cp "$config_root/core/agent-memory/shared/MEMORY.md" "$pod_root/.claude/agent-memory/shared/MEMORY.md"
        fi
    fi

    # Step 10: Render CLAUDE.md
    render_claude_md "$config_root" "$pod_root"

    # Step 11: Render settings.json
    render_settings_json "$config_root" "$pod_root"

    echo "Generated .claude/ and CLAUDE.md successfully."
}

copy_layer() {
    local src="$1" dst="$2"
    for subdir in agents commands rules hooks contexts mcp-configs agent-memory; do
        if [[ -d "$src/$subdir" ]]; then
            mkdir -p "$dst/$subdir"
            # Copy .md and .json files if they exist (nullglob-safe)
            find "$src/$subdir" -maxdepth 1 \( -name '*.md' -o -name '*.json' \) -type f 2>/dev/null | while IFS= read -r f; do
                cp -f "$f" "$dst/$subdir/"
            done
        fi
    done
}

apply_excludes() {
    local dir="$1"
    shift
    for name in "$@"; do
        [[ -z "$name" ]] && continue
        rm -f "$dir/${name}.md" "$dir/$name"
    done
}

apply_includes() {
    local pod_root="$1" target_dir="$2"
    shift 2
    for path in "$@"; do
        [[ -z "$path" ]] && continue
        local src="$pod_root/$path"
        if [[ -f "$src" ]]; then
            cp -f "$src" "$target_dir/"
        fi
    done
}

render_claude_md() {
    local config_root="$1" pod_root="$2"
    local template="$config_root/templates/CLAUDE.md.tmpl"
    local output="$pod_root/CLAUDE.md"

    if [[ ! -f "$template" ]]; then
        echo "Warning: CLAUDE.md template not found at $template" >&2
        return 0
    fi

    local content
    content="$(cat "$template")"

    # Substitute scalar vars
    content="${content//\{\{POD_DESCRIPTION\}\}/$CFG_POD_DESCRIPTION}"
    content="${content//\{\{POD_TEAM\}\}/$CFG_POD_TEAM}"
    content="${content//\{\{REPO_NAME\}\}/$(get_var repo_name)}"
    content="${content//\{\{REPO_HOST\}\}/$(get_var repo_host)}"
    content="${content//\{\{STACK\}\}/$CFG_STACK}"
    content="${content//\{\{TEST_COMMAND\}\}/$(get_var test_command)}"
    content="${content//\{\{LINT_COMMAND\}\}/$(get_var lint_command)}"
    content="${content//\{\{CI_COMMAND\}\}/$(get_var ci_command)}"
    content="${content//\{\{COMMIT_FORMAT\}\}/$(get_var commit_format)}"
    content="${content//\{\{COVERAGE_MINIMUM\}\}/$(get_var coverage_minimum)}"

    # Include stack anti-patterns
    local stack_file="$config_root/stacks/$CFG_STACK/CLAUDE.stack.md"
    local stack_content=""
    if [[ -f "$stack_file" ]]; then
        stack_content="$(cat "$stack_file")"
    fi
    content="${content//\{\{FILE:STACK_ANTIPATTERNS\}\}/$stack_content}"

    # Include extra sections from .claude-local
    local extra_file="$pod_root/.claude-local/CLAUDE.extra.md"
    local extra_content=""
    if [[ -f "$extra_file" ]]; then
        extra_content="$(cat "$extra_file")"
    fi
    content="${content//\{\{FILE:EXTRA_SECTIONS\}\}/$extra_content}"

    # Generate agents list by scanning .claude/agents/*.md
    local agents_list=""
    for agent_file in "$pod_root/.claude/agents"/*.md; do
        [[ -f "$agent_file" ]] || continue
        local agent_name
        agent_name="$(basename "$agent_file" .md)"
        # Extract description from frontmatter
        local agent_desc
        agent_desc="$(sed -n '/^description:/{ s/^description:[[:space:]]*>*[[:space:]]*//; p; q; }' "$agent_file")"
        if [[ -z "$agent_desc" || "$agent_desc" == ">" ]]; then
            # Multi-line description: grab the next non-empty indented line
            agent_desc="$(sed -n '/^description:/,/^[a-z]/{
                /^description:/d
                /^[a-z]/d
                /^[[:space:]]*$/d
                s/^[[:space:]]*//
                p
                q
            }' "$agent_file")"
        fi
        agents_list="${agents_list}- **${agent_name}** — ${agent_desc}"$'\n'
    done
    content="${content//\{\{AGENTS_LIST\}\}/$agents_list}"

    # Generate commands list by scanning .claude/commands/*.md
    local commands_list=""
    for cmd_file in "$pod_root/.claude/commands"/*.md; do
        [[ -f "$cmd_file" ]] || continue
        local cmd_name
        cmd_name="$(basename "$cmd_file" .md)"
        local cmd_desc
        cmd_desc="$(sed -n 's/^description:[[:space:]]*//p' "$cmd_file" | head -1)"
        commands_list="${commands_list}- \`/${cmd_name}\` — ${cmd_desc}"$'\n'
    done
    content="${content//\{\{COMMANDS_LIST\}\}/$commands_list}"

    printf '%s\n' "$content" > "$output"
}

render_settings_json() {
    local config_root="$1" pod_root="$2"
    local template="$config_root/templates/settings.json.tmpl"
    local output="$pod_root/.claude/settings.json"

    if [[ ! -f "$template" ]]; then
        echo "Warning: settings.json template not found at $template" >&2
        return 0
    fi

    local content
    content="$(cat "$template")"

    content="${content//\{\{TEST_COMMAND\}\}/$(get_var test_command)}"
    content="${content//\{\{LINT_COMMAND\}\}/$(get_var lint_command)}"
    content="${content//\{\{CI_COMMAND\}\}/$(get_var ci_command)}"

    printf '%s\n' "$content" > "$output"
}
