#!/bin/sh

# Claude Code PostToolUse hook: auto-format the file an agent just edited.
# Receives the tool-call JSON on stdin; formats based on file extension.
# Best-effort and silent — never blocks the agent (always exits 0).

input="$(cat)"

file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
[ -n "$file" ] || exit 0
[ -f "$file" ] || exit 0

case "$file" in
  *.php)
    if [ -x vendor/bin/pint ]; then vendor/bin/pint "$file" >/dev/null 2>&1
    elif command -v pint >/dev/null 2>&1; then pint "$file" >/dev/null 2>&1
    fi
    ;;
  *.py)
    if command -v ruff >/dev/null 2>&1; then
      ruff format "$file" >/dev/null 2>&1
      ruff check --fix "$file" >/dev/null 2>&1
    fi
    ;;
  *.js|*.jsx|*.ts|*.tsx|*.vue|*.css|*.scss|*.json|*.md)
    if command -v prettier >/dev/null 2>&1; then prettier --write "$file" >/dev/null 2>&1
    else npx --no-install prettier --write "$file" >/dev/null 2>&1 || true
    fi
    ;;
esac

exit 0
