# Global Claude Code instructions

These are my user-level instructions for Claude Code on every project. The
canonical, tool-agnostic guidance lives in `AGENTS.md` (imported below); keep
Claude-specific notes in this file.

@~/.claude/AGENTS.md

## Claude Code specifics

- Use the available MCP servers (see `~/.claude.json` / the shared `mcp.json`)
  rather than shelling out when an MCP tool fits.
- Prefer the dedicated file/search tools (Read, Grep, Glob) over `cat`/`grep`/
  `find` in Bash.
- Run independent tool calls in parallel.
- Keep commits scoped and messages descriptive; never commit `.env` or
  `*.local.json`.
