#!/usr/bin/env bash
# One small JSON file per session that says what the session is doing right now.
# Wire to UserPromptSubmit, PostToolBatch, Notification, Stop and SessionEnd.
# The Stop event lists background work still in flight, so "done" and "paused,
# waiting on background work" are told apart without asking Claude.
# `session-state.sh board` prints every live session; add -w to keep it on screen.
# Silent no-op on any failure; never blocks a turn.
dir="${CLAUDE_STATE_DIR:-$HOME/.claude/session-state}"
command -v jq >/dev/null 2>&1 || exit 0
summ='def summ: group_by(.type) | map("\(length) \(.[0].type)") | join(", ");'
# ponytail: a background shell command that matches this pattern is a dev server or a
# log tail that never finishes, so it must not hold a session at "background" forever.
# Naive name match; set CLAUDE_STATE_SERVICES to your own pattern if it guesses wrong.
services="${CLAUDE_STATE_SERVICES:-((npm|pnpm|yarn|bun)( run)? (dev|start|serve|watch)|composer( run)? dev|vite( |$)(?!build)|next dev|nuxt dev|php -S|artisan (serve|pail|horizon|queue:(work|listen)|reverb:start)|tail -f|docker compose up|uvicorn|flask run|--watch)}"

if [ "${1:-}" = "board" ]; then
  while :; do
    [ "${2:-}" = "-w" ] && clear
    now="$(date +%s)"
    cat "$dir"/*.json 2>/dev/null | jq -rs --argjson now "$now" "$summ"'
      def age: (($now - .at) / 60 | floor) as $m | if $m < 60 then "\($m)m" else "\($m / 60 | floor)h\($m % 60)m" end;
      def rank: {"needs-you": 0, "done": 1, "background": 2, "scheduled": 3, "working": 4}[.state] // 5;
      map(select($now - .at < 86400)) | sort_by(rank, -.at)[]
      | [ ({"needs-you": "NEEDS YOU", "done": "DONE", "background": "BACKGROUND", "scheduled": "SCHEDULED", "working": "WORKING"}[.state] // .state),
          (.cwd // "?" | split("/") | last),
          (if .state == "background" then (.tasks | summ) + " still running"
           elif .state == "scheduled" then "\(.crons) wakeup scheduled"
           elif .state == "done" then (if (.servers // 0) > 0 then "\(.servers) server up" else "nothing running" end)
           else "" end),
          age ] | @tsv' | column -t -s "$(printf '\t')"
    [ "${2:-}" = "-w" ] || exit 0
    sleep 2
  done
fi

input="$(cat)"
# Three fields in one read: session, event, and whether a subagent sent it.
IFS=$'\t' read -r sid ev sub < <(jq -r '[.session_id // "", .hook_event_name // "", (.agent_id // "")] | @tsv' <<<"$input" 2>/dev/null)
[ -n "$sid" ] || exit 0
# A subagent's tool batches arrive under the parent session. The main thread is
# still idle then, so they must not flip the state back to "working".
[ -n "$sub" ] && exit 0
f="$dir/$sid.json"
if [ "$ev" = "SessionEnd" ]; then
  rm -f "$f"
  exit 0
fi
mkdir -p "$dir" 2>/dev/null || exit 0
old="$(cat "$f" 2>/dev/null)"
[ -n "$old" ] || old='{}'
now="$(date +%s)"

# `since` is the time of the last prompt a person typed. A finished background task
# also arrives as a prompt (<task-notification> or <agent-message>); that wakes the
# main thread but does not restart the clock or forget what was running.
# ponytail: a reply that ends in "?" counts as a question for you; naive, swap for a
# real signal if Claude Code ever exposes one.
new="$(jq -c --argjson now "$now" --argjson old "$old" --arg svc "$services" '
  . as $in | $in.hook_event_name as $ev
  | {session: $in.session_id, cwd: ($in.cwd // $old.cwd), at: $now, since: ($old.since // $now),
     state: ($old.state // "working"), tasks: ($old.tasks // []), servers: ($old.servers // 0),
     crons: ($old.crons // 0), told: $old.told}
  + (if $ev == "UserPromptSubmit" then
       (if ($in.prompt // "") | test("^\\s*<(task-notification|agent-message)") then {state: "working"}
        else {state: "working", since: $now, tasks: [], servers: 0, crons: 0, told: null} end)
     elif $ev == "PostToolBatch" or $ev == "StopBlocked" then {state: "working"}
     elif $ev == "Notification" then
       (if ($in.notification_type // "") | test("^(permission_prompt|elicitation_dialog|elicitation_url_dialog)$")
        then {state: "needs-you"} else {at: ($old.at // $now)} end)
     elif $ev == "Stop" then
       ([$in.background_tasks[]? | {type, what: ((.description // .command // .name // "") | .[0:60]),
           svc: (.type == "shell" and ((.command // "") | test($svc; "i")))}]) as $all
       | [$all[] | select(.svc | not) | del(.svc)] as $t
       | (($in.session_crons // []) | length) as $c
       | {tasks: $t, servers: (($all | length) - ($t | length)), crons: $c, turn: ($now - ($old.since // $now)),
          told: (if $in.stop_hook_active == true then null else $old.told end),
          state: (if ($t | length) > 0 then "background" elif $c > 0 then "scheduled"
                  elif ($in.last_assistant_message // "") | test("\\?\\s*$") then "needs-you" else "done" end)}
     else {at: ($old.at // $now)} end)' <<<"$input" 2>/dev/null)"
[ -n "$new" ] || exit 0

# A Stop hook can refuse the stop and send Claude back to work. Stop hooks run side by
# side, so the outcome is not known here. Two rules cover it:
# - any hook: the stop after a refused one carries stop_hook_active, and the jq above
#   forgets the earlier banner then, so the real end is announced too.
# - check-on-stop.sh: in a project whose settings run it, the banner waits. That script
#   sends the event again with "checked": true when its check passes, and StopBlocked
#   when it fails. A stop that follows a refused one skips the check, so it is not held.
held=""
if [ "$ev" = "Stop" ] && jq -e '.checked != true and .stop_hook_active != true' <<<"$input" >/dev/null 2>&1; then
  proj="${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd // ""' <<<"$input" 2>/dev/null)}"
  grep -qs 'check-on-stop\.sh' "$proj/.claude/settings.local.json" "$proj/.claude/settings.json" && held=1
fi

# Banner when a turn ends 90 seconds or more after your prompt, once per state:
# one "paused" when background work is left running, one "done" when all of it is in.
notify="${CLAUDE_NOTIFY:-$HOME/.claude/hooks/notify.sh}"
msg="$(jq -r "$summ"'select(.turn != null and .turn >= 90 and .state != .told)
  | if .state == "background" then "Paused: " + (.tasks | summ) + " still running"
    elif .state == "scheduled" then "Paused: \(.crons) wakeup scheduled"
    elif .state == "needs-you" then "Stopped with a question for you. Nothing running."
    elif (.servers // 0) > 0 then "Done. \(.servers) server still up."
    else "Done. Nothing running." end' <<<"$new" 2>/dev/null)"
if [ -n "$msg" ] && [ -z "$held" ]; then
  new="$(jq -c '.told = .state' <<<"$new")"
  [ -x "$notify" ] && jq -c --arg m "$msg" '{cwd, message: $m}' <<<"$new" | "$notify" >/dev/null 2>&1
fi
printf '%s\n' "$new" >"$f.$$.tmp" && mv "$f.$$.tmp" "$f"
exit 0
