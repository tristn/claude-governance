# Override Guide

The governance plugin provides sensible defaults. Projects customize
behavior through overrides — no need to fork the plugin.

## Precedence (highest to lowest)

1. **Environment variables** — `GOVERNANCE_<KEY>=value`
2. **Project config** — `.claude/governance/config.json`
3. **Plugin defaults** — `config/defaults.json`

## Configuration options

| Key | Env var | Default | Description |
|-----|---------|---------|-------------|
| `recursion_threshold` | `GOVERNANCE_RECURSION_THRESHOLD` | 20 | Tool calls before nudge fires |
| `main_branch_line_threshold` | `GOVERNANCE_MAIN_BRANCH_LINE_THRESHOLD` | 20 | Lines changed before main guard warns |
| `cost_tracker_enabled` | `GOVERNANCE_COST_TRACKER_ENABLED` | true | Enable/disable cost tracking |
| `cost_tracker_log_path` | `GOVERNANCE_COST_TRACKER_LOG_PATH` | `.claude/logs/cost-tracker.jsonl` | Path for cost log |

## Pattern files

Place these in `.claude/governance/` to extend plugin defaults:

| File | Extends | Purpose |
|------|---------|---------|
| `blocked-credentials.txt` | `config/blocked-credentials.txt` | Additional credential patterns to block |
| `protected-files.txt` | `config/protected-files.txt` | Additional file patterns to protect |
| `destructive-ops.txt` | `config/destructive-ops.txt` | Additional destructive command patterns |
| `required-review-paths.txt` | (none — project only) | Paths that trigger main-branch warnings |

Patterns from both plugin and project files are merged (union).

## Overriding skills

Place a skill with the same name in your project's `.claude/skills/`
directory. Claude Code's native precedence means the project skill
wins over the plugin skill.

Example: to customize `/pr` for your project, create
`.claude/skills/pr/SKILL.md` — the plugin's version is ignored.

## Overriding rules

Project-level rules in `.claude/rules/` load alongside plugin rules.
If a project rule contradicts a plugin rule, the project rule wins
(Claude Code applies project rules with higher priority).
