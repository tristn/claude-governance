#!/usr/bin/env bash
# PreToolUse(Bash): Soft guard against non-trivial commits to main.
# Warns via additionalContext — does NOT block.
# FAIL-OPEN.
trap 'echo "{\"decision\":\"approve\"}"; exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/config-loader.sh" 2>/dev/null || true

CMD=$(gov_extract_command)
[[ -z "$CMD" ]] && { echo '{"decision":"approve"}'; exit 0; }

# Only fire on commit-producing commands
if ! echo "$CMD" | grep -qE 'git\s+(commit|merge|cherry-pick|rebase)'; then
    echo '{"decision":"approve"}'
    exit 0
fi

# Only fire on main/master branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [[ "$BRANCH" != "main" && "$BRANCH" != "master" ]]; then
    echo '{"decision":"approve"}'
    exit 0
fi

THRESHOLD=$(gov_config "main_branch_line_threshold" "20")
LINES_CHANGED=$(git diff --cached --numstat 2>/dev/null | awk '{s+=$1+$2} END {print s+0}')

# Check required-review paths (project-specific, optional)
TOUCHES_REQUIRED=false
REQ_FILE="${_GOV_PROJECT_DIR}/.claude/governance/required-review-paths.txt"
if [[ -f "$REQ_FILE" ]]; then
    STAGED_FILES=$(git diff --cached --name-only 2>/dev/null)
    while IFS= read -r pattern; do
        [[ "$pattern" =~ ^#.*$ || -z "$pattern" ]] && continue
        if echo "$STAGED_FILES" | python3 -c "
import sys, fnmatch, pathlib
pattern = '$pattern'
for line in sys.stdin:
    f = line.strip()
    if f and (fnmatch.fnmatch(f, pattern) or pathlib.PurePath(f).match(pattern)):
        sys.exit(0)
sys.exit(1)
" 2>/dev/null; then
            TOUCHES_REQUIRED=true
            break
        fi
    done < "$REQ_FILE"
fi

if [[ "$LINES_CHANGED" -gt "$THRESHOLD" ]] || [[ "$TOUCHES_REQUIRED" = true ]]; then
    REASON=""
    [[ "$LINES_CHANGED" -gt "$THRESHOLD" ]] && REASON="$LINES_CHANGED lines changed (>$THRESHOLD threshold)"
    if [[ "$TOUCHES_REQUIRED" = true ]]; then
        [[ -n "$REASON" ]] && REASON="$REASON + "
        REASON="${REASON}touches required-review paths"
    fi
    echo "{\"decision\":\"approve\",\"additionalContext\":\"MAIN-BRANCH-GUARD: Committing to main with non-trivial changes ($REASON). Use a feature branch + PR for non-trivial work.\"}"
    exit 0
fi

echo '{"decision":"approve"}'
exit 0
