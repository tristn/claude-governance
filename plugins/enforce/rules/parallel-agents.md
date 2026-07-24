---
description: Prefer parallel agent dispatch when tasks are independent.
globs: "**/*"
---

# Parallel agents by default

When multiple tasks are independent of each other (no data
dependency, no ordering requirement), dispatch them as parallel
Agent calls in a single message. Do not run them sequentially.

Do not wait for the user to ask for parallelism — recognize
independence and parallelize automatically. Examples:
- Implementing two unrelated modules
- Researching across different topic areas
- Running tests while writing documentation
