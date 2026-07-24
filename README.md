# claude-governance

Mechanical enforcement governance for AI coding agents. Hooks that
block dangerous actions, skills that standardize workflows, and
negative-constraint rules that keep agents disciplined.

Built for Claude Code. Designed to be installed once and work across
all your projects.

## Install

```
/plugin marketplace add tristn/claude-governance
```

Or install from local path for development:
```
/plugin add /path/to/claude-governance
```

## What you get

### Hooks (mechanical enforcement)

| Hook | Event | What it does |
|------|-------|-------------|
| `pre-bash-guard` | PreToolUse(Bash) | Blocks credential exposure, force-push, `git add .` |
| `block-destructive-ops` | PreToolUse(Bash) | Blocks `rm -rf /`, DROP TABLE, fork bombs, etc. |
| `main-branch-guard` | PreToolUse(Bash) | Warns on non-trivial commits to main |
| `protect-sensitive-files` | PreToolUse(Edit/Write) | Blocks writes to .pem, .key, .env, credentials |
| `recursion-nudge` | PostToolUse(*) | Nudges after 20 consecutive tool calls without user input |
| `cost-tracker` | PostToolUse(*) | Logs tool usage per session to JSONL |

### Skills

| Skill | What it does |
|-------|-------------|
| `/pr` | Ship a PR: validate branch, push, create PR, CI, merge |
| `/session-close` | End-of-session checklist: ship work, update docs, run tests, verify handoff |
| `/session-start` | Read state, surface priorities, wait for direction |

### Rules (negative constraints)

- **Debug iteration cap** — Stop after 2 failed attempts, reframe
- **Test-driven fixes** — Write failing test before fixing bugs
- **Parallel agents** — Fan out independent tasks automatically
- **Plain English verdicts** — Explain decisions simply with recommendations
- **Anti-rationalization** — Don't skip quality steps, ever

## Customize

See [Override Guide](docs/override-guide.md) for full details.

Quick version: create `.claude/governance/config.json` in your
project to change thresholds. Add pattern files to extend defaults.
Override skills by placing your own in `.claude/skills/`.

## Philosophy

1. **Enforce with mechanisms, not prose.** Hooks that block are
   worth more than rules that suggest. (Validated by ETH Zurich
   2026 study — verbose instruction files hurt performance.)

2. **Negative constraints only.** "Don't do X" works. "Always do Y"
   doesn't. (Validated by arxiv study on 679 rule files.)

3. **Project-agnostic defaults, project-specific overrides.** The
   plugin ships sensible defaults. Your project extends them.

## Attribution

Cherry-picked patterns (all MIT licensed):
- Anti-rationalization tables: [agent-skills](https://github.com/addyosmani/agent-skills) by Addy Osmani
- Skill anatomy format: [agent-skills](https://github.com/addyosmani/agent-skills) by Addy Osmani
- Destructive command blocking patterns: [claude-setup](https://github.com/buildingopen/claude-setup)
- Sensitive file protection: [claude-setup](https://github.com/buildingopen/claude-setup)

## License

MIT
