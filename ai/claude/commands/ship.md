---
description: Run the full quality gate then commit — verify, review, commit
argument-hint: [commit message]
allowed-tools: Bash, Task, Read, Edit, Grep, Glob
---

Ship the current changes through the full gate. Stop and report at the first hard
failure — never commit broken code.

1. **Verify** — run the `verify` skill (it detects the stack and runs
   lint, type-check, and tests).
2. **Review** — delegate the working-tree diff to the `code-reviewer` subagent.
   Fix 🔴 must-fix findings; surface 🟡/🟢 for my call.
3. **Security** — run the `/security-review` skill on the diff. Treat anything it
   flags as a 🔴 must-fix (auth, secrets, injection, unsafe input) before commit.
4. **Commit** — only if 1–3 pass. Stage and commit with a clear message
   ($ARGUMENTS if given, otherwise write an accurate one from the diff).
   Never stage `.env` or `*.local.*`. Do not push unless I ask.
