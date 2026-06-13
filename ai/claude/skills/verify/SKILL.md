---
name: verify
description: Run the right lint, type-check, and tests for the current project before considering work done. Use after making code changes, when asked to "verify", "check it works", or before committing/opening a PR.
---

# verify

Detect the project's stack from the files present, then run its quality gates
and report results plainly. Do not claim success unless the commands actually
pass — paste failing output.

## Steps

1. **Detect the stack** (a repo may be more than one):
   - `composer.json` → PHP/Laravel
   - `package.json` → JS/TS
   - `pyproject.toml` / `uv.lock` → Python

2. **Run the gates for each detected stack** (skip any tool that isn't present):

   **PHP/Laravel**
   ```bash
   vendor/bin/pint --test          # format check
   herd php artisan test           # or: vendor/bin/pest --no-coverage
   ```

   **JS/TS**
   ```bash
   pnpm lint        # or: npm run lint
   pnpm typecheck   # or: npx tsc --noEmit
   pnpm test        # if a test script exists
   ```

   **Python**
   ```bash
   ruff check .
   ruff format --check .
   uv run pytest -q   # if tests exist
   ```

3. **Report**: list each command, whether it passed, and the failing output if
   not. End with a one-line verdict (all green / what to fix).

## Notes
- Prefer project-local binaries (`vendor/bin`, `node_modules/.bin`) over global.
- If no test/lint setup exists, say so rather than inventing commands.
