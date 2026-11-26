#!/usr/bin/env bash
# Status line segment: one dim habit reminder (audit cards R10 and R18).
#   R10  one session per ticket, with a handoff note
#   R18  /tasks, /goal and /handoff instead of typing the same thing by hand
# Contextual first: a full context, or a last prompt a built-in command covers.
# Otherwise one standing tip that changes every 15 minutes. HABIT_TIPS=0 turns it off.
[ "${HABIT_TIPS:-1}" = 0 ] && exit 0
input="$(cat)"
IFS=$'\t' read -r used tp < <(jq -r '[(.context_window.used_percentage // 0 | floor), (.transcript_path // "")] | @tsv' <<<"$input" 2>/dev/null)
tip=""
if [ "${used:-0}" -ge 60 ]; then
	tip="ctx ${used}%: /handoff, then /clear"
elif [ -n "$tp" ] && [ -f "$tp" ]; then
	# Last prompt you typed: a user line whose content is a plain string (tool results are arrays).
	last="$(tail -c 262144 "$tp" | jq -Rr 'fromjson? | select(.type == "user" and (.message.content | type) == "string") | .message.content | gsub("\\s+"; " ")' 2>/dev/null |
		tail -n 1 | tr '[:upper:]' '[:lower:]' | sed 's/^ *//' | cut -c1-200)"
	case "$last" in
	"are u done"* | "are you done"* | status* | "any update"* | "where are u"* | "where are you"* | "how much more"* | "why are u taking"* | "why are you taking"*)
		tip="next time: /tasks shows what is running" ;;
	continue* | "go on"* | "keep going"* | "please finish"* | "finish it"* | go | "go ahead"*)
		tip="next time: /goal <done when> keeps it going" ;;
	*"prompt for"*"session"* | *"handoff"*)
		tip="next time: /handoff <what the next session is for>" ;;
	esac
fi
if [ -z "$tip" ]; then
	case $(($(date +%s) / 900 % 3)) in
	0) tip="habit: one ticket per session; /handoff, then /clear" ;;
	1) tip="habit: /tasks instead of asking for status" ;;
	*) tip="habit: /goal <done when> instead of continue" ;;
	esac
fi
printf '\033[2m%s\033[0m' "$tip"
