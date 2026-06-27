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

| When you're… | Reach for |
|---|---|
| exploring an unfamiliar codebase / "how does X relate to Y" | `/graphify .` then query the graph |
| tracing callers / impact / blast-radius of a change | code-review-graph (`graph-init` once, then `review-on`) |
| doing a structural search or multi-file refactor | the `ast-grep` skill (not regex) |
| building or polishing UI | `frontend-design` / `impeccable` / `ui-ux-pro-max` skills |
| researching across many sources | `/deep-research` |
| about to commit / open a PR | `verify` skill, then `/review` (or `/gstack-review`) |
| planning a non-trivial feature | `/plan` (planner subagent) or `/gstack-spec` |
| stress-testing a plan/spec or a tenancy / auth / security / money change before building | `agent-review-panel` (multi-agent adversarial debate) |
| told to "just build it" from a feature list, unattended | `autobuild features.md` |
| running a big/verbose search or test sweep | delegate to a subagent (summary only returns) |
| running parallel agents on branches | `gwt new <branch>` |
| a headless, budget-capped automation run | `claude-auto` |
| over-engineering creeping in | `/ponytail` |

Opt-in, toggle on then off: `superpowers-on`, `browser-on`, `github-on`,
`review-on`. `continuous-learning-v2` auto-learns your patterns — check
`/instinct-status` occasionally and promote good ones.

## Context & token discipline

- Delegate broad search / verbose runs to subagents — only the summary returns.
- Read just-in-time: keep paths/queries, read file *ranges*, not whole files.
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
