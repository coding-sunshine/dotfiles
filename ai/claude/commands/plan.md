---
description: Research the task and produce a step-by-step implementation plan
argument-hint: <what to plan>
allowed-tools: Task, Read, Grep, Glob
---

Produce an implementation plan for: $ARGUMENTS

Delegate to the `planner` subagent (it runs read-only on a stronger model and has
the full rubric); if it isn't available, plan it yourself with the same lens.
Pass enough context that it can work without re-asking. Return the plan — do not
start editing code until I approve the approach.
