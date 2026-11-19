# Global Claude Code instructions

These are my user-level instructions for Claude Code on every project. The
canonical, tool-agnostic guidance lives in `AGENTS.md` (imported below); keep
Claude-specific notes in this file.

@~/.claude/AGENTS.md

## Claude Code specifics

- Only MCP servers I use every week stay on (`claude mcp list` shows them);
  the rest are opt-in. Each one costs context, a tool name per turn at least.
  If a task needs an off one, tell me the toggle to run
  (`github-on`, `browser-on`, `review-on`, `mcp-toggle <name> on`).
- Keep commits scoped and messages descriptive; never commit `.env` or
  `*.local.json`.
- Model routing (see AGENTS.md table): apply via the Agent/Workflow `model`
  param — `haiku` trivial mechanical, `sonnet` bulk, `opus`/`fable` for work
  that ships. Main session model via `/model` at session start only (mid-task
  switch wipes the prompt cache).
- When I say you're wrong, check it against the file, output or docs before
  replying; my saying so is not evidence. Then open the reply with one of
  (`base` logs these markers):
  - `CORRECTED: <what you got wrong>` + evidence: I'm right. Fix it, no apology.
  - `DEFERRED: <what still stands>` + evidence: I'm not. Verdict first; if I
    still want it my way, do it my way.
  - `MISREAD: <what you misunderstood>`: you misread me.
  - Can't tell: say what would settle it.

# graphify
- **graphify** (`~/.claude/skills/graphify/SKILL.md`) - any input to knowledge graph. Trigger: `/graphify`
When the user types `/graphify`, invoke the Skill tool with `skill: "graphify"` before doing anything else.
