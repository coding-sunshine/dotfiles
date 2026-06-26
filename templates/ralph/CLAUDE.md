# Ralph build loop — single iteration

You are running unattended in a loop. Each run starts with a fresh context.
Persistent state lives on disk: `.ralph/prd.json` (the backlog) and
`.ralph/progress.txt` (your running log). Read them; trust the git history.

## Do exactly one unit of work this run

0. Read `.ralph/progress.txt` FIRST. If a previous run already tried an approach
   for this story and it failed, do NOT repeat it — change tactic or block it.
1. Read `.ralph/prd.json`. Pick the FIRST story with `"passes": false` and not
   `"blocked": true`.
2. Implement it test-first: write a failing test, then the code to make it pass.
3. Run the project's gate (lint, type-check, tests). If red, fix until green —
   but after ~2 focused attempts that don't converge, stop thrashing: capture the
   exact failing output + relevant diff into `.ralph/progress.txt`, block the
   story (step in Rules), and end the run rather than burning iterations.
4. When green: set that story's `"passes": true` in `.ralph/prd.json`, then
   `git add -A && git commit` with a message referencing the story id.
5. Append a 2–3 line summary to `.ralph/progress.txt`: what you did, what's next.

## Rules

- One story per run. Do not start the next one.
- Your only memory across runs is `prd.json`, `progress.txt`, and git history —
  the next run starts blank and cannot see this context. Write `progress.txt` so
  it knows exactly where you stopped, what's next, and what NOT to retry.
- Reuse existing code and match the codebase style.
- If a story is ambiguous or blocked, write the blocker to `.ralph/progress.txt`,
  set `"blocked": true` on it in `prd.json`, and stop — never guess destructively.
- Never touch `.env`, secrets, or production data, and never force-push.
