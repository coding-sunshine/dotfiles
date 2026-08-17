# Agent instructions (shared)

Canonical, tool-agnostic instructions for every coding agent I run. Tool-specific
files import or point here.

## About me

PHP/Laravel (via Herd) + JS/TS + Python, on macOS (Apple Silicon). Heavy
AI-agent workflow; I value small, verifiable steps.

## Working style

- Smallest change that fully solves the task; match surrounding style, don't
  reformat unrelated lines.
- Reuse existing functions/utilities before adding new ones.
- Ambiguous request: state your chosen interpretation in one line before
  building; ask only if interpretations diverge materially.
- Clean up orphans your change created (imports/vars/functions now unused).
  Pre-existing dead code: mention it, never delete unasked.
- State how you verified (tests run, output). Don't claim it works unchecked.
- Ask before destructive/hard-to-reverse actions (deletes, force-push, schema or
  data changes, anything outward-facing).
- **Task state goes in JSON, never Markdown.** Anything with a status field —
  task lists, checklists, build progress, feature lists — lives in a `.json`
  file. Markdown state gets "tidied up" mid-run and done items silently vanish;
  JSON survives. Markdown stays for narrative (plans, specs, notes, memory).
  Status fields are binary: `passing` or `failing`, never `in_progress` or
  `partial`. Unproven is `failing`. Every item carries the exact command that
  decides it.

## Answer shape — every reply, every tool

