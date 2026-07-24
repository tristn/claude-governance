---
name: pr
description: Ship a Pull Request. Validates branch state, pushes, creates PR, waits for CI, merges. Project-agnostic.
user-invocable: true
disable-model-invocation: true
---

# /pr -- Ship a Pull Request

Generic PR workflow. Projects can override by placing their own
`skills/pr/SKILL.md` in `.claude/skills/`.

## Prerequisites

- On a feature branch (not main/master).
- At least one commit ahead of the base branch.
- User has confirmed the work is ready.

## Anti-rationalizations

| Excuse | Counter |
|--------|---------|
| "It's a small change, I'll push to main" | Small changes on main skip review. If it touches logic, branch. |
| "CI is slow, I'll merge without waiting" | CI exists to catch what you missed. Wait. |
| "I'll create the PR later" | Unpushed work is invisible work. Ship now or note it as WIP. |

## Steps

### 1. Validate branch state

```bash
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  echo "FAIL: on $BRANCH — create a feature branch first."
  exit 1
fi
AHEAD=$(git rev-list --count main..HEAD 2>/dev/null || git rev-list --count master..HEAD 2>/dev/null || echo 0)
if [[ "$AHEAD" -eq 0 ]]; then
  echo "FAIL: no commits ahead of base branch."
  exit 1
fi
echo "Branch: $BRANCH, $AHEAD commit(s) ahead"
```

### 2. Check for uncommitted changes

If there are unstaged or staged-but-uncommitted changes, ask the
user whether to commit them or stash before proceeding.

### 3. Push branch

```bash
git push -u origin $(git branch --show-current)
```

### 4. Determine linked issue

Check git log and branch name for an issue number. Common patterns:
- Branch named `feature/issue-42-add-foo` → issue #42
- Commit message containing `#42` or `Closes #42`

If unclear, ask the user for the issue number. If there's no linked
issue, create the PR without `Closes #N`.

### 5. Create PR

```bash
gh pr create --title "<concise title under 70 chars>" --body "Closes #<N>

## Summary
<bullet points describing what changed and why>

## Test plan
<checklist of verification steps>"
```

### 6. Wait for CI and merge

```bash
gh pr checks --watch
gh pr merge --squash --delete-branch
```

If CI fails: fix, push, and re-watch. Do NOT merge on failure.

### 7. Return to base branch

```bash
git checkout main && git pull
```

Report the merged PR URL to the user.
