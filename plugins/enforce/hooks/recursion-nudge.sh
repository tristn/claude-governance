#!/usr/bin/env bash
# PostToolUse(.*): Track consecutive tool calls without user input.
# At threshold, inject a nudge encouraging the agent to step back.
#
# Paired with recursion-reset.sh (UserPromptSubmit) which zeros the
# per-session counter on every user message.
#
# FAIL-OPEN: always exits 0.
trap 'exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/config-loader.sh" 2>/dev/null || true

THRESHOLD=$(gov_config "recursion_threshold" "20")
STATE_DIR="${_GOV_PROJECT_DIR:-.}/.claude/state"

gov_read_stdin > /dev/null 2>&1 || true

SID="${CLAUDE_SESSION_ID:-}"
[[ -z "$SID" ]] && exit 0

mkdir -p "$STATE_DIR" 2>/dev/null || exit 0
COUNTER_FILE="$STATE_DIR/tool_count_$SID"
LOCK_FILE="$STATE_DIR/.lock_$SID"

if ! command -v flock >/dev/null 2>&1; then
    exit 0
fi

COUNT=$(
    exec 9> "$LOCK_FILE" 2>/dev/null || exit 0
    flock -w 1 9 2>/dev/null || exit 0
    CUR=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
    NEW=$((CUR + 1))
    printf '%s\n' "$NEW" > "$COUNTER_FILE.tmp" 2>/dev/null && mv -f "$COUNTER_FILE.tmp" "$COUNTER_FILE" 2>/dev/null
    printf '%s' "$NEW"
) 2>/dev/null

[[ -z "$COUNT" ]] && exit 0
[[ "$COUNT" -ne "$THRESHOLD" ]] && exit 0

cat <<'EOF'
{"decision":"approve","additionalContext":"RECURSION-NUDGE: You've made 20+ consecutive tool calls without user input. This is correlated with grinding on a local minimum. Consider: (1) Am I pattern-matching on a dead-end approach? (2) Would stepping back or researching help? (3) Should I ask the user for a redirect? If still confident in direction, continue. Otherwise, pause and reframe."}
EOF

exit 0
