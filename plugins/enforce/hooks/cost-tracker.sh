#!/usr/bin/env bash
# PostToolUse(.*): Log tool usage per session for cost tracking.
# Writes JSONL to project .claude/logs/cost-tracker.jsonl.
#
# Tracks: timestamp, session ID, tool name, and cumulative call count.
# Token-level tracking requires API-side support — this tracks
# call volume as a proxy for cost awareness.
#
# FAIL-OPEN.
trap 'exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/config-loader.sh" 2>/dev/null || true

ENABLED=$(gov_config "cost_tracker_enabled" "true")
[[ "$ENABLED" != "true" ]] && exit 0

LOG_PATH=$(gov_config "cost_tracker_log_path" ".claude/logs/cost-tracker.jsonl")
LOG_FILE="${_GOV_PROJECT_DIR:-.}/$LOG_PATH"

cat > /dev/null 2>&1 || true

SID="${CLAUDE_SESSION_ID:-unknown}"
TOOL="${TOOL_USE_NAME:-unknown}"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "unknown")

mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || exit 0

printf '{"ts":"%s","session":"%s","tool":"%s"}\n' "$TS" "$SID" "$TOOL" >> "$LOG_FILE" 2>/dev/null

exit 0
