#!/usr/bin/env bash
# SessionStart hook — cost discipline. Injects a one-line reminder every session
# and warns if the session model is Opus (burns the weekly Opus cap).
#
# Why only a reminder: Claude Code hooks CANNOT block or reliably detect
# mid-session model/effort/fast switches (internal/menu actions — no hook fires),
# and the active MCP-server list is not exposed to hooks. So the real levers are
# the settings defaults (sonnet / effort high / haiku background / subagent tiers)
# plus this front-of-mind nudge. Disable: remove the SessionStart block in settings.json.
set -eu

input="$(cat 2>/dev/null || true)"
model="$(printf '%s' "$input" | jq -r '(.model.id // .model) // empty' 2>/dev/null || true)"

printf '↳ cost discipline: haiku=trivial · sonnet=default · opus=hard only | no mid-session model/effort/fast switch (cache wipe) | /clear between tasks · /compact at breaks only · /mcp prune unused\n'

case "$model" in
  *opus*) printf '⚠ session on OPUS — burns the weekly Opus cap. Use /model sonnet for routine work.\n' ;;
esac

exit 0
