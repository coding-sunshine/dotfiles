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

## Secrets

Never print or commit secrets. Keys live in `~/.env` (git-ignored) and are
exported into the shell. Reference env vars; don't hardcode values.
