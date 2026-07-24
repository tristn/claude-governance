---
description: Generate or improve a prompt template using the prompt-engineer subagents
argument-hint: [task description, or path to existing prompt]
---

You are about to either generate a new prompt or improve an existing one.

The user's request: $ARGUMENTS

Decide which subagent fits:
- If the user is describing a NEW task they want a prompt for, use the
  Task tool with the `prompt-generator` subagent.
- If the user pointed at an existing prompt (file path, pasted prompt
  text, or said "improve" / "fix" / "make better"), use the Task tool
  with the `prompt-improver` subagent.
- If unclear, ask one short clarifying question first.

Do not attempt the prompt engineering yourself in the main thread — always delegate so the work happens in the subagent's isolated context.
