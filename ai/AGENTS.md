# Agent instructions (shared)

Canonical, tool-agnostic instructions for every coding agent I run (Claude Code,
Codex, Cursor, Gemini CLI). Tool-specific files import or point at this file so
there is a single source of truth.

## About me

- Mixed stack: **PHP/Laravel** (via Herd), **JavaScript/TypeScript**, and
  **Python**.
- macOS (Apple Silicon, Tahoe / macOS 26).
- Heavy AI-agent-driven workflow; I value small, verifiable steps.

## Working style

- Make the smallest change that fully solves the task. Match the style of the
  surrounding code; do not reformat unrelated lines.
- Prefer reusing existing functions/utilities over adding new ones.
- After a change, state how it was verified (tests run, command output). Don't
  claim something works if it wasn't checked.
- Ask before destructive or hard-to-reverse actions (deletes, force-push,
  schema/data changes, anything outward-facing).

## Stack conventions

- **PHP/Laravel:** run artisan/composer/php via Herd (`herd php artisan ...`).
  Tests: `pest --no-coverage`. Lint/format: Pint.
- **JS/TS:** prefer `pnpm`; `bun` for scripts/speed. Type-check before declaring
  done.
- **Python:** use `uv` for envs/deps (`uv run`, `uv add`). Lint/format with
  `ruff`.

## Tooling available

`rg`, `fd`, `fzf`, `eza`, `zoxide`, `git-delta`, `lazygit`, `direnv`, `gh`,
`docker`. Prefer `rg`/`fd` over `grep`/`find`.

## Context & token discipline

Keep the working context small and the durable context known:

- Delegate broad search and verbose runs (test suites, log/doc trawling) to
  subagents — only their summary returns to the main thread.
- Read just-in-time: keep references (paths, queries) and read file *ranges*;
  don't dump whole large files.
- At milestones run `/compact`. Durable decisions persist via auto memory
  (`MEMORY.md`) and, when present, the cavemem store — don't re-derive them.
- `/clear` (or a fresh session) when switching to an unrelated task — a
  long-lived session re-reads its whole history every turn, so cost grows
  quadratically with turn count. Don't run one rolling session for days.
- Default effort is `high` (the cost/quality sweet spot). Reach for
  `/effort xhigh`/`max` or ultracode/workflow orchestration only on genuinely
  hard problems, not routine edits.
- Keep `CLAUDE.md` and rules under ~200 lines; scope detail to `.claude/rules/`.
- Watch the statusline / `/context` / `/cost`; keep the active MCP set lean and
  downshift the model (`/model`) for routine work.
- Audit periodically with `/context`. The always-on set is deliberately small
  (filesystem + context7 MCP); enable heavier tools only when needed —
  `github-on`, `browser-on`, `superpowers-on` — and turn them back off after.

## Browser automation

Default to the **Agent Browser** CLI (`agent-browser`) — it's the most
token-efficient (load workflows via `agent-browser skills get core` or `--help`).
Use `npx playwright` for authoring/running standard E2E tests. Only run
`browser-on` (Playwright MCP + Chrome DevTools MCP) when you need interactive MCP
control or network/console/performance debugging, and `browser-off` afterwards.

## Secrets

Never print or commit secrets. Keys live in `~/.env` (git-ignored) and are
exported into the shell. Reference env vars; don't hardcode values.
