#!/usr/bin/env bash
# Combined statusline: mode badges (caveman/ponytail) + vibe-ads + ccusage.
# Claude Code passes session JSON on stdin; capture once, feed each child.
input="$(cat)"

# Plugin badge scripts live under version-hashed dirs — glob, don't pin.
caveman_sh=$(ls "$HOME"/.claude/plugins/cache/caveman/caveman/*/src/hooks/caveman-statusline.sh 2>/dev/null | head -1)
ponytail_sh=$(ls "$HOME"/.claude/plugins/cache/ponytail/ponytail/*/hooks/ponytail-statusline.sh 2>/dev/null | head -1)

badges="$([[ -n "$caveman_sh" ]] && printf '%s' "$input" | bash "$caveman_sh" 2>/dev/null)"
pt="$([[ -n "$ponytail_sh" ]] && printf '%s' "$input" | bash "$ponytail_sh" 2>/dev/null)"
[[ -n "$pt" ]] && badges="$badges$pt"
ad="$(node "$HOME/.vibe-ads/vibe-ads-statusline.mjs" 2>/dev/null)"
usage="$(printf '%s' "$input" | bun x ccusage statusline --visual-burn-rate emoji-text --cost-source both --timezone Asia/Kolkata 2>/dev/null)"

out="" sep=""
for part in "$badges" "$ad" "$usage"; do
  [[ -z "$part" ]] && continue
  out+="$sep$part"
  sep=" | "
done
printf '%s' "$out"
