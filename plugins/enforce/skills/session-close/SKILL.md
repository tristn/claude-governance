---
name: session-close
description: Session close checklist. Ships unpushed work, updates docs, runs tests, verifies handoff state. Project-agnostic.
user-invocable: true
disable-model-invocation: true
---

# /session-close -- End-of-Session Checklist

Generic session close. Projects can override by placing their own
`skills/session-close/SKILL.md` in `.claude/skills/`.

Only invoke when the user explicitly says they're wrapping up.

## Anti-rationalizations

| Excuse | Counter |
|--------|---------|
| "I'll push/update docs next session" | Next session starts cold. Unpushed work and stale docs are invisible. |
| "Tests passed earlier, no need to re-run" | Code changed since then. Run them now. |
| "The state doc is close enough" | If a cold reader can't orient from it, it's not close enough. |

## Steps

### 0. Ship unpushed branch work

If on a feature branch with commits ahead of the base branch, run
`/pr` to push, create/merge the PR, and return to main. If the user
wants to leave work unmerged (WIP), skip but document it in state docs.

### 1. Gather session context

- Review the conversation: what changed, what was learned, what's next.
- Run `git log --oneline -10` to see recent commits.

### 2. Update project state docs

Look for common state files and update them:
- `STATE.md` — update current status, decision point, next actions
- `ROADMAP.md` — mark completed items, add new ones
- `LEARNINGS.md` — append dated lessons from this session

If these files don't exist, skip (not every project uses them).

### 3. Run test suite

Auto-detect and run the project's test framework:
```bash
# Python
[[ -f "pytest.ini" || -f "pyproject.toml" || -d "tests" ]] && python -m pytest -q

# Node
[[ -f "package.json" ]] && npm test

# Go
[[ -f "go.mod" ]] && go test ./...

# Rust
[[ -f "Cargo.toml" ]] && cargo test
```

Report the count and any failures.

### 4. Verify no loose ends

- Check `git status` for uncommitted changes
- Check `git log --oneline origin/HEAD..HEAD` for unpushed commits
- Flag any TODOs added during this session

### 5. Verify handoff state

Re-read the project state doc (STATE.md or equivalent). Confirm a
cold agent starting a new session could orient from it alone. If it
depends on conversation context not on the page, fix it.

### 6. Report summary

One-paragraph summary: what was done, test status, what's next.
