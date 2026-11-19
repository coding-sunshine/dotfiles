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
#   - a plain file with the same content: relink
#   - a plain file that differs: it holds the newest edit, so copy it into
#     dotfiles and relink. If the dotfiles copy has uncommitted edits of its
#     own, it leaves both files alone and warns, so neither side's edit is lost.
# Messages go to stdout: at SessionStart that is what reaches the session.

DOT="${DOTFILES:-$HOME/.dotfiles}/ai/claude"
mkdir -p "$HOME/.claude"

for f in CLAUDE.md settings.json; do
  live="$HOME/.claude/$f"
  src="$DOT/$f"
  [ -f "$src" ] || continue
  [ -L "$live" ] && continue
  if [ -e "$live" ] && ! cmp -s "$live" "$src"; then
    if ! git -C "$DOT" diff --quiet -- "$f" 2>/dev/null; then
      echo "relink-config: ~/.claude/$f is no longer linked and $src has uncommitted edits; tell the user to merge the two by hand, then rerun ~/.claude/hooks/relink-config.sh."
      continue
    fi
    cp "$live" "$src" || continue
    echo "relink-config: copied ~/.claude/$f into dotfiles and relinked; tell the user to commit it in ~/.dotfiles."
  fi
  ln -sf "$src" "$live"
done

# Codex can't link to these, so rebuild its copy of the shared AGENTS.md too.
codex="${DOTFILES:-$HOME/.dotfiles}/ai/codex/sync-agents.sh"
[ -f "$codex" ] && sh "$codex"
exit 0
