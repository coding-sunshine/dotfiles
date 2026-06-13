---
description: Open a pull request for the current branch
argument-hint: [optional title]
allowed-tools: Bash(git:*), Bash(gh:*)
---

Open a pull request for the current branch:

1. Confirm the branch is pushed (`git push -u origin HEAD` if needed).
2. Review the commits (`git log main..HEAD --oneline`) and the diff to write an
   accurate title and body — summary of what changed and why, plus a short test
   plan. Use $ARGUMENTS as the title if provided.
3. Create the PR with `gh pr create` (do NOT target a protected branch without
   confirming the base).

Print the PR URL when done. Do not invent a "Closes #X" unless a real issue is
referenced.
