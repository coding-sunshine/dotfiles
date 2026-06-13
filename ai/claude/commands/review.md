---
description: Review the current changes for bugs, security, and cleanups
allowed-tools: Bash(git diff:*), Bash(git status:*), Read, Grep, Glob
---

Review the current working-tree changes. Delegate to the `code-reviewer`
subagent (it has the full rubric and runs on a stronger model); if it isn't
available, review them yourself using the same correctness/security/reuse lens.

Start from `git status` and `git diff HEAD`. Report findings grouped by severity
(🔴 must / 🟡 should / 🟢 nit) with file:line and a concrete fix each. If the diff
is clean, say so — don't invent issues.

$ARGUMENTS
