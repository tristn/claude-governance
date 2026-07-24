# claude-governance

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-plugin%20marketplace-d97757.svg)](https://docs.claude.com/en/docs/claude-code/plugins)

A Claude Code plugin marketplace shipping two plugins: **enforce**, mechanical guardrails (hooks that block dangerous actions, skills that standardize workflows, negative-constraint rules), and **prompting**, the Anthropic Console Prompt Generator and Prompt Improver workflows as subagents with a `/prompt` router. Install once at user scope; both work across all your projects.

## Install

```bash
claude plugin marketplace add tristn/claude-governance
claude plugin install enforce@tristn-governance
claude plugin install prompting@tristn-governance
```

For local development, add the marketplace from a path instead:

```bash
claude plugin marketplace add /path/to/claude-governance
```

## enforce

Enforcement by mechanism, not prose. Hooks fire on tool events and block or warn before anything runs.

### Hooks

| Hook | Event | What it does |
|------|-------|--------------|
| `pre-bash-guard` | PreToolUse: Bash | Blocks credential exposure, force-push, `git add .` |
| `block-destructive-ops` | PreToolUse: Bash | Blocks `rm -rf /`, `DROP TABLE`, fork bombs, and similar patterns |
| `main-branch-guard` | PreToolUse: Bash | Warns on non-trivial commits to main (line threshold configurable) |
| `protect-sensitive-files` | PreToolUse: Edit, Write, MultiEdit | Blocks writes to `.pem`, `.key`, `.env`, credential files |
| `recursion-nudge` / `recursion-reset` | PostToolUse / UserPromptSubmit | Nudges after 20 consecutive tool calls without user input; counter resets on your next message |
| `cost-tracker` | PostToolUse | Logs per-session tool usage to JSONL |

### Skills

| Skill | What it does |
|-------|--------------|
| `/pr` | Ship a PR: validate branch, push, create PR, CI, merge |
| `/session-close` | End-of-session checklist: ship work, update docs, run tests, verify handoff |

### Rules (negative constraints)

| Rule | Constraint |
|------|------------|
| `debug-iteration-cap` | Stop after 2 failed fix attempts and reframe |
| `test-driven-fixes` | Write the failing test before fixing the bug |
| `parallel-agents` | Fan out independent tasks instead of running them serially |
| `plain-english-verdicts` | Pivotal decisions get options, tradeoff, recommendation in plain language |
| `anti-rationalization` | Quality steps are never skipped, whatever the excuse |

## prompting

| Component | What you get |
|-----------|--------------|
| `prompt-generator` (agent) | Task description in, production-ready prompt template out: variables, XML structure, examples. Saves to `prompts/<name>.md` |
| `prompt-improver` (agent) | Existing prompt in, diagnosed and restructured prompt out. Saves `*.improved.md` for reusable templates; returns inline for ephemeral prompts such as agent delegation handoffs |
| `/prompt` (command) | Routes free-form requests to the right subagent |

Both agents run `model: inherit`, so they follow your session model. For maximum prompt-craft quality regardless of session model, copy the agent into `~/.claude/agents/` and pin `model: opus` there.

## Configure and override

Precedence, highest first:

1. Environment variables (`GOVERNANCE_<KEY>=value`)
2. Project config (`.claude/governance/config.json`)
3. Plugin defaults (`plugins/enforce/config/defaults.json`)

Thresholds (recursion nudge, main-branch line count, cost tracking) are plain config keys. Pattern files in `.claude/governance/` (`blocked-credentials.txt`, `protected-files.txt`, `destructive-ops.txt`) extend the shipped defaults rather than replacing them. Override a shipped skill by placing your own version in `.claude/skills/`.

Full reference: [Override Guide](plugins/enforce/docs/override-guide.md).

## Philosophy

1. **Enforce with mechanisms, not prose.** Hooks that block are worth more than rules that suggest. (Consistent with the ETH Zurich 2026 finding that verbose instruction files hurt agent performance.)
2. **Negative constraints only.** "Don't do X" works; "always do Y" doesn't. (Consistent with the arXiv study of 679 rule files.)
3. **Project-agnostic defaults, project-specific overrides.** The plugin ships sensible defaults; your project extends them without forking.

## Attribution

Cherry-picked patterns, all MIT licensed:

- Anti-rationalization tables and skill anatomy format: [agent-skills](https://github.com/addyosmani/agent-skills) by Addy Osmani
- Destructive command blocking and sensitive-file protection patterns: [claude-setup](https://github.com/buildingopen/claude-setup)
- `plugins/prompting/reference/metaprompt-full.md`: verbatim from the [Anthropic cookbook metaprompt](https://platform.claude.com/cookbook/misc-metaprompt)

## License

MIT. See [LICENSE](LICENSE).
