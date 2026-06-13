# <Project name>

One-line description of what this project is.

## Stack
- Language/framework + versions (e.g. Laravel 12 / PHP 8.4, or Next.js / TS, or Python 3.13 + uv)
- Datastore, queue, key services

## Commands
- Install: `<composer install / pnpm install / uv sync>`
- Run: `<herd / pnpm dev / uv run ...>`
- Test: `<herd php artisan test / pnpm test / uv run pytest>`
- Lint/format: `<vendor/bin/pint / pnpm lint / ruff check>`

## Conventions
- Where code lives, naming, architectural patterns to follow.
- Reuse these existing helpers/utilities: `<paths>`.

## Don't
- Files/areas not to touch; generated code; risky operations.
- Anything that needs a human (migrations on prod data, secrets, releases).

> Global instructions in ~/.claude/CLAUDE.md and ~/.claude/AGENTS.md still apply;
> this file adds project-specific context on top.
