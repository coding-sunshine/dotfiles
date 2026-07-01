#!/usr/bin/env bash
# Combined statusline: vibe-ads banner + ccusage cost/burn, joined by " | ".
ad="$(node "$HOME/.vibe-ads/vibe-ads-statusline.mjs" 2>/dev/null)"
usage="$(bun x ccusage statusline --visual-burn-rate emoji-text --cost-source both --timezone Asia/Kolkata 2>/dev/null)"

out="" sep=""
for part in "$ad" "$usage"; do
  [[ -z "$part" ]] && continue
  out+="$sep$part"
  sep=" | "
done
printf '%s' "$out"
