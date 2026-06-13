#!/bin/sh

# Sets up the AI agent config layer by symlinking the versioned configs in
# ./ai into the locations each tool expects, and registering shared MCP servers.
# Idempotent: safe to re-run. Called by fresh.sh, or run standalone.

set -e

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
AI="$DOTFILES/ai"

echo "Setting up AI agent layer..."

link() {
  # link <source> <target> — works for files and directories
  mkdir -p "$(dirname "$2")"
  rm -rf "$2"
  ln -s "$1" "$2"
  echo "  linked $2 -> $1"
}

# Claude Code
link "$AI/claude/CLAUDE.md"     "$HOME/.claude/CLAUDE.md"
link "$AI/claude/settings.json" "$HOME/.claude/settings.json"
link "$AI/AGENTS.md"            "$HOME/.claude/AGENTS.md"
link "$AI/claude/hooks"         "$HOME/.claude/hooks"
link "$AI/claude/skills"        "$HOME/.claude/skills"
link "$AI/claude/agents"        "$HOME/.claude/agents"
link "$AI/claude/commands"      "$HOME/.claude/commands"

# Codex CLI (reads AGENTS.md automatically)
link "$AI/codex/config.toml"    "$HOME/.codex/config.toml"
link "$AI/AGENTS.md"            "$HOME/.codex/AGENTS.md"

# Gemini CLI
link "$AI/gemini/settings.json" "$HOME/.gemini/settings.json"
link "$AI/AGENTS.md"            "$HOME/.gemini/AGENTS.md"

# Register shared MCP servers with the Claude CLI (best-effort).
if command -v claude >/dev/null 2>&1; then
  echo "  registering MCP servers with claude..."
  claude mcp add-json --scope user filesystem \
    "$(jq -c '.mcpServers.filesystem' "$AI/mcp/mcp.json")" 2>/dev/null \
    || echo "  (filesystem MCP already registered or failed — skipping)"
  claude mcp add-json --scope user github \
    "$(jq -c '.mcpServers.github' "$AI/mcp/mcp.json")" 2>/dev/null \
    || echo "  (github MCP already registered or failed — skipping)"
else
  echo "  claude CLI not found yet — re-run ./ai.sh after Brewfile install."
fi

echo "AI agent layer ready. Edit configs in $AI and re-run ./ai.sh to update."
