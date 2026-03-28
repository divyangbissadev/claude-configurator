#!/usr/bin/env bash
# Regenerates .claude/ after updating the configurator submodule.
# Shows a diff of what changed.

run_sync() {
    local pod_root="${1:-.}"
    local config_root="${CONFIGURATOR_ROOT:?CONFIGURATOR_ROOT must be set}"
    local config_file="$pod_root/claude-pod.yml"

    if [[ ! -f "$config_file" ]]; then
        echo "Error: claude-pod.yml not found. Run 'claude-setup init' first." >&2
        return 1
    fi

    # Capture current state for diffing
    local tmp_before
    tmp_before="$(mktemp -d)"
    if [[ -d "$pod_root/.claude" ]]; then
        cp -r "$pod_root/.claude" "$tmp_before/.claude"
    fi
    if [[ -f "$pod_root/CLAUDE.md" ]]; then
        cp "$pod_root/CLAUDE.md" "$tmp_before/CLAUDE.md"
    fi

    # Parse and regenerate
    source "$config_root/lib/parse_config.sh"
    source "$config_root/lib/generate.sh"
    parse_config "$config_file"
    run_generate "$pod_root"

    # Show diff
    echo ""
    echo "=== Changes ==="
    if command -v diff &>/dev/null; then
        diff -rq "$tmp_before/.claude" "$pod_root/.claude" 2>/dev/null || true
        if [[ -f "$tmp_before/CLAUDE.md" ]]; then
            diff -u "$tmp_before/CLAUDE.md" "$pod_root/CLAUDE.md" 2>/dev/null || true
        fi
    else
        echo "(install 'diff' to see detailed changes)"
    fi

    rm -rf "$tmp_before"
    echo ""
    echo "Sync complete."
}
