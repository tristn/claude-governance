#!/usr/bin/env bash
# PreToolUse(Edit|Write|MultiEdit): Block writes to sensitive files.
# FAIL-OPEN.
trap 'echo "{\"decision\":\"approve\"}"; exit 0' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/config-loader.sh" 2>/dev/null || true

FILE_PATH=$(gov_extract_file_path)
[[ -z "$FILE_PATH" ]] && { echo '{"decision":"approve"}'; exit 0; }

BASENAME=$(basename "$FILE_PATH")

while IFS= read -r pattern; do
    [[ -z "$pattern" ]] && continue
    if python3 -c "
import fnmatch, sys
if fnmatch.fnmatch('$BASENAME', '$pattern'):
    sys.exit(0)
sys.exit(1)
" 2>/dev/null; then
        echo "{\"decision\":\"block\",\"reason\":\"Write to sensitive file blocked ($BASENAME matches '$pattern'). These files may contain secrets.\"}"
        exit 0
    fi
done < <(gov_patterns_file "protected-files.txt" "protected-files.txt" 2>/dev/null)

echo '{"decision":"approve"}'
exit 0
