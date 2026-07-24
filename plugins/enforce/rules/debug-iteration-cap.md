---
description: Stop grinding after 2 failed debug attempts. Reframe before continuing.
globs: "**/*"
---

# Debug iteration cap

Do not attempt the same fix approach more than twice. After 2 failed
attempts at the same bug:

1. Stop modifying code.
2. Explain to the user: (a) what you tried, (b) your best hypothesis
   for the root cause, (c) what information you need to proceed.
3. Do not continue patching the same approach. Either propose a
   fundamentally different strategy or ask for help.
