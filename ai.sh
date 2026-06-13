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
link "$AI/claude/CLAUDE.md"      "$HOME/.claude/CLAUDE.md"
link "$AI/claude/settings.json"  "$HOME/.claude/settings.json"
link "$AI/claude/statusline.sh"  "$HOME/.claude/statusline.sh"
link "$AI/AGENTS.md"             "$HOME/.claude/AGENTS.md"
link "$AI/claude/hooks"          "$HOME/.claude/hooks"
link "$AI/claude/agents"         "$HOME/.claude/agents"
link "$AI/claude/commands"       "$HOME/.claude/commands"

# Skills: symlink each one individually so externally-installed skills (e.g.
# caveman) can live alongside ours without writing into the repo.
[ -L "$HOME/.claude/skills" ] && rm -f "$HOME/.claude/skills"
mkdir -p "$HOME/.claude/skills"
for skill in "$AI"/claude/skills/*/; do
  [ -d "$skill" ] || continue
  name="$(basename "$skill")"
  rm -rf "$HOME/.claude/skills/$name"
  ln -s "${skill%/}" "$HOME/.claude/skills/$name"
  echo "  linked ~/.claude/skills/$name -> ${skill%/}"
done

# Codex CLI (reads AGENTS.md automatically)
link "$AI/codex/config.toml"    "$HOME/.codex/config.toml"
link "$AI/AGENTS.md"            "$HOME/.codex/AGENTS.md"

# Gemini CLI
link "$AI/gemini/settings.json" "$HOME/.gemini/settings.json"
link "$AI/AGENTS.md"            "$HOME/.gemini/AGENTS.md"

# Wire up the cavemem persistent-memory engine (local, compressed, survives
# /compact). Best-effort — installed as a global npm package by fresh.sh.
if command -v cavemem >/dev/null 2>&1; then
  cavemem install >/dev/null 2>&1 \
    && echo "  cavemem memory engine wired" \
    || echo "  (cavemem install skipped)"
fi

# Register shared MCP servers with the Claude CLI (best-effort).
if command -v claude >/dev/null 2>&1; then
  echo "  registering MCP servers with claude..."
  for srv in filesystem github context7; do
    claude mcp add-json --scope user "$srv" \
      "$(jq -c ".mcpServers.$srv" "$AI/mcp/mcp.json")" 2>/dev/null \
      || echo "  ($srv MCP already registered or failed — skipping)"
  done
  # composio is heavy — register only when an API key is present.
  if [ -n "$COMPOSIO_API_KEY" ]; then
    claude mcp add-json --scope user composio \
      "$(jq -c '.mcpServers.composio' "$AI/mcp/mcp.json")" 2>/dev/null \
      || echo "  (composio MCP already registered or failed — skipping)"
  fi

  # Install official plugins (best-effort; never fail setup).
  claude plugin marketplace add anthropics/claude-code >/dev/null 2>&1 || true
  for plugin in feature-dev code-review; do
    claude plugin install "$plugin" >/dev/null 2>&1 || true
  done
else
  echo "  claude CLI not found yet — re-run ./ai.sh after Brewfile install."
fi

echo "AI agent layer ready. Edit configs in $AI and re-run ./ai.sh to update."
