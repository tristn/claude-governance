#!/usr/bin/env bash
# PreToolUse(Bash): Block catastrophically destructive commands.
# FAIL-OPEN.
trap 'echo "{\"decision\":\"approve\"}"; exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/config-loader.sh" 2>/dev/null || true

CMD=$(gov_extract_command)
[[ -z "$CMD" ]] && { echo '{"decision":"approve"}'; exit 0; }

while IFS= read -r pattern; do
    [[ -z "$pattern" ]] && continue
    if echo "$CMD" | grep -qiE "$pattern"; then
        echo "{\"decision\":\"block\",\"reason\":\"Destructive operation blocked by governance (matched: $pattern). This command could cause irreversible damage.\"}"
        exit 0
    fi
done < <(gov_patterns_file "destructive-ops.txt" "destructive-ops.txt" 2>/dev/null)

echo '{"decision":"approve"}'
exit 0
