# prompting

Anthropic Console's Prompt Generator and Prompt Improver workflows as
Claude Code subagents, plus a `/prompt` router.

- **prompt-generator** — task description in, production-ready prompt
  template out (variables, XML structure, examples). Saves to
  `prompts/<name>.md`.
- **prompt-improver** — existing prompt in, diagnosed and restructured
  prompt out. Saves `*.improved.md` for reusable templates; returns
  inline for ephemeral prompts (e.g. agent delegation handoffs).
- **/prompt** — routes free-form requests to the right subagent.

Both agents run `model: inherit` — they follow your session model. If
you want maximum prompt-craft quality regardless of session model,
copy the agent into your own `~/.claude/agents/` and pin
`model: opus` there.

`reference/metaprompt-full.md` is the verbatim upstream metaprompt for
human reference; the agents do not load it at runtime.

Install: `claude plugin install prompting@tristn-governance`
