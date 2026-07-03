#!/usr/bin/env bash
# Notification hook: macOS banner when a session needs attention
# (permission request, or idle waiting for input). Click focuses the
# terminal app the session runs in. Silent no-op on failure.
input="$(cat)"
msg="$(printf '%s' "$input" | jq -r '.message // "needs your attention"' 2>/dev/null)"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
proj="${cwd##*/}"
title="Claude — ${proj:-session}"

# Hook inherits the session's env; TERM_PROGRAM tells us which terminal to focus.
# ponytail: app-level focus only — exact tab/pane needs per-terminal AppleScript
# that Ghostty/cmux don't expose.
case "${TERM_PROGRAM:-}" in
  ghostty)        bundle="com.mitchellh.ghostty" ;;
  iTerm.app)      bundle="com.googlecode.iterm2" ;;
  Apple_Terminal) bundle="com.apple.Terminal" ;;
  vscode)         bundle="com.microsoft.VSCode" ;;
  WarpTerminal)   bundle="dev.warp.Warp-Stable" ;;
  *)              bundle="" ;;
esac

if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier -title "$title" -message "$msg" -sound Glass \
    ${bundle:+-activate "$bundle"} >/dev/null 2>&1
else
  osascript -e "display notification \"${msg//\"/\\\"}\" with title \"${title//\"/\\\"}\" sound name \"Glass\"" >/dev/null 2>&1
fi

exit 0
