# prompting

Anthropic Console's Prompt Generator and Prompt Improver workflows as
Claude Code subagents (prompt-generator, prompt-improver), plus a
`/prompt` router. Component table and usage: [root README](../../README.md).

Both agents run `model: inherit` — they follow your session model. For
maximum prompt-craft quality regardless of session model, copy the
agent into `~/.claude/agents/` and pin `model: opus` there.

`reference/metaprompt-full.md` is the verbatim upstream metaprompt for
human reference; the agents do not load it at runtime.

Install: `claude plugin install prompting@tristn-governance`
