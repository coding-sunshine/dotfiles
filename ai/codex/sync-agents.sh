#!/bin/sh
# Build ~/.codex/AGENTS.md from the canonical ~/.dotfiles/ai/AGENTS.md.
#
# Codex reads that one file and has no @import, so it can't be a symlink to the
# Claude CLAUDE.md the way the other configs are. Other tools also write into it:
# base keeps its CLI guide and a <!-- BASE:WORKSPACES --> block there, and
# installers append sections (abliteration). Those must survive a rebuild.
#
# Layout of the built file:
#   generated part: Codex header + ai/AGENTS.md verbatim, ending at $END
#   tool-owned tail: everything below $END, kept byte for byte
# Before $END existed, the tail started at "## BASE CLI"; that fallback migrates
# the old hand-made file once.
#
# Runs from ai.sh and at Claude SessionStart (relink-config.sh), so an edit to
# ai/AGENTS.md reaches Codex without a manual step. Rewrites only on change.

DOT="${DOTFILES:-$HOME/.dotfiles}/ai"
out="$HOME/.codex/AGENTS.md"
END='<!-- dotfiles:end. Everything above is generated from ~/.dotfiles/ai/AGENTS.md by ai/codex/sync-agents.sh; edit that file. Tools may append below. -->'

[ -f "$DOT/AGENTS.md" ] || exit 0
mkdir -p "$HOME/.codex"
tmp="$(mktemp "$HOME/.codex/AGENTS.md.XXXXXX")" || exit 0

{
  cat <<'EOF'
# Global Codex instructions

User-level instructions for Codex on every project. The shared, tool-agnostic
guidance follows; Codex-specific notes are here.

## Codex specifics

- Keep commits scoped and messages descriptive; never commit `.env` or
  `*.local.json`.
- Model names in the routing table below are Claude tiers. In Codex, read them
  as "cheapest model that clears the bar" vs "strongest model".
- graphify: when the user types `/graphify`, read
  `~/.claude/skills/graphify/SKILL.md` and follow it before doing anything else.

EOF
  cat "$DOT/AGENTS.md"
  printf '\n%s\n' "$END"
  if [ -f "$out" ]; then
    if grep -qxF "$END" "$out"; then
      awk -v end="$END" 'found { print } $0 == end { found = 1 }' "$out"
    else
      echo
      awk '/^## BASE CLI/ { found = 1 } found { print }' "$out"
    fi
  fi
} > "$tmp"

if [ -f "$out" ] && cmp -s "$tmp" "$out"; then
  rm -f "$tmp"
else
  chmod 644 "$tmp"
  mv "$tmp" "$out"
fi
exit 0
