# Global Claude Code instructions

These are my user-level instructions for Claude Code on every project. The
canonical, tool-agnostic guidance lives in `AGENTS.md` (imported below); keep
Claude-specific notes in this file.

@~/.claude/AGENTS.md

## Claude Code specifics

- No MCP server is always-on (each re-sends its schema every turn and on every
  subagent spawn). If a task needs one, tell me the toggle to run
  (`github-on`, `browser-on`, `review-on`, `mcp-toggle <name> on`).
- Keep commits scoped and messages descriptive; never commit `.env` or
  `*.local.json`.
- Model routing (see AGENTS.md table): apply via the Agent/Workflow `model`
  param — `haiku` trivial mechanical, `sonnet` bulk, `opus` for work that
  ships. Main session model via `/model` at session start only (mid-task
  switch wipes the prompt cache).
# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
