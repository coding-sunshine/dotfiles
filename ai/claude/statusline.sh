#!/bin/sh

# Claude Code statusLine: model · branch · context-usage bar · session cost.
# Reads the statusLine JSON on stdin. Cheap (parses only the transcript tail)
# and degrades gracefully when jq or the transcript is unavailable.

input="$(cat)"

# Without jq we can't parse the payload — print a minimal line and bail.
if ! command -v jq >/dev/null 2>&1; then
  printf 'claude'
  exit 0
fi

model="$(printf '%s' "$input" | jq -r '.model.display_name // "claude"')"
cwd="$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')"
cost="$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // empty')"
transcript="$(printf '%s' "$input" | jq -r '.transcript_path // empty')"
big="$(printf '%s' "$input" | jq -r '.exceeds_200k_tokens // false')"

# Git branch (cheap; silent outside a repo).
branch=""
[ -n "$cwd" ] && branch="$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"

# Context usage from the most recent transcript entry that carries token usage.
# Scan only the tail so this stays fast on long sessions.
window=200000
[ "$big" = "true" ] && window=1000000
pct=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  used="$(tail -n 50 "$transcript" 2>/dev/null | jq -rs '
    [ .[] | .message?.usage? | select(. != null)
      | (.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0)
    ] | last // empty' 2>/dev/null)"
  case "$used" in
    ''|*[!0-9]*) used="" ;;
  esac
  if [ -n "$used" ] && [ "$used" -gt 0 ]; then
    pct=$(( used * 100 / window ))
    [ "$pct" -gt 100 ] && pct=100
  fi
fi

# 10-cell bar for the context percentage.
bar=""
if [ -n "$pct" ]; then
  filled=$(( pct / 10 ))
  i=0
  while [ "$i" -lt 10 ]; do
    if [ "$i" -lt "$filled" ]; then bar="${bar}█"; else bar="${bar}░"; fi
    i=$(( i + 1 ))
  done
fi

out="$model"
[ -n "$branch" ] && out="$out · ⎇ $branch"
[ -n "$pct" ]    && out="$out · $bar ${pct}%"
[ -n "$cost" ]   && out="$out · \$$(printf '%.2f' "$cost" 2>/dev/null || printf '%s' "$cost")"

# Warn when the session is getting expensive — nudge to /clear. A long-lived
# session re-reads its whole history every turn, so cost grows quadratically.
if [ -n "$cost" ]; then
  warn="$(awk -v c="$cost" 'BEGIN { c+=0; if (c>=10) print "\xe2\x9a\xa0 pricey-/clear?"; else if (c>=5) print "\xe2\x86\xb3 /clear soon" }')"
  [ -n "$warn" ] && out="$out · $warn"
fi

# Cross-session spend (today's total + burn rate) via ccusage, if installed —
# the always-on visibility layer. Graceful: skipped if ccusage is missing/errors.
ccusage_bin="$(command -v ccusage 2>/dev/null || true)"
[ -z "$ccusage_bin" ] && [ -x "$HOME/.bun/bin/ccusage" ] && ccusage_bin="$HOME/.bun/bin/ccusage"
if [ -n "$ccusage_bin" ]; then
  cc="$(printf '%s' "$input" | "$ccusage_bin" statusline --visual-burn-rate emoji 2>/dev/null || true)"
  today="$(printf '%s' "$cc" | sed -n 's@.*/ \(\$[0-9.,]*\) today.*@\1@p')"
  burn="$(printf '%s' "$cc" | grep -oE '🔥 \$[0-9.,]+/hr' | head -1)"
  [ -n "$today" ] && out="$out · $today today"
  [ -n "$burn" ] && out="$out · $burn"
fi

printf '%s' "$out"
