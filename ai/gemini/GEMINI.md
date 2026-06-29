# Antigravity / Gemini global instructions

User-level instructions for Antigravity (the `agy` CLI + IDE) and Gemini CLI.
The canonical, tool-agnostic guidance lives in `AGENTS.md` — Antigravity and
Gemini read it automatically from this same directory, so it is NOT imported
here (importing would double-load it). Keep only Antigravity/Gemini-specific
notes in this file.

Note: `~/.gemini/GEMINI.md` is shared — both Antigravity and Gemini CLI read it,
and GEMINI.md wins over AGENTS.md on a direct conflict. So keep this file thin
and let AGENTS.md carry the actual rules (the same ones Claude Code follows).

## Antigravity / Gemini specifics

- Follow AGENTS.md: working style, the code-writing field notes, the quality bar,
  and context discipline. Don't restate those rules here.
- Use configured MCP servers rather than shelling out when an MCP tool fits.
- Prefer built-in file/search tools over `cat`/`grep`/`find` in the terminal.
- Run independent actions in parallel.
- Keep commits scoped and messages descriptive; never commit `.env` or
  `*.local.json`.

## Cost — flat-rate, unlike Claude Code

- Antigravity coding runs on the flat AI Pro plan: pick an AI Pro model
  (`agy models` lists them). Don't spend metered Gemini API quota on routine work.
- The Claude weekly-Opus-cap and haiku/sonnet/opus tiering in AGENTS.md are
  Claude-specific — ignore them here. Flat plan = optimize for results, not tokens.

## Workflow

- Use the Artifact / agent-manager flow for multi-step tasks; review the plan
  Artifact before letting it run.
- `--sandbox` for untrusted or destructive runs; `--dangerously-skip-permissions`
  only after you've scoped the work.
- Project-specific rules go in `.agents/rules/*.md` in the repo, not here.
