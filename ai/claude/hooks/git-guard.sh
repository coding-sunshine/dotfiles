#!/usr/bin/env bash
# PreToolUse guard for Bash: block git commands CLAUDE.md alone can't reliably
# prevent (instructions ~70% followed; hooks 100%). Exit 2 = block, stderr
# shown to the model so it can adjust.
input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[[ -z "$cmd" ]] && exit 0
case "$cmd" in *git*) ;; *) exit 0 ;; esac

block() { echo "git-guard: $1" >&2; exit 2; }

# Repos allowed to bypass hooks via --no-verify (identified by origin remote,
# not local dir name, since local dirs can be cloned/renamed/typo'd).
NO_VERIFY_ALLOWED_REMOTES=(
  "OrganyzAI/sigmma"
)
cwd="$(printf '%s' "$input" | jq -r '.cwd // .workspace.current_dir // empty' 2>/dev/null)"
no_verify_allowed=0
if [[ -n "$cwd" ]]; then
  remote_url="$(git -C "$cwd" remote get-url origin 2>/dev/null)"
  for repo in "${NO_VERIFY_ALLOWED_REMOTES[@]}"; do
    [[ "$remote_url" == *"$repo"* ]] && no_verify_allowed=1 && break
  done
fi

# Any force-push variant (incl. --force-with-lease)
if echo "$cmd" | grep -qE 'git[^|;&]*push[^|;&]*(--force|-f([[:space:]]|$))'; then
  echo "$cmd" | grep -qE '(^|[^a-zA-Z-])(main|master)([^a-zA-Z-]|$)' && \
    block "force-push to main/master blocked. Ask the user."
  # Plain --force/-f (not with-lease) must name an explicit remote+branch
  if echo "$cmd" | grep -qE 'push[^|;&]*(--force([[:space:]]|$)|-f[[:space:]]|-f$)'; then
    echo "$cmd" | grep -qE 'push[^|;&]*(--force|-f)[[:space:]]+[^-[:space:]]' || \
      block "bare force-push blocked. Name remote + branch explicitly (never main/master), or use --force-with-lease."
  fi
fi

if [[ "$no_verify_allowed" -eq 0 ]]; then
  echo "$cmd" | grep -qE 'git[^|;&]*(commit|push)[^|;&]*--no-verify' && \
    block "--no-verify blocked. Fix what the hook rejects instead of skipping it."
fi

echo "$cmd" | grep -qE 'git[^|;&]*(reset[^|;&]*--hard|clean[^|;&]*-[a-z]*f)' && \
  block "history/file-destroying command (reset --hard / clean -f) blocked. Ask the user first."

exit 0
