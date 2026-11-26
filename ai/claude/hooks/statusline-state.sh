#!/usr/bin/env bash
# Status line segment: what this session is doing, then context and limit use.
# Reads the status line JSON on stdin and the state file session-state.sh writes.
# Needs "refreshInterval" on the statusLine setting so the clock keeps moving
# while the main thread sits idle behind background work.
input="$(cat)"
dir="${CLAUDE_STATE_DIR:-$HOME/.claude/session-state}"
sid="$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null)"
st="$(cat "$dir/$sid.json" 2>/dev/null)"
[ -n "$st" ] || st='{}'
IFS=$'\t' read -r state text meters < <(jq -r --argjson now "$(date +%s)" --argjson st "$st" '
  def mins(t): (($now - t) / 60 | floor) as $m | if $m < 60 then "\($m)m" else "\($m / 60 | floor)h\($m % 60)m" end;
  def pct(x): if x == null then empty else "\(x | floor)%" end;
  [ ($st.state // "none"),
    (if $st.state == "working" then "working " + mins($st.since)
     elif $st.state == "background" then ($st.tasks | group_by(.type) | map("\(length) \(.[0].type)") | join(", ")) + " running " + mins($st.at)
     elif $st.state == "scheduled" then "\($st.crons) wakeup scheduled"
     elif $st.state == "needs-you" then "needs you"
     elif $st.state == "done" then "done " + ($st.at | strflocaltime("%H:%M")) + (if ($st.servers // 0) > 0 then ", \($st.servers) server up" else ", nothing running" end)
     else "" end),
    ([ ("ctx " + pct(.context_window.used_percentage)),
       ("5h " + pct(.rate_limits.five_hour.used_percentage)),
       ("7d " + pct(.rate_limits.seven_day.used_percentage)),
       (.effort.level // empty) ] | join(" "))
  ] | @tsv' <<<"$input" 2>/dev/null)
case "$state" in
  working) c=36 g="▶" ;;    # cyan
  background) c=33 g="◐" ;; # yellow
  scheduled) c=33 g="◷" ;;
  needs-you) c=31 g="■" ;; # red
  done) c=32 g="●" ;;      # green
  *) c=0 g="" ;;
esac
[ -n "$text" ] && printf '\033[%sm%s %s\033[0m' "$c" "$g" "$text"
[ -n "$text" ] && [ -n "$meters" ] && printf ' | '
printf '%s' "$meters"
