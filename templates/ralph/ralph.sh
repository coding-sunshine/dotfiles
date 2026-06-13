#!/bin/sh

# Ralph: an autonomous build loop. Each iteration starts a FRESH `claude -p`
# (clean context) that reads prd.json, implements the top incomplete story with
# TDD, runs the gate, commits, marks the story done, and logs progress.
# Memory persists on disk (git history + prd.json + progress.txt), never in
# context — so the loop doesn't degrade as it runs.
#
# SAFETY: this runs unattended. Work on a throwaway branch/worktree. Runs are
# budget-capped per iteration so a runaway agent can't rack up cost.
#
# Usage:  ./.ralph/ralph.sh [max_iterations]   (default 25)
# Env:    CLAUDE_MAX_USD  per-iteration USD cap (default 5)
#         RALPH_MODEL     model override (default: Claude Code default)
#
# Flags below are a starting point — confirm against `claude -p --help` for your
# CLI version. Anthropic's official sanctioned primitive is Claude Code Routines.

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
MAX_ITER="${1:-25}"
BUDGET="${CLAUDE_MAX_USD:-5}"
PRD="$DIR/prd.json"
PROMPT="$DIR/CLAUDE.md"
PROGRESS="$DIR/progress.txt"

command -v claude >/dev/null 2>&1 || { echo "claude CLI not found" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq required" >&2; exit 1; }
[ -f "$PRD" ] || { echo "missing $PRD — copy prd.example.json to prd.json first" >&2; exit 1; }

model_flag=""
[ -n "$RALPH_MODEL" ] && model_flag="--model $RALPH_MODEL"

i=0
while [ "$i" -lt "$MAX_ITER" ]; do
  remaining="$(jq '[.stories[] | select(.passes != true)] | length' "$PRD")"
  if [ "$remaining" -eq 0 ]; then
    echo "✅ All stories pass. Done in $i iterations."
    exit 0
  fi

  i=$(( i + 1 ))
  echo "── Ralph iteration $i/$MAX_ITER ($remaining stories left) ──"

  # Fresh agent, clean context, scoped tools, hard budget cap.
  claude -p "$(cat "$PROMPT")" \
    $model_flag \
    --max-budget-usd "$BUDGET" \
    --allowedTools "Read,Edit,Write,Grep,Glob,Bash" \
    --permission-mode acceptEdits \
    2>&1 | tee -a "$PROGRESS"
  echo "── end iteration $i ──" >> "$PROGRESS"
done

open="$(jq '[.stories[] | select(.passes != true)] | length' "$PRD")"
echo "⏹  Hit max iterations ($MAX_ITER). $open stories still open."
