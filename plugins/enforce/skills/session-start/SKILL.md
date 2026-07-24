---
name: session-start
description: Session start sequence. Reads project state, surfaces priorities, waits for user direction. Project-agnostic.
user-invocable: true
disable-model-invocation: true
---

# /session-start -- Begin a Session

Generic session start. Projects can override by placing their own
`skills/session-start/SKILL.md` in `.claude/skills/`.

Every non-trivial session starts by reading state, not by coding.

## Anti-rationalizations

| Excuse | Counter |
|--------|---------|
| "I know what to work on, skip orientation" | Last session's context is gone. Read state first — 30 seconds prevents hours of misdirection. |
| "I'll just start coding and figure it out" | Working without priorities means working on the wrong thing. Orient first. |
| "The user already told me what to do" | Even with a direct task, reading state catches conflicts and blockers you'd miss. |

## Steps

### 1. Read project state

Look for and read orientation docs:
- `STATE.md` — current status, decision point, next actions
- `README.md` — project overview (if no STATE.md)
- Recent git log: `git log --oneline -5`

### 2. Check task board (if available)

Try to read project tasks:
```bash
# GitHub Projects
gh project item-list 2 --owner $(gh repo view --json owner -q .owner.login) 2>/dev/null

# Or GitHub Issues
gh issue list --state open --limit 10 2>/dev/null
```

### 3. Surface priorities

Present the top 2-3 items with a one-line recommendation for which
to pick and why. Use this priority order:
1. Critical path (blocks other work)
2. Compounding workflow gains (makes future work faster)
3. Warmups (low-risk, builds momentum)

Name the tradeoff between options.

### 4. Wait for user direction

Ask: "Which would you like to work on, or did you have something
else in mind?"

**Never auto-claim work. Never start coding without asking.**

If the user asks for work not on the board, note it (create an
issue if a board exists) before starting.
