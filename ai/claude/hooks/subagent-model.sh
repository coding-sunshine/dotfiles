#!/usr/bin/env bash
# PreToolUse(Task|Agent): hard-pin fan-out models. Instructions are ~70% followed; hooks are 100%.
# Types in KEEP run on whatever the main thread asked for. Everything else is forced down.
set -euo pipefail

KEEP='code-reviewer|feature-dev:code-reviewer|caveman:cavecrew-reviewer|planner|Plan|feature-dev:code-architect|debugger|claude'
HAIKU='Explore|caveman:cavecrew-investigator|statusline-setup'

input=$(cat)
type=$(jq -r '.tool_input.subagent_type // "general-purpose"' <<<"$input")

# fork inherits the parent model by design — overriding it is ignored, so skip.
if [[ "$type" == "fork" || "$type" =~ ^($KEEP)$ ]]; then
  exit 0
fi

if [[ "$type" =~ ^($HAIKU)$ ]]; then model=haiku; else model=sonnet; fi

printf '%s\t%s\t%s\n' "$(date -u +%FT%TZ)" "$type" "$model" >>"$HOME/.claude/subagent-model.log"

jq -c --arg m "$model" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "allow",
    updatedInput: (.tool_input + {model: $m})
  }
}' <<<"$input"
