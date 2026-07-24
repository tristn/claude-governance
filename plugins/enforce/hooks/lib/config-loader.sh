#!/usr/bin/env bash
# Shared config loader + input parser for governance hooks.
#
# Hook input contract: Claude Code pipes JSON to stdin containing
# tool_input (for PreToolUse) or tool_result (for PostToolUse).
#
# Precedence for config: env var > project config > plugin defaults.
# All functions fail-open.

# This file lives at <plugin-root>/hooks/lib/ — root is two levels up.
_GOV_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
_GOV_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
_GOV_PROJECT_CFG="${_GOV_PROJECT_DIR}/.claude/governance/config.json"
_GOV_PLUGIN_CFG="${_GOV_PLUGIN_ROOT}/config/defaults.json"

_GOV_PY=$(command -v python3 2>/dev/null || command -v python 2>/dev/null || echo "")

# Read and cache stdin (can only read once)
_GOV_STDIN=""
gov_read_stdin() {
    if [[ -z "$_GOV_STDIN" ]]; then
        _GOV_STDIN=$(cat 2>/dev/null || true)
    fi
    echo "$_GOV_STDIN"
}

# Extract the bash command from PreToolUse stdin JSON
gov_extract_command() {
    local input
    input=$(gov_read_stdin)
    if [[ -n "$_GOV_PY" && -n "$input" ]]; then
        echo "$input" | "$_GOV_PY" -c "
import json, sys
try:
    data = json.load(sys.stdin)
    ti = data.get('tool_input', {})
    print(ti.get('command', ''))
except: pass
" 2>/dev/null || true
    fi
}

# Extract file_path from Edit/Write PreToolUse stdin JSON
gov_extract_file_path() {
    local input
    input=$(gov_read_stdin)
    if [[ -n "$_GOV_PY" && -n "$input" ]]; then
        echo "$input" | "$_GOV_PY" -c "
import json, sys
try:
    data = json.load(sys.stdin)
    ti = data.get('tool_input', {})
    print(ti.get('file_path', ''))
except: pass
" 2>/dev/null || true
    fi
}

# gov_config KEY DEFAULT
gov_config() {
    local key="$1"
    local default="$2"
    local env_key="GOVERNANCE_$(echo "$key" | tr '[:lower:]' '[:upper:]')"
    local val="${!env_key:-}"

    if [[ -n "$val" ]]; then echo "$val"; return; fi

    if [[ -f "$_GOV_PROJECT_CFG" && -n "$_GOV_PY" ]]; then
        val=$("$_GOV_PY" -c "import json; print(json.load(open('$_GOV_PROJECT_CFG')).get('$key', ''))" 2>/dev/null || true)
        if [[ -n "$val" ]]; then echo "$val"; return; fi
    fi

    if [[ -f "$_GOV_PLUGIN_CFG" && -n "$_GOV_PY" ]]; then
        val=$("$_GOV_PY" -c "import json; print(json.load(open('$_GOV_PLUGIN_CFG')).get('$key', ''))" 2>/dev/null || true)
        if [[ -n "$val" ]]; then echo "$val"; return; fi
    fi

    echo "$default"
}

# gov_patterns_file PROJECT_FILE PLUGIN_FILE
gov_patterns_file() {
    local project_file="${_GOV_PROJECT_DIR}/.claude/governance/$1"
    local plugin_file="${_GOV_PLUGIN_ROOT}/config/$2"

    {
        [[ -f "$plugin_file" ]] && grep -v '^\s*#' "$plugin_file" | grep -v '^\s*$'
        [[ -f "$project_file" ]] && grep -v '^\s*#' "$project_file" | grep -v '^\s*$'
    } 2>/dev/null | sort -u
}
