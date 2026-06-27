#!/usr/bin/env bash
# UserPromptSubmit hook — nudge tool/skill selection on a few unambiguous prompt
# patterns, so the right capability gets used without the user remembering it.
#
# Costs ~0 standing context (runs as a shell, injects at most ONE short line, and
# only when a pattern clearly matches — silent otherwise). The map is kept small
# and high-precision on purpose: a noisy/wrong hint is worse than none. The full
# routing table lives in AGENTS.md; this is just a deterministic backstop.
#
# Disable: remove the UserPromptSubmit block from settings.json.
set -eu

input="$(cat)"
prompt="$(printf '%s' "$input" | jq -r '.prompt // empty' 2>/dev/null || true)"
[ -n "$prompt" ] || prompt="$input"
p="$(printf '%s' "$prompt" | tr '[:upper:]' '[:lower:]')"

hint=""
case "$p" in
  *refactor*|*rename*|*"find all"*|*"every occurrence"*|*codemod*)
    hint="structural / multi-file change → use the ast-grep skill (beats regex)" ;;
  *"how does"*|*"how is"*|*architecture*|*"where is"*|*"trace the"*|*unfamiliar*)
    hint="understanding a codebase → /graphify . then query it; code-review-graph for callers/impact" ;;
  *"best practice"*|*"which library"*|*"compare options"*|*"latest version"*)
    hint="cross-source research → /deep-research" ;;
  *"build the app"*|*"from this feature list"*|*"build it unattended"*|*"overnight"*)
    hint="unattended build from a feature list → autobuild features.md" ;;
esac

[ -n "$hint" ] && printf '↳ tool hint: %s\n' "$hint"
exit 0
