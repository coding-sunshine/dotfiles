# Agent instructions (shared)

Canonical, tool-agnostic instructions for every coding agent I run (Claude Code,
Codex, Cursor, Gemini CLI). Tool-specific files import or point here.

## About me

PHP/Laravel (via Herd) + JS/TS + Python, on macOS (Apple Silicon). Heavy
AI-agent workflow; I value small, verifiable steps.

## Working style

- Smallest change that fully solves the task; match surrounding style, don't
  reformat unrelated lines.
- Reuse existing functions/utilities before adding new ones.
- State how you verified (tests run, output). Don't claim it works unchecked.
- Ask before destructive/hard-to-reverse actions (deletes, force-push, schema or
  data changes, anything outward-facing).

## Writing code — field notes (Karpathy, deduped vs above)

The model writes plausible code fast and notices "plausible ≠ correct" slow, so
discipline comes from process. Adds to Working style + `/ponytail`:

- **Read before write.** Read the files you'll touch; copy patterns that already
  exist; check the real imports/deps (no `axios` where it's all `fetch`). No
  pattern found → ask, don't guess.
- **Think before code.** State assumptions and name the tradeoff of the option
  you picked. Genuinely confused → stop and ask; never fill the gap with
  plausible code (that's what passes casual review and fails when it matters).
- **Verify by behavior.** On a bug, write the failing test first, watch it fail,
  then fix — proof you fixed the cause, not the symptom. Test behavior that can
  break, not that a constructor sets a field. Hard to test = design signal.
- **Goal first.** Restate the success criterion before coding ("reject malformed
  email → 400 + message, test both cases"); multi-step → state the plan first.
- **Debug, don't guess.** Read the whole error + stack, reproduce, change one
  thing at a time. Don't paper over an unexpected null with a null check — find
  why it's null.
- **Communicate.** Say what changed and why; flag concerns even when you did
  exactly what was asked; be precise about uncertainty ("unsure this lib supports
  streaming" beats "should work").

Already covered above: simplicity, surgical diffs, stdlib-first, named failure
modes (Working style + `/ponytail`).

## Stack conventions

PHP → Herd (`herd php artisan`, Pest, Pint) · JS/TS → pnpm/bun, type-check
before done · Python → uv + ruff. Fuller per-stack detail loads from
`.claude/rules/` (drop into a project with `rules-init`).

## Tooling

`rg`, `fd`, `fzf`, `eza`, `zoxide`, `git-delta`, `lazygit`, `direnv`, `gh`,
`docker`. Prefer `rg`/`fd` over `grep`/`find`. For code-structure/AST searches
(call patterns, signatures, structural refactors) prefer `ast-grep`/`sg` over the
Grep tool; keep `rg` for plain text.

## Capability map — reach for these automatically

When a task matches a row, use that tool without being asked. Skills are
progressive (load only when invoked), so routing is free until used.

| When you're…                                                                             | Reach for                                                 |
| ---------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| exploring an unfamiliar codebase / "how does X relate to Y"                              | `/graphify .` then query the graph                        |
| tracing callers / impact / blast-radius of a change                                      | code-review-graph (`graph-init` once, then `review-on`)   |
| doing a structural search or multi-file refactor                                         | the `ast-grep` skill (not regex)                          |
| building or polishing UI                                                                 | `frontend-design` / `impeccable` / `ui-ux-pro-max` skills |
| researching across many sources                                                          | `/deep-research`                                          |
| about to commit / open a PR                                                              | `verify` skill, then `/review` (or `/gstack-review`)      |
| planning a non-trivial feature                                                           | `/plan` (planner subagent) or `/gstack-spec`              |
| stress-testing a plan/spec or a tenancy / auth / security / money change before building | `agent-review-panel` (multi-agent adversarial debate)     |
| told to "just build it" from a feature list, unattended                                  | `autobuild features.md`                                   |
| running a big/verbose search or test sweep                                               | delegate to a subagent (summary only returns)             |
| running parallel agents on branches                                                      | `gwt new <branch>`                                        |
| a headless, budget-capped automation run                                                 | `claude-auto`                                             |
| over-engineering creeping in                                                             | `/ponytail`                                               |

Opt-in, toggle on then off: `superpowers-on`, `browser-on`, `github-on`,
`review-on`. `continuous-learning-v2` auto-learns your patterns — check
`/instinct-status` occasionally and promote good ones.

## Context & token discipline

- Delegate broad search / verbose runs to subagents — only the summary returns.
- Read just-in-time: keep paths/queries, read file _ranges_, not whole files.
- `/compact` at milestones; `/clear` when switching tasks (a long session
  re-reads its history every turn — cost grows with turn count).
- Protect the prompt cache (reads bill ~10% of input): pick model + effort at
  session start, save `/compact` for natural task breaks. Mid-task model/effort/
  fast-mode switches and MCP connect/disconnect each force a pricier uncached turn.
- Durable decisions persist via `MEMORY.md` + cavemem — don't re-derive them.
- Default effort `high`; reserve `xhigh`/`max` or workflow orchestration for
  genuinely hard problems.
- Keep the active MCP set lean and downshift `/model` for routine work; audit
  with `/context`. MCP is the biggest lever (~500 tok/tool — drop any a CLI
  replaces); flag skills >400 lines, rules >100, `CLAUDE.md` >300; stay <40% used.

## Browser automation

Default to the **Agent Browser** CLI (`agent-browser`, most token-efficient).
`npx playwright` for standard E2E. Only `browser-on` (Playwright + Chrome
DevTools MCP) for interactive/network/console debugging — `browser-off` after.

## Secrets

Never print or commit secrets. Keys live in `~/.env` (git-ignored), exported
into the shell. Reference env vars; don't hardcode.
