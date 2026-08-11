---
description: Contract loop — negotiate acceptance criteria with an adversarial critic, freeze them, build, then grade against the frozen contract
argument-hint: <what to build>
allowed-tools: Task, Read, Write, Edit, Grep, Glob, Bash
---

Build **$ARGUMENTS** using the contract loop. Criteria get frozen before any code
is written, and the work is graded against those frozen criteria — not against a
standard invented after the fact.

State lives in two files at the repo root. Create `.work/` if absent, and add it
to `.gitignore` if it is not already ignored.

## 1. Propose

Read the code the change touches. Write `.work/contract.md`:

```markdown
# Contract: <name>

## Scope
In: <what this covers>
Out: <what it explicitly does not>

## Criteria
| id | criterion | check |
|----|-----------|-------|
| c1 | <observable outcome> | <exact command, or file:line + what to see there> |

## Grading
Any criterion failing fails the item. No partial pass. Unverifiable scores 0.0.
```

Every criterion must pass the disagreement test — two reasonable engineers reading
it and the finished code cannot disagree about whether it passed. If a criterion
has no runnable check, it is not a criterion yet.

## 2. Negotiate

Send the contract to the `auditor` subagent in **NEGOTIATE** mode. Fix what it
rejects, add what it says is missing, resend. Loop until it returns `ACCEPT`.

Do not write implementation code during this phase. Arguing about the criteria is
cheap; arguing about finished code is not.

## 3. Freeze

On `ACCEPT`, write `.work/feature_list.json`:

```json
{
  "contract": ".work/contract.md",
  "items": [
    {
      "id": "c1",
      "name": "<criterion, one line>",
      "status": "failing",
      "verified_by": "<the exact command that decides it>",
      "notes": ""
    }
  ]
}
```

Rules for this file, which is why it is JSON and not Markdown:

- `status` is exactly `failing` or `passing`. There is no `in_progress`, no
  `partial`, no `blocked`. Something not yet proven is `failing`.
- `verified_by` is a runnable command. If a criterion genuinely cannot be decided
  by a command, `verified_by` is `manual: <file:line> — <exact observation>`, and
  only the auditor may mark it passing.
- Never delete or rewrite an item after the freeze. Add items only if the scope
  itself changed, and say so out loud when you do.
- Never edit `status` yourself. Only step 5 changes it.

## 4. Build

Implement. `.work/contract.md` is the spec — build to the criteria, not to your
reading of the original request.

## 5. Grade

Send the frozen contract and the diff to `auditor` in **GRADE** mode. Apply its
scores to `feature_list.json`: `1.0` → `passing`, `0.0` → `failing` with the
reason in `notes`.

Gate:

```bash
jq -e 'all(.items[]; .status == "passing")' .work/feature_list.json
```

Exit 0 means done. Exit 1 means fix the failing items and return to step 5 — not
to step 1, and not by editing the contract.

## Report

Ending state of `feature_list.json` (id, status, one-line reason for each failing
item), then anything the auditor filed under `OUT OF CONTRACT`.
