#!/usr/bin/env bash
# Combined statusline: mode badges (caveman/ponytail) + dir(branch) + vibe-ads
# + ccusage (cost/burn/model). Claude Code passes session JSON on stdin;
# capture once, feed each child.
input="$(cat)"

# Plugin badge scripts live under version-hashed dirs — glob, don't pin.
caveman_sh=$(ls "$HOME"/.claude/plugins/cache/caveman/caveman/*/src/hooks/caveman-statusline.sh 2>/dev/null | head -1)
ponytail_sh=$(ls "$HOME"/.claude/plugins/cache/ponytail/ponytail/*/hooks/ponytail-statusline.sh 2>/dev/null | head -1)

badges="$([[ -n "$caveman_sh" ]] && printf '%s' "$input" | bash "$caveman_sh" 2>/dev/null)"
pt="$([[ -n "$ponytail_sh" ]] && printf '%s' "$input" | bash "$ponytail_sh" 2>/dev/null)"
[[ -n "$pt" ]] && badges="$badges$pt"

# Where am I: dir basename + git branch, '*' when tree dirty.
cwd="$(printf '%s' "$input" | jq -r '.workspace.current_dir // empty' 2>/dev/null)"
loc=""
if [[ -n "$cwd" ]]; then
  loc="$(basename "$cwd")"
  branch="$(git -C "$cwd" branch --show-current 2>/dev/null)"
  if [[ -n "$branch" ]]; then
    dirty=""
    [[ -n "$(git -C "$cwd" status --porcelain 2>/dev/null | head -1)" ]] && dirty="*"
    loc="$loc($branch$dirty)"
  fi
fi

ad="$(node "$HOME/.vibe-ads/vibe-ads-statusline.mjs" 2>/dev/null)"
usage="$(printf '%s' "$input" | bun x ccusage statusline --visual-burn-rate emoji-text --cost-source both --timezone Asia/Kolkata 2>/dev/null)"

# ccusage already shows the model; surface it ourselves only as a fallback.
model=""
if [[ -z "$usage" ]]; then
  model="$(printf '%s' "$input" | jq -r '.model.display_name // empty' 2>/dev/null)"
fi

out="" sep=""
for part in "$badges" "$model" "$loc" "$ad" "$usage"; do
  [[ -z "$part" ]] && continue
  out+="$sep$part"
  sep=" | "
done
printf '%s' "$out"
