# Skill Anatomy

Every skill in this plugin follows a consistent structure.
Based on patterns from agent-skills (Addy Osmani).

## Required sections

```markdown
---
name: skill-name
description: One-line description of what the skill does.
user-invocable: true
disable-model-invocation: true
---

# /skill-name -- Human-Readable Title

One paragraph: what this skill does and when to use it.

## Anti-rationalizations

| Excuse | Counter |
|--------|---------|
| "Reason to skip this" | Why that's wrong |

## Steps

### 1. First step
...
```

## Why anti-rationalization tables

Research shows AI agents rationalize skipping steps under time
pressure or when they assess a step as low-value. The table
pre-loads counter-arguments so the agent encounters them before
it can talk itself out of compliance.

## Why negative constraints

Arxiv research on 679 rule files (25,532 rules) found that only
negative constraints ("do not X") reliably improve agent performance.
Positive directives ("always do Y") can actually hurt. Rules in
this plugin are structured as constraints, not instructions.
