#!/bin/sh
# Keep ~/.claude/CLAUDE.md and ~/.claude/settings.json linked to the dotfiles copies.
#
# A tool that saves one of them by writing a new file and renaming it over the
# old one (Claude Code itself, a plugin or a hook installer) swaps the symlink
# for a plain file. From then on the edit lands only in ~/.claude and the
# dotfiles copy goes stale. Both links broke this way once without anyone
# noticing.
#
# Runs at SessionStart and from ai.sh. What it does for each of the two files:
#   - already a link: nothing
#   - missing: link it
#   - a plain file: that file holds the newest edit, so copy it into dotfiles
#     and relink. If the dotfiles copy has uncommitted edits of its own, it
#     leaves both files alone and warns, so neither side's edit is lost.

DOT="${DOTFILES:-$HOME/.dotfiles}/ai/claude"
mkdir -p "$HOME/.claude"

for f in CLAUDE.md settings.json; do
  live="$HOME/.claude/$f"
  src="$DOT/$f"
  [ -f "$src" ] || continue
  [ -L "$live" ] && continue
  if [ -e "$live" ]; then
    if ! git -C "$DOT" diff --quiet -- "$f" 2>/dev/null; then
      echo "relink-config: ~/.claude/$f is no longer linked and $src has uncommitted edits; merge the two by hand, then rerun." >&2
      continue
    fi
    cp "$live" "$src" || continue
    echo "relink-config: copied ~/.claude/$f into dotfiles (commit it) and relinked."
  fi
  ln -sf "$src" "$live"
done

# Codex can't link to these, so rebuild its copy of the shared AGENTS.md too.
sh "${DOTFILES:-$HOME/.dotfiles}/ai/codex/sync-agents.sh"
exit 0
