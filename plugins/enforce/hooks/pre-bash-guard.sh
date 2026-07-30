#!/usr/bin/env bash
# PreToolUse(Bash): Block credential exposure, force-push, and
# dangerous git commands.
# FAIL-OPEN: errors exit 0 with approve.
trap 'echo "{\"decision\":\"approve\"}"; exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/config-loader.sh" 2>/dev/null || true

CMD=$(gov_extract_command)
[[ -z "$CMD" ]] && { echo '{"decision":"approve"}'; exit 0; }

# Hard-coded: block reading .env files
if echo "$CMD" | grep -qE '(cat|head|tail|less|more)\s+.*\.env'; then
    echo '{"decision":"block","reason":"Reading .env files directly would expose credentials in conversation context. Use: test -n \"$VAR\" && echo set || echo unset"}'
    exit 0
fi

# Hard-coded: block dangerous git commands
# Force flags must be arguments OF the push itself: the gap never crosses
# a command separator (& | ;), and the flag must be a whole token — else
# "git push origin capture-first" or a later "-f" in an unrelated command
# on the same line false-positives.
if echo "$CMD" | grep -qE 'git\s+push[^&|;]*\s(-[a-zA-Z]*f[a-zA-Z]*|--force[^[:space:]]*)(\s|$)'; then
    echo '{"decision":"block","reason":"Force-push blocked by governance. Use git revert for pushed mistakes."}'
    exit 0
fi
if echo "$CMD" | grep -qE 'git\s+add\s+(-A|\.)(\s|$)'; then
    echo '{"decision":"block","reason":"git add -A/. blocked — stage specific files by name to avoid including secrets or large binaries."}'
    exit 0
fi
if echo "$CMD" | grep -qE 'git\s+reset\s+--hard'; then
    echo '{"decision":"approve","additionalContext":"WARNING: git reset --hard is destructive and irreversible. Confirm this is intentional."}'
    exit 0
fi

# Configurable: block commands containing credential patterns
while IFS= read -r pattern; do
    [[ -z "$pattern" ]] && continue
    if echo "$CMD" | grep -qE "$pattern"; then
        echo "{\"decision\":\"block\",\"reason\":\"Command contains credentials (matched: $pattern). Never hardcode secrets.\"}"
        exit 0
    fi
done < <(gov_patterns_file "blocked-credentials.txt" "blocked-credentials.txt" 2>/dev/null)

echo '{"decision":"approve"}'
exit 0
