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

# Install agent skills via the `npx skills` ecosystem (best-effort). These are
# thin, progressive-disclosure skills (~100 tokens frontmatter each), so they're
# cheap to keep always-on. Land in the user skills dir, coexisting with ours.
if command -v npx >/dev/null 2>&1; then
  echo "  installing agent skills (npx skills)..."
  npx -y skills add vercel-labs/agent-browser -g -y >/dev/null 2>&1 || true            # token-lean browser CLI
  npx -y skills add anthropics/skills@frontend-design -g -y >/dev/null 2>&1 || true     # non-AI-looking UI
  npx -y skills add vercel-labs/agent-skills@web-design-guidelines -g -y >/dev/null 2>&1 || true  # UI audit
fi

# gstack — Garry Tan's command framework. Installed PREFIXED (/gstack-*) so it
# coexists with our /review //ship //plan instead of colliding. Best-effort.
if command -v bun >/dev/null 2>&1 && command -v git >/dev/null 2>&1; then
  if [ ! -d "$HOME/.claude/skills/gstack" ]; then
    echo "  installing gstack (/gstack-* commands)..."
    git clone --single-branch --depth 1 https://github.com/garrytan/gstack.git \
      "$HOME/.claude/skills/gstack" >/dev/null 2>&1 \
      && ( cd "$HOME/.claude/skills/gstack" && ./setup --prefix >/dev/null 2>&1 ) \
      && echo "  gstack installed" \
      || echo "  (gstack install skipped)"
  fi
else
  echo "  (skipping gstack — needs bun + git)"
fi

# Register MCP servers with the Claude CLI (best-effort).
if command -v claude >/dev/null 2>&1; then
  echo "  registering MCP servers with claude..."
  # Lean always-on set only. github/playwright/chrome-devtools are opt-in via
  # `mcp-toggle <name> on` (github-on / browser-on) to keep per-turn tokens low.
  for srv in filesystem context7; do
    claude mcp add-json --scope user "$srv" \
      "$(jq -c ".mcpServers.$srv | with_entries(select(.key|startswith(\"//\")|not))" "$AI/mcp/mcp.json")" 2>/dev/null \
      || echo "  ($srv MCP already registered or failed — skipping)"
  done
  # composio is heavy — register only when an API key is present.
  if [ -n "$COMPOSIO_API_KEY" ]; then
    claude mcp add-json --scope user composio \
      "$(jq -c '.mcpServers.composio | with_entries(select(.key|startswith("//")|not))' "$AI/mcp/mcp.json")" 2>/dev/null \
      || echo "  (composio MCP already registered or failed — skipping)"
  fi

  # Official plugins (best-effort; never fail setup).
  claude plugin marketplace add anthropics/claude-code >/dev/null 2>&1 || true
  for plugin in feature-dev code-review; do
    claude plugin install "$plugin" >/dev/null 2>&1 || true
  done

  # Superpowers: install but DISABLE by default (it preloads ~22k tokens when
  # active). Toggle per session with `superpowers-on` / `superpowers-off`.
  claude plugin marketplace add obra/superpowers-marketplace >/dev/null 2>&1 || true
  claude plugin install superpowers@superpowers-marketplace >/dev/null 2>&1 || true
  claude plugin disable superpowers@superpowers-marketplace >/dev/null 2>&1 || true
else
  echo "  claude CLI not found yet — re-run ./ai.sh after Brewfile install."
fi

echo "AI agent layer ready. Edit configs in $AI and re-run ./ai.sh to update."
