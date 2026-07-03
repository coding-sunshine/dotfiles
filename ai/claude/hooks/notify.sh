#!/usr/bin/env bash
# Notification hook: macOS banner when a session needs attention
# (permission request, or idle waiting for input). Silent no-op on failure.
input="$(cat)"
msg="$(printf '%s' "$input" | jq -r '.message // "needs your attention"' 2>/dev/null)"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
proj="${cwd##*/}"
title="Claude — ${proj:-session}"

osascript -e "display notification \"${msg//\"/\\\"}\" with title \"${title//\"/\\\"}\" sound name \"Glass\"" >/dev/null 2>&1

exit 0
