#!/usr/bin/env sh
#
# Stop hook: run one check when the turn left uncommitted changes, and hand a
# failure back to the model (exit 2) before the answer reaches you.
#
#   check-on-stop.sh [--files] <command> [args...]
#
# --files appends the changed files to the command, for a linter that takes
# paths (biome). Without it the command runs as given (a workspace lint).
# CHECK_GLOBS picks the files that count as a change; default: TS and JS.
#
# Two skips, copied from starter's verify-on-stop.sh: nothing changed, and the
# second stop in a row, so a failure the model cannot fix never loops.
#
# The status hook (session-state.sh) holds its "done" banner in a project that runs
# this check, because only this script knows whether the stop goes through. `report`
# tells it: the Stop event again, marked checked, on a pass; StopBlocked on a failure.
# With no status hook or no jq, nothing is sent.

input="$(cat 2>/dev/null)"
printf '%s' "$input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0

state_hook="${CLAUDE_STATE_HOOK:-$HOME/.claude/hooks/session-state.sh}"
report() {
    [ -f "$state_hook" ] && command -v jq >/dev/null 2>&1 || return 0
    printf '%s' "$input" | jq -c "$1" 2>/dev/null | bash "$state_hook" >/dev/null 2>&1
}
pass() {
    report '. + {checked: true}'
    exit 0
}

cd "${CLAUDE_PROJECT_DIR:-.}" || pass

files=0
[ "${1:-}" = "--files" ] && { files=1; shift; }
[ $# -gt 0 ] || pass

set -f
globs="${CHECK_GLOBS:-*.ts *.tsx *.js *.jsx *.mts *.cts}"
# shellcheck disable=SC2086
changed="$({
    git diff --name-only --relative --diff-filter=d HEAD -- $globs
    git ls-files --others --exclude-standard -- $globs
} 2>/dev/null | sort -u)"
set +f
[ -n "$changed" ] || pass

# The check gets 50 seconds, inside the hook's own 60. A check that runs out of time or
# cannot be started lets the stop through and says so: a broken check must not hold the
# session, and Claude should not try to repair your tooling.
# The check runs in its own process group, and the whole group is ended at the deadline:
# a package runner's child would otherwise keep the output pipe open and the hook waiting.
limit="${CHECK_SECONDS:-50}"
run() {
    if command -v perl >/dev/null 2>&1; then
        perl -e '
            my $limit = shift;
            my $pid = fork;
            exit 127 unless defined $pid;
            if (!$pid) { setpgrp(0, 0); exec @ARGV or exit 127; }
            setpgrp($pid, $pid);
            $SIG{ALRM} = sub { kill "TERM", -$pid; exit 142 };
            alarm $limit;
            waitpid $pid, 0;
            exit($? & 127 ? 128 + ($? & 127) : $? >> 8);
        ' "$limit" "$@"
    else
        "$@"
    fi
}
if [ "$files" = 1 ]; then
    out="$(printf '%s\n' "$changed" | tr '\n' '\0' | run xargs -0 "$@" 2>&1)"
else
    out="$(run "$@" 2>&1)"
fi
rc=$?
[ "$rc" = 0 ] && pass
case "$rc" in
126 | 127) why="could not be started (exit $rc)" ;;
142) why="ran longer than $limit seconds" ;;
*) why="" ;;
esac
if [ -n "$why" ]; then
    command -v jq >/dev/null 2>&1 && jq -cn --arg m "check-on-stop: \`$*\` $why. The stop was allowed without it." '{systemMessage: $m}'
    pass
fi

{
    echo "Check failed before stopping: $*. Fix it, then finish."
    printf '%s\n' "$out" | tail -n 40
} >&2
report '{session_id, cwd, hook_event_name: "StopBlocked"}'
exit 2
