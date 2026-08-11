#!/bin/zsh
# Daily auto-update: Claude Code skills (git clones) + plugins.
# Installed by launchd: ~/Library/LaunchAgents/com.hardikshah.ai-tools-update.plist
set -u
LOG="$HOME/.local/state/ai-tools-update.log"
mkdir -p "${LOG:h}"
exec >>"$LOG" 2>&1
echo "=== $(date '+%Y-%m-%d %H:%M') ==="

# gstack (pull + re-run setup so /gstack-* prefix survives)
if [ -d "$HOME/.claude/skills/gstack/.git" ]; then
  ( cd "$HOME/.claude/skills/gstack" && git pull --ff-only -q && ./setup --prefix >/dev/null && echo "gstack: $(git rev-parse --short HEAD)" )
fi

# skill git clones
for d in "$HOME/.agents/skills"/*/; do
  [ -d "$d/.git" ] || continue
  ( cd "$d" && git pull --ff-only -q && echo "$(basename $d): $(git rev-parse --short HEAD)" )
done

# claude plugins (names from installed_plugins.json)
if command -v claude >/dev/null && command -v jq >/dev/null; then
  for p in $(jq -r '.plugins | keys[]' "$HOME/.claude/plugins/installed_plugins.json"); do
    claude plugin update "$p" 2>&1 | tail -1
  done
fi

echo "done"
