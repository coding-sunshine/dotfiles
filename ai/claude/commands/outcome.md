---
description: Turn a one-off fix into a standing outcome — an invariant, the command that checks it, the access a loop needs, and a schedule that keeps it true
argument-hint: <the task or fix that should stay true>
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

Task: **$ARGUMENTS**

Ask what should happen after this task is done, and work at that level. "Fix
this crash" becomes "keep the app crash-free". "Make this test pass" becomes
"keep main green".

## 1. State the outcome

One sentence an outsider can check, and the command that decides it (exit 0
means it holds):

- "No unresolved production error older than 24h" → a Sentry query
- "`composer verify` passes on main" → `composer verify`
- "p95 of /dashboard under 200ms" → the benchmark command

## 2. Check the loop can run without me

A standing outcome only runs unattended if the agent can do three things on its
own. For each, name what provides it here, or mark it missing:

| need   | question                                                | examples                                                     |
| ------ | ------------------------------------------------------- | ------------------------------------------------------------ |
| see    | Can it fetch the failure signal itself?                 | Sentry MCP (`sentry-on`), logs, Herd `site error`, `gh run`  |
| locate | Can it map a signal to the exact code that produced it? | release tagged with the git SHA, version-to-commit mapping   |
| prove  | Can it reproduce and verify a fix independently?        | worktree with its own DB, failing test first, the check above |

Each missing need is a setup task, and it comes first. An outcome missing any of
the three is a reminder, not a loop.

## 3. Record it

If the repo keeps `todo/*.status.json`, add `todo/outcomes.status.json` in that
shape. Otherwise write `.claude/outcomes.json`:

```json
{
  "outcomes": [
    {
      "id": "crash-free",
      "outcome": "<the sentence from step 1>",
      "command": "<the check, exit 0 = holds>",
      "needs": { "see": "<source>", "locate": "<mapping>", "prove": "<how>" },
      "cadence": "daily",
      "status": "failing",
      "last_checked": null
    }
  ]
}
```

`status` is `passing` only after `command` ran and exited 0 in this session.
Unproven is `failing`.

## 4. Run the check once

Run `command` now and record `status` and `last_checked`. If it fails, the first
fix goes through `/contract`.

## 5. Offer the schedule

Ask before creating either; both act without me watching.

- `/schedule` runs a cloud agent on cron. It only sees what is committed and
  reachable from the cloud, so local-only signals (Herd, local logs) do not work
  there.
- `/loop` runs in this session on this machine.

Each run: check, and if it fails, reproduce, fix through `/contract`, re-run the
check, update `status`.
