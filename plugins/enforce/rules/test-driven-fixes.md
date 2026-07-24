---
description: Write a failing test before fixing a bug. Never fix blind.
globs: "**/*"
---

# Test-driven bug fixes

When fixing a bug:

1. Do not modify implementation code first.
2. Write a test that reproduces the exact failure. Run it. Confirm
   it fails.
3. Only then modify implementation code.
4. Run the full test suite after each edit.
5. If 3 implementation attempts fail, stop and propose a
   fundamentally different approach to the user.
