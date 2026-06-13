# Ralph — autonomous build loop

Ralph runs Claude Code in a loop until a backlog of stories is done. Each
iteration is a fresh `claude -p` (clean context); state persists on disk via
`prd.json`, `progress.txt`, and git history — so context never degrades across
iterations.

## Use

1. From a project, drop the template in: `ralph-init` (copies this dir to `.ralph/`).
2. Create and edit the backlog: `cp .ralph/prd.example.json .ralph/prd.json` —
   list small, independently-verifiable stories, each `"passes": false`.
3. **Work on a throwaway branch/worktree**: `gwt new ralph/<name>`.
4. Run: `./.ralph/ralph.sh [max_iterations]`.

## Safety ("don't make Claude angry")

- Unattended runs should use **API billing** (`ANTHROPIC_API_KEY`) so they draw
  from the Agent-SDK/API budget instead of burning the interactive subscription's
  session/weekly caps. Each iteration is capped with `--max-budget-usd` (default
  `$5`; override via `CLAUDE_MAX_USD`).
- Always run in a sandbox/worktree and review the diff before merging.
- The flags here are a starting point — confirm them against `claude -p --help`
  for your CLI version. For sanctioned unattended automation, prefer Anthropic's
  **Claude Code Routines**; the community `ralph-loop-setup` plugin is a
  maintained alternative to this hand-rolled loop.
