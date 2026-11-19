#!/usr/bin/env bash
# SessionStart hook — cost discipline. Injects a one-line reminder every session
# and warns if the session model is Fable (metered). Opus is the chosen session
# default (settings.json), so it gets no warning.
#
# Why only a reminder: Claude Code hooks CANNOT block or reliably detect
# mid-session model/effort/fast switches (internal/menu actions — no hook fires),
# and the active MCP-server list is not exposed to hooks. So the real levers are
# the settings defaults (opus session / haiku background / subagent tiers)
# plus this front-of-mind nudge. Disable: remove the SessionStart block in settings.json.
set -eu

input="$(cat 2>/dev/null || true)"
model="$(printf '%s' "$input" | jq -r '(.model | if type=="object" then .id else . end) // empty' 2>/dev/null || true)"

printf '↳ cost discipline: session=opus · subagents haiku=trivial, sonnet=bulk | no mid-session model/effort/fast switch (cache wipe) | /clear between tasks · /compact at breaks only · /mcp prune unused\n'

case "$model" in
  # Fable went metered on 2026-07-07 ($10/$50 per Mtok) and was 54% of July spend. Loudest warning.
  *fable*) printf '⚠ session on FABLE — metered credits on TOP of the subscription. Taste work only (UI, copy, API design). /model opus otherwise.\n' ;;
esac

exit 0