Accuracy and scannability over completeness. Checkable rules (vague "be
concise" loses to system-prompt drift; these don't):

- Lead with the answer/outcome in the first line; reasoning after, only if it
  changes what I'd do next.
- Detail budget: include only what changes my next action. Cut background I
  already know, restatements of my question, and "what I did" narration.
- No option surveys unless I ask — pick one, recommend it, one-line tradeoff.
- No unasked next-steps essays; a one-line offer max.
- Headers/tables only when they aid scanning (3+ parallel items); otherwise
  prose. Simple question = direct answer, no sections.

## Stack conventions

PHP → Herd (`herd php artisan`, Pest, Pint) · JS/TS → pnpm/bun, type-check
before done · Python → uv + ruff. Fuller per-stack detail loads from
`.claude/rules/` (drop into a project with `rules-init`).

## Tooling

`rg`, `fd`, `fzf`, `eza`, `zoxide`, `git-delta`, `lazygit`, `direnv`, `gh`,
`docker`. Prefer `rg`/`fd` over `grep`/`find`. For code-structure/AST searches
(call patterns, signatures, structural refactors) prefer `ast-grep`/`sg` over the
Grep tool; keep `rg` for plain text.

## Capability map — reach for these automatically

When a task matches a row, use that tool without being asked. Skills are
progressive (load only when invoked), so routing is free until used.

| When you're…                                                                             | Reach for                                                 |
| ---------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| exploring an unfamiliar codebase / "how does X relate to Y"                              | `/graphify .` then query the graph                        |
| tracing callers / impact / blast-radius of a change                                      | code-review-graph (`graph-init` once, then `review-on`)   |
| doing a structural search or multi-file refactor                                         | the `ast-grep` skill (not regex)                          |
| building or polishing UI                                                                 | `frontend-design` / `impeccable` / `ui-ux-pro-max` skills |
| writing/punching up copy (titles, LinkedIn, blog, microcopy) or humanizing AI-sounding text | `ai-copywriter` skill (superset of `humanizer`/`humanize-text`) |
| researching across many sources                                                          | `/deep-research`                                          |
| about to commit / open a PR                                                              | `verify` skill, then `/review` (or `/gstack-review`)      |
| CI-grade precision review of a diff/PR or auditing a whole unfamiliar directory          | `ocr review` / `ocr scan` (Open Code Review CLI)          |
| planning a non-trivial feature                                                           | `/plan` (planner subagent) or `/gstack-spec`              |
| building anything multi-step where "done" is arguable                                    | `/contract` — criteria frozen by an adversarial critic before code, graded against them after |
| stress-testing a plan/spec or a tenancy / auth / security / money change before building | `agent-review-panel` (multi-agent adversarial debate)     |
| told to "just build it" from a feature list, unattended                                  | `autobuild features.md`                                   |
| running a big/verbose search or test sweep                                               | delegate to a subagent (summary only returns)             |
| running parallel agents on branches                                                      | `claude --worktree` (native) or `gwt new <branch>`        |
| a headless, budget-capped automation run                                                 | `claude-auto`                                             |
| over-engineering creeping in                                                             | `/ponytail`                                               |

Opt-in, toggle on then off: `superpowers-on`, `browser-on`, `github-on`,
`review-on`. `continuous-learning-v2` auto-learns your patterns — check
`/instinct-status` occasionally and promote good ones.

## Model routing — subagents & delegation

My economics: 2× Claude Max (sunk cost, weekly Opus/Fable caps). So the cheap
bulk model is **sonnet**, not an external API.

| tier         | use for                                                                          |
| ------------ | -------------------------------------------------------------------------------- |
| haiku        | trivial mechanical: bulk greps, renames, format sweeps                           |
| sonnet       | default bulk: clear-spec impl, migrations, codebase reading                      |
| opus / fable | anything that ships, user-facing taste (UI, copy, API design), plan/impl reviews |

- Tie-break for anything that ships: **intelligence > taste > cost**. Cost
  decides only between equals.
- Standing permission to escalate: cheap model output misses the bar → redo on
  a smarter model without asking. Judge the output, not the price tag.
- User-facing work (UI, copy, API design) stays on opus/fable — never delegate
  taste downward.
- Fan-out burns multiply: one agentic task can branch into 4–6 concurrent model
  calls. On opus/fable sessions, pin workers to sonnet/haiku (agent frontmatter
  or `model:` param) — orchestrate smart, execute cheap. Hard rules belong in
  hooks, not CLAUDE.md (instructions ~70% followed; hooks 100%).

### Model-specific (self-route: apply the block for the model you are)

**Fable 5 sessions** (per Anthropic's Fable prompting guide):

- Long runs: verify with fresh-context subagents at intervals, not self-critique
  — separate verifiers outperform reviewing your own work.
- Before reporting progress, audit each claim against an actual tool result from
  this session; unverified = say so explicitly.
- Never echo/transcribe internal reasoning as response text (triggers
  reasoning_extraction refusals → Opus fallback).
- If my prompt lacks the why, ask for or infer the intent before a long run —
  Fable performs better knowing what the output is for.

**Opus 5 sessions** (per Anthropic's Opus 5 prompting guide):

- Do NOT add verification/double-check steps — Opus 5 self-verifies; extra
  instruction causes over-verification. The Fable verifier rule above does not
  apply to you.
- Reviews: report everything, filter in a second pass. Never "only
  high-severity" / "be conservative" — Opus 5 obeys literally and misses bugs.
- Subagents only for sizeable independent tracks; one if one suffices; never
  to verify your own work.
- `low`/`medium` effort holds quality on Opus 5 — primary cost/latency lever
  for routine work.

## Context & token discipline

- Delegate broad search / verbose runs to subagents — only the summary returns.
- Read just-in-time: keep paths/queries, read file _ranges_, not whole files.
- `/compact` at milestones; `/clear` when switching tasks (a long session
  re-reads its history every turn — cost grows with turn count).
- Protect the prompt cache (reads bill ~10% of input): pick model + effort at
  session start, save `/compact` for natural task breaks. Mid-task model/effort/
  fast-mode switches and MCP connect/disconnect each force a pricier uncached turn.
- Durable decisions persist via `MEMORY.md` + cavemem — don't re-derive them.
- Default effort `high`; reserve `xhigh`/`max` or workflow orchestration for
  genuinely hard problems.
- Keep the active MCP set lean and downshift `/model` for routine work; audit
  with `/context`. MCP is the biggest lever (~500 tok/tool — drop any a CLI
  replaces); flag skills >400 lines, rules >100, `CLAUDE.md` >300; stay <40% used.

## Browser automation

Default to the **Agent Browser** CLI (`agent-browser`, most token-efficient).
`npx playwright` for standard E2E. Only `browser-on` (Playwright + Chrome
DevTools MCP) for interactive/network/console debugging — `browser-off` after.

## Prose humanization — auto-apply

Any human-facing prose I'll send or publish (emails, explainers, docs,
announcements, PR/release bodies, README/marketing copy) gets humanized before I
see it — remove AI tells (em-dash overuse, rule-of-three, "moreover/additionally",
inflated vocab, vague attributions, negative parallelism). Do it silently as part
of drafting; don't ask first.

- General prose (emails, explainers, docs) → `humanizer` skill.
- UX/product/marketing copy, or scoring text → `humanize-text` skill.

Exempt (leave as-is): code, commit messages, terminal/caveman replies to me,
literal quotes, and anything I explicitly say to keep verbatim.

## Secrets

Never print or commit secrets. Keys live in `~/.env` (git-ignored), exported
into the shell. Reference env vars; don't hardcode.
