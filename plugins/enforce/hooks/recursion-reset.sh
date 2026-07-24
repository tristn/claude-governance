#!/usr/bin/env bash
# UserPromptSubmit: Reset the recursion-nudge counter.
# Fires on every user message — resets the consecutive tool call streak.
# FAIL-OPEN.
trap 'exit 0' ERR

STATE_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/state"

cat > /dev/null 2>&1 || true

SID="${CLAUDE_SESSION_ID:-}"
[[ -z "$SID" ]] && exit 0

COUNTER_FILE="$STATE_DIR/tool_count_$SID"
[[ -f "$COUNTER_FILE" ]] && printf '0\n' > "$COUNTER_FILE" 2>/dev/null

exit 0
