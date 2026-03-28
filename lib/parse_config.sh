#!/usr/bin/env bash
# Parses claude-pod.yml into bash variables.
# Not a general YAML parser — handles only the claude-pod.yml schema.
# Compatible with bash 3.2+ (macOS default).

# Exported variables after parse_config():
#   CFG_POD_NAME, CFG_POD_TEAM, CFG_POD_DESCRIPTION
#   CFG_STACK
#   CFG_WORKFLOWS=()
#   CFG_OVERRIDE_AGENTS_INCLUDE=()  CFG_OVERRIDE_AGENTS_EXCLUDE=()
#   CFG_OVERRIDE_RULES_INCLUDE=()   CFG_OVERRIDE_RULES_EXCLUDE=()
#   CFG_OVERRIDE_COMMANDS_INCLUDE=() CFG_OVERRIDE_COMMANDS_EXCLUDE=()
#   CFG_VARS_RAW (newline-delimited "key=value" pairs — access via get_var)

CFG_POD_NAME=""
CFG_POD_TEAM=""
CFG_POD_DESCRIPTION=""
CFG_STACK=""
CFG_VARS_RAW=""
CFG_WORKFLOWS=()
CFG_OVERRIDE_AGENTS_INCLUDE=()
CFG_OVERRIDE_AGENTS_EXCLUDE=()
CFG_OVERRIDE_RULES_INCLUDE=()
CFG_OVERRIDE_RULES_EXCLUDE=()
CFG_OVERRIDE_COMMANDS_INCLUDE=()
CFG_OVERRIDE_COMMANDS_EXCLUDE=()

get_var() {
    local key="$1"
    local line
    # Each entry is stored as "key=value"; match on exact key prefix
    while IFS= read -r line; do
        case "$line" in
            "${key}="*)
                echo "${line#${key}=}"
                return 0
                ;;
        esac
    done <<< "$CFG_VARS_RAW"
    echo ""
}

parse_config() {
    local config_file="$1"

    if [[ ! -f "$config_file" ]]; then
        echo "Error: Config file not found: $config_file" >&2
        return 1
    fi

    # Reset all globals
    CFG_POD_NAME=""
    CFG_POD_TEAM=""
    CFG_POD_DESCRIPTION=""
    CFG_STACK=""
    CFG_VARS_RAW=""
    CFG_WORKFLOWS=()
    CFG_OVERRIDE_AGENTS_INCLUDE=()
    CFG_OVERRIDE_AGENTS_EXCLUDE=()
    CFG_OVERRIDE_RULES_INCLUDE=()
    CFG_OVERRIDE_RULES_EXCLUDE=()
    CFG_OVERRIDE_COMMANDS_INCLUDE=()
    CFG_OVERRIDE_COMMANDS_EXCLUDE=()

    local section="" subsection="" array_target=""

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip blank lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Strip trailing comments
        line="${line%%#*}"

        # Detect top-level sections (no leading whitespace)
        if [[ "$line" =~ ^[a-z] ]]; then
            local key val
            key="$(echo "$line" | sed 's/:.*//' | xargs)"
            val="$(echo "$line" | sed 's/^[^:]*://' | xargs)"
            # Remove surrounding quotes
            val="${val#\"}" ; val="${val%\"}"
            val="${val#\'}" ; val="${val%\'}"

            case "$key" in
                pod)       section="pod"; subsection=""; array_target="" ;;
                stack)     section=""; CFG_STACK="$val" ;;
                workflows) section="workflows"; array_target="CFG_WORKFLOWS" ;;
                overrides) section="overrides"; subsection="" ;;
                vars)      section="vars" ;;
            esac
            continue
        fi

        # Indented lines — context depends on section
        local trimmed
        trimmed="$(echo "$line" | sed 's/^[[:space:]]*//')"

        case "$section" in
            pod)
                local key val
                key="$(echo "$trimmed" | sed 's/:.*//' | xargs)"
                val="$(echo "$trimmed" | sed 's/^[^:]*://' | xargs)"
                val="${val#\"}" ; val="${val%\"}"
                val="${val#\'}" ; val="${val%\'}"
                case "$key" in
                    name)        CFG_POD_NAME="$val" ;;
                    team)        CFG_POD_TEAM="$val" ;;
                    description) CFG_POD_DESCRIPTION="$val" ;;
                esac
                ;;
            workflows)
                if [[ "$trimmed" =~ ^-[[:space:]]+(.*) ]]; then
                    local item="${BASH_REMATCH[1]}"
                    item="${item#\"}" ; item="${item%\"}"
                    CFG_WORKFLOWS+=("$item")
                fi
                ;;
            overrides)
                # Detect subsection: agents, rules, commands
                if [[ "$trimmed" =~ ^(agents|rules|commands): ]]; then
                    subsection="${BASH_REMATCH[1]}"
                    array_target=""
                elif [[ "$trimmed" =~ ^(include|exclude): ]]; then
                    local override_type="${BASH_REMATCH[1]}"
                    local suffix
                    suffix="$(echo "${subsection}_${override_type}" | tr '[:lower:]' '[:upper:]')"
                    array_target="CFG_OVERRIDE_${suffix}"
                    # Check for empty array on same line: "exclude: []"
                    case "$trimmed" in
                        *'[]'*) array_target="" ;;
                    esac
                elif [[ -n "$array_target" && "$trimmed" =~ ^-[[:space:]]+(.*) ]]; then
                    local item="${BASH_REMATCH[1]}"
                    item="${item#\"}" ; item="${item%\"}"
                    item="${item#\'}" ; item="${item%\'}"
                    eval "${array_target}+=(\"$item\")"
                fi
                ;;
            vars)
                if [[ "$trimmed" =~ ^([a-z_]+):[[:space:]]*(.*) ]]; then
                    local key="${BASH_REMATCH[1]}"
                    local val="${BASH_REMATCH[2]}"
                    val="${val#\"}" ; val="${val%\"}"
                    val="${val#\'}" ; val="${val%\'}"
                    if [[ -z "$CFG_VARS_RAW" ]]; then
                        CFG_VARS_RAW="${key}=${val}"
                    else
                        CFG_VARS_RAW="${CFG_VARS_RAW}"$'\n'"${key}=${val}"
                    fi
                fi
                ;;
        esac
    done < "$config_file"
}
