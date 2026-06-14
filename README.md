<p align="center"><img src="art/banner-2x.png"></p>

## Introduction

My personal dotfiles for setting up and maintaining a **macOS Tahoe (macOS 26)**
machine on Apple Silicon. One script takes a clean Mac and installs my tooling
for a **mixed PHP/Laravel + JS/TS + Python** stack, applies sensible macOS
defaults, and — importantly — wires up a first-class **AI agent layer** (Claude
Code, Codex, Cursor, Gemini CLI).

Originally forked from [driesvints/dotfiles](https://github.com/driesvints/dotfiles)
and adapted for an AI-agent-driven 2026 workflow.

### What you get

- **Homebrew** packages, casks, and Mac App Store apps from a single [`Brewfile`](./Brewfile)
- **Zsh + Oh My Zsh**, a [Starship](https://starship.rs) prompt, and `$PATH` setup
- **Terminal:** [Ghostty](https://ghostty.org) (fast, native Metal) with the JetBrains Mono Nerd Font
- Modern CLI tooling: `rg`, `fd`, `fzf`, `eza`, `zoxide`, `git-delta`, `lazygit`, `direnv`
- Zsh autosuggestions + syntax highlighting, and a global git config (delta diffs, sane defaults, SSH-signed commits)
- Per-language toolchains: Herd (PHP), `pnpm`/`bun` (JS/TS), `uv`/`ruff` (Python)
- GUI apps: Raycast (launcher), Sequel Ace + TablePlus (DB), Zed + Cursor (editors), and more
- An [AI agent layer](#ai-agent-layer): versioned configs for Claude Code, Codex,
  Gemini CLI, and shared MCP servers
- [Productivity workflows](#productivity-workflows): Laravel Boost, parallel agents
  via git worktrees, and auto-format hooks
- ~900 lines of opinionated [`.macos`](./.macos) system defaults

### Requirements

- A Mac running **macOS 26 (Tahoe)** on **Apple Silicon**
- An internet connection and your Apple ID signed in (for Mac App Store apps)

## A Fresh macOS Setup

These instructions set up a brand-new Mac. If you instead want to build your own
dotfiles from this repo, see [Customizing](#customizing) below.

### 1. Back up your old Mac (if migrating)

Before wiping or migrating, run through this checklist:

- Committed and pushed all your git branches?
- Saved important documents from non-iCloud directories?
- Exported any local databases you care about?
- Saved data from apps that don't sync to iCloud?
- Ran `mackup backup` on the latest [mackup](https://github.com/lra/mackup)?

### 2. Set up an SSH key

[Generate a key](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
with the helper script:

```zsh
curl https://raw.githubusercontent.com/coding-sunshine/dotfiles/HEAD/ssh.sh | sh -s "<your-email-address>"
```

Then add the key to your [GitHub account](https://github.com/settings/keys).

### 3. Clone and install

> 🛑 **Run as your normal user, not `root`.** If your prompt ends in `#` (e.g.
> `sh-3.2#`) you're root — type `exit` until it ends in `%`. Homebrew refuses to
> run as root, the CLT install dialog won't appear for root, and symlinks would
> land in `/var/root` instead of your home directory. Never run `fresh.sh` as root.

> ℹ️ **A brand-new Mac has no `git` yet.** The first `git` command triggers the
> **Xcode Command Line Tools** installer — click **Install** in the dialog (or run
> `xcode-select --install`) and wait for it to finish before continuing. The clone
> that triggered it does *not* run; re-issue it afterwards. Verify with
> `git --version`.

```zsh
git clone --recursive git@github.com:coding-sunshine/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./fresh.sh
```

> 🔑 The SSH clone above only works once your key from step 2 is added to GitHub.
> If you haven't done that yet (or want to skip SSH for the initial clone), use
> HTTPS instead:
>
> ```zsh
> git clone --recursive https://github.com/coding-sunshine/dotfiles.git ~/.dotfiles
> ```

#### Troubleshooting: the CLT installer dialog never appears

`xcode-select --install` prints `install requested...` but no GUI dialog shows
up (common over SSH, or if you were in a root shell). Two reliable fallbacks:

- **Headless install** — no dialog needed:
  ```zsh
  # Tell softwareupdate to expose the CLT package, then list and install it
  sudo touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  softwareupdate --list   # copy the exact "Command Line Tools for Xcode-XX.X" label
  sudo softwareupdate --install "Command Line Tools for Xcode-16.4" --verbose
  sudo rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  ```
- **Manual download** — if `softwareupdate` doesn't list it, grab the installer
  from <https://developer.apple.com/download/all/> (sign in with your Apple ID),
  search **"Command Line Tools"**, and run the `.dmg`.

If a previous attempt got wedged, clear it and retry:
`sudo rm -rf /Library/Developer/CommandLineTools && xcode-select --install`.
Confirm success with `git --version` before continuing.

`fresh.sh` is idempotent — safe to re-run. It will:

1. Install Xcode Command Line Tools, Oh My Zsh, and Homebrew
2. Symlink [`.zshrc`](./.zshrc) and [`.gitconfig`](./.gitconfig) into your home directory
3. Install everything in the [`Brewfile`](./Brewfile)
4. Create project directories (`~/Herd`, `~/Code/{Personal,Clients,Cogneiss}`)
5. Install the global Laravel installer (if Herd's `composer` is available)
6. Clone your repositories (edit [`clone.sh`](./clone.sh) first — it ships empty)
7. Symlink [`config/`](./config) into `~/.config` and set up the
   [AI agent layer](#ai-agent-layer) via [`ai.sh`](./ai.sh)
8. Symlink the Mackup config
9. Apply [`.macos`](./.macos) system defaults (this reloads the shell at the end)

### 4. Finish up

1. Start **Herd.app** and complete its install process (provides PHP/Node/DBs).
   Then install the global Laravel installer (Herd's `composer` is only on
   `$PATH` after Herd runs once):
   ```zsh
   composer global require laravel/installer   # so `laravel new` works
   ```
2. Copy the secrets template and fill in your keys:
   ```zsh
   cp ~/.dotfiles/.env.example ~/.env && $EDITOR ~/.env
   ```
3. Add your SSH **public** key to GitHub as both an *Authentication* and a
   *Signing* key (commits are SSH-signed by default — see `.gitconfig`):
   <https://github.com/settings/keys>
4. Restore app preferences once Mackup has synced from your cloud storage:
   ```zsh
   mackup restore
   ```
   > ⚠️ **Mackup is largely unmaintained** and has broken with newer macOS app
   > sandboxing — some apps no longer restore cleanly. If it misbehaves, skip it
   > and configure those apps by hand, or move their settings into this repo and
   > symlink them like the `config/` files. (Alternatives: [chezmoi](https://chezmoi.io)
   > or plain symlinks.)
5. Restart your Mac to finalize everything.

### 5. Verify

```zsh
brew bundle check --file ~/.dotfiles/Brewfile   # all packages installed?
ls -l ~/.claude ~/.codex ~/.gemini              # agent configs symlinked?
claude mcp list                                 # MCP servers registered?
git config --get commit.gpgsign                 # "true" -> SSH signing on
echo $ANTHROPIC_API_KEY                          # ~/.env loaded? (non-empty)
```

> 💡 Set your terminal/editor font to **"JetBrainsMono Nerd Font"** (Ghostty is
> preconfigured) so the Starship prompt icons render instead of as empty boxes.

Your Mac is now ready to use! 🎉

> 💡 You can clone to a location other than `~/.dotfiles`, but several scripts
> assume that path. If you change it, update [`.zshrc`](./.zshrc) (`$DOTFILES`)
> and the `~/.dotfiles` references in [`fresh.sh`](./fresh.sh) and [`ai.sh`](./ai.sh).

## AI Agent Layer

The [`ai/`](./ai) directory is the single source of truth for every coding agent
I run. [`ai.sh`](./ai.sh) (invoked by `fresh.sh`, also runnable standalone)
symlinks each config into place and registers shared MCP servers. It is
idempotent — re-run it any time you change a config.

| File | Symlinked to | Purpose |
| --- | --- | --- |
| [`ai/AGENTS.md`](./ai/AGENTS.md) | `~/.claude/AGENTS.md`, `~/.codex/AGENTS.md`, `~/.gemini/AGENTS.md` | Shared, tool-agnostic instructions |
| [`ai/claude/CLAUDE.md`](./ai/claude/CLAUDE.md) | `~/.claude/CLAUDE.md` | Global Claude Code instructions (imports `AGENTS.md`) |
| [`ai/claude/settings.json`](./ai/claude/settings.json) | `~/.claude/settings.json` | Model (Sonnet default) / permissions / hooks / statusline / auto memory |
| [`ai/claude/statusline.sh`](./ai/claude/statusline.sh) | `~/.claude/statusline.sh` | Statusline: model · branch · context-usage bar · session cost |
| [`ai/claude/agents/`](./ai/claude/agents) | `~/.claude/agents` | Subagents: `code-reviewer` & `planner` (Opus), `test-writer` & `debugger` (Sonnet) |
| [`ai/claude/commands/`](./ai/claude/commands) | `~/.claude/commands` | Slash commands: `/review`, `/pr`, `/spec`, `/test`, `/plan`, `/ship` |
| [`ai/claude/skills/`](./ai/claude/skills) | `~/.claude/skills/*` (per-skill) | Skills: `verify` (ours) + installed: `agent-browser`, `frontend-design`, `web-design-guidelines`, `gstack` (`/gstack-*`) |
| [`ai/codex/config.toml`](./ai/codex/config.toml) | `~/.codex/config.toml` | Codex CLI config |
| [`ai/gemini/settings.json`](./ai/gemini/settings.json) | `~/.gemini/settings.json` | Gemini CLI config |
| [`ai/mcp/mcp.json`](./ai/mcp/mcp.json) | registered via `claude mcp add-json` | MCP servers: **always-on** filesystem, context7; **opt-in** github, playwright, chrome-devtools, composio |

To update: edit a file under `ai/`, then run `./ai.sh`. Skills are symlinked
per-item so externally-installed skills coexist without polluting the repo.

> **Model routing.** The interactive default is **Sonnet 4.6** (fast and cheap
> for day-to-day work); the `planner` and `code-reviewer` subagents run on
> **Opus** where the extra reasoning pays off. Use `/model` to downshift to Haiku
> for trivial work or up to Opus for hard problems.

### Secrets

API keys live in `~/.env` (git-ignored), which [`.zshrc`](./.zshrc) sources
automatically on shell start. Start from [`.env.example`](./.env.example).
Nothing secret is ever committed.

## Productivity workflows

### Laravel Boost (real project context for agents)

[Laravel Boost](https://laravel.com/ai/boost) gives AI agents 15 MCP tools to
*see* your actual app (logs, queries, config, routes) instead of guessing, and
it auto-installs the [Herd MCP server](https://herd.laravel.com/docs/macos/advanced-usage/ai-integrations).
Run once per Laravel project:

```zsh
boost   # alias: composer require laravel/boost --dev && herd php artisan boost:install
```

### Parallel agents with git worktrees

Worktrees let several agents work on different branches at once, each in its own
directory sharing one `.git`. The [`gwt`](./bin/gwt) helper makes this a one-liner:

```zsh
gwt new feature-x      # create ../<repo>.worktrees/feature-x on a new branch
gwtcd feature-x        # jump into it
gwt ls                 # list worktrees
gwt rm feature-x       # remove when merged
```

> ⚠️ Practical ceiling is ~5–7 agents (rate limits + disk; each worktree is a
> full checkout). Worktrees isolate files but **share ports/DBs/services** — give
> each running app its own port and database.

### Subagents, commands & skills

The agent layer ships reusable Claude Code building blocks (all symlinked into
`~/.claude` by `ai.sh`):

- **Subagents** ([`ai/claude/agents/`](./ai/claude/agents)) — `code-reviewer`
  and `planner` (Opus), `test-writer` and `debugger` (Sonnet), each with its own
  isolated context window (verbose work stays out of the main thread).
- **Slash commands** ([`ai/claude/commands/`](./ai/claude/commands)) — `/review`,
  `/pr`, `/spec`, `/test`, plus `/plan` (delegates to `planner`) and `/ship`
  (full gate: verify → review → **security-review** → commit).
- **Skills** — [`verify`](./ai/claude/skills/verify/SKILL.md) runs stack-aware
  lint/test/type-check gates. `ai.sh` also installs (via `npx skills`)
  `agent-browser` (token-lean browser CLI), Anthropic's `frontend-design`, and
  Vercel's `web-design-guidelines`.
- **gstack** ([garrytan/gstack](https://github.com/garrytan/gstack)) — Garry Tan's
  23-command framework (CEO/eng/design/QA/release review gates), installed
  **prefixed** as `/gstack-*` so it coexists with the commands above. Update with
  `gstack-upgrade`.
- **Auto-format hook** — [`format.sh`](./ai/claude/hooks/format.sh) formats every
  file an agent edits (Pint/Ruff/Prettier) via a PostToolUse hook.
- **Project context** — `claude-init` drops a [`CLAUDE.md` template](./templates/CLAUDE.md)
  into any repo; `rules-init` drops path-scoped [`.claude/rules/`](./templates/claude-rules)
  (TypeScript/PHP/Python/tests) that load only when matching files are touched.

### Memory & context management

Most of this is native to Claude Code — the layer here just turns it on, makes
it visible, and adds one lightweight persistent store:

- **Auto memory** is enabled in [`settings.json`](./ai/claude/settings.json)
  (`autoMemoryEnabled`). Claude writes its own learnings to
  `~/.claude/projects/<repo>/memory/MEMORY.md` (only ~200 lines load per session);
  browse/edit with `/memory`.
- **Statusline** ([`statusline.sh`](./ai/claude/statusline.sh)) shows a live
  context-usage bar + session cost so you see compaction coming. Pair with
  `/context` and `/cost`.
- **Path-scoped rules** (`rules-init`) keep heavy instructions out of context
  until a matching file is opened.
- **cavemem** (installed by `fresh.sh`, wired by `ai.sh`) is a local, compressed
  persistent-memory MCP (SQLite + FTS5 + local vector search — no keys, no
  network) that *survives `/compact`* and gives cross-session recall. View it
  with `memview` (`cavemem viewer`).
- **Token discipline** lives in [`AGENTS.md`](./ai/AGENTS.md): delegate fan-out to
  subagents, read file ranges not whole files, keep the MCP set lean (`/mcp`),
  and downshift the model for routine work.
- *Opt-in:* `caveman-on` installs the [caveman](https://github.com/JuliusBrussee/caveman)
  skill, which compresses Claude's **output** (~65%, reasoning and code preserved);
  it changes output style, so toggle per session with `/caveman`.

### Autonomous & spec-driven delivery

Two paths for building whole features/apps:

- **Supervised** — [GitHub Spec Kit](https://github.com/github/spec-kit) (`spec`
  → `specify init`, then `/speckit.*`) to spec first, plan mode + `/plan` to
  design, then `/ship` to gate and commit.
- **Autonomous** — the [Ralph loop](./templates/ralph) (`ralph-init`) runs a
  fresh `claude -p` per iteration against a `prd.json` backlog (TDD → commit →
  repeat), and [`claude-auto`](./bin/claude-auto) (`cauto`) is a headless,
  budget-capped runner.

> **Safe automation ("don't make Claude angry").** Run unattended loops on a
> throwaway worktree, route them to **API billing** (`ANTHROPIC_API_KEY`) so they
> draw from the Agent-SDK/API budget instead of the interactive subscription
> caps, and keep the `--max-budget-usd` / `--max-turns` caps. For sanctioned
> unattended work, prefer Anthropic's **Claude Code Routines** (pushes only to
> `claude/*` branches).

### Browser automation

Ranked by token cost (browser tools are expensive, so the default is the lean one):

- **Default — [Agent Browser](https://github.com/vercel-labs/agent-browser)**: a
  CLI (~1,400 tokens/snapshot, ~93% less than Playwright MCP). Installed as a thin
  skill by `ai.sh`; run `npx agent-browser install` once to fetch Chrome.
- **E2E tests — Playwright CLI** (`npx playwright`): no MCP tool-def tax; use it to
  author/run standard test suites.
- **Opt-in — Playwright MCP + Chrome DevTools MCP**: `browser-on` registers both
  (interactive control + network/console/perf debugging); `browser-off` after.
  Playwright MCP alone adds ~13.7k tokens at startup, hence opt-in.

### Token budget

Session base overhead is ~20–30k tokens before you type (system prompt + CLAUDE.md
every turn + MCP schemas every turn + skill frontmatter). This setup keeps it lean:

- **Always-on by design:** `filesystem` + `context7` MCP, a short
  `CLAUDE.md`→`AGENTS.md`, skill frontmatter (~100 tokens each; gstack adds ~2–3k
  for its 23 skills), auto memory (≤25k cap).
- **Off by default (opt-in):** `github`, `playwright`, `chrome-devtools` MCP
  (toggle with `github-on` / `browser-on`), and Superpowers (installed but
  disabled — `superpowers-on` only for heavy sessions; it preloads ~22k tokens).
- **Levers without losing quality:** delegate fan-out to subagents, use `cavemem`
  for durable memory (not a bloated `CLAUDE.md`), `caveman-on` for output
  compression, and watch `/context` + `/cost`. Audit with `/context` and toggle
  off anything you're not using this session.

### References / going further

- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) and
  [awesome-claude-code-skills](https://github.com/Sensiblehorizonmatahari4990/awesome-claude-code-skills)
  — curated indexes of skills, hooks, commands, and MCP servers.
- [ECC / everything-claude-code](https://github.com/affaan-m/everything-claude-code)
  — a huge harness (261 skills / 64 agents). We cherry-picked the security-review
  gate rather than installing it; if you want the kitchen sink,
  `/plugin marketplace add affaan-m/everything-claude-code` + `/plugin install ecc@ecc`
  (mind the context cost — check `/context` after).

### Pre-commit hooks (Lefthook)

[Lefthook](https://lefthook.dev) runs format/lint on **every** commit — yours and
the agents' — not just Claude's edits. Drop the starter config into a project:

```zsh
hooks   # copies templates/lefthook.yml and runs `lefthook install`
```

It auto-formats staged files with Pint / Ruff / Prettier (whichever apply) and
re-stages the fixes, so nothing unformatted lands. See [`templates/lefthook.yml`](./templates/lefthook.yml).

### Terminal

[Ghostty](https://ghostty.org) is the terminal (fast, native Metal) and
[Starship](https://starship.rs) the prompt. Their configs live under
[`config/`](./config) and symlink into `~/.config`.

## What's in here

| Path | What it does |
| --- | --- |
| [`fresh.sh`](./fresh.sh) | Main bootstrap — orchestrates the whole install |
| [`ssh.sh`](./ssh.sh) | Generates an SSH key and adds it to the agent |
| [`clone.sh`](./clone.sh) | Clones your repositories (empty template) |
| [`ai.sh`](./ai.sh) | Sets up the AI agent layer (symlinks + MCP) |
| [`Brewfile`](./Brewfile) | All Homebrew formulae, casks, and MAS apps |
| [`.zshrc`](./.zshrc) | Zsh / Oh My Zsh config, Herd + tool init, `~/.env` |
| [`.gitconfig`](./.gitconfig) | Global git config (delta, sensible defaults, identity) |
| [`.gitignore_global`](./.gitignore_global) | Global ignore rules (wired via `.gitconfig`) |
| [`aliases.zsh`](./aliases.zsh) | Shell aliases (loaded via `$ZSH_CUSTOM`) |
| [`path.zsh`](./path.zsh) | `$PATH` additions (loaded via `$ZSH_CUSTOM`) |
| [`.env.example`](./.env.example) | Template for `~/.env` secrets (API keys) |
| [`bin/gwt`](./bin/gwt) | Git worktree helper for parallel agents |
| [`bin/claude-auto`](./bin/claude-auto) | Headless, budget-capped Claude runner for automation/CI |
| [`bin/mcp-toggle`](./bin/mcp-toggle) | Enable/disable an opt-in MCP server on demand (keeps context lean) |
| [`config/`](./config) | App configs symlinked into `~/.config` (ghostty, starship, zed) |
| [`templates/`](./templates) | Drop-in project files (`CLAUDE.md`, `lefthook.yml`, `ralph/`, `claude-rules/`) |
| [`.macos`](./.macos) | macOS system defaults |
| [`.mackup.cfg`](./.mackup.cfg) | Mackup app-preferences sync config |
| [`ai/`](./ai) | Versioned AI agent configs + hooks + skills (see above) |

## Day-to-day

```zsh
dotfiles         # cd into the dotfiles repo
reloadshell      # reload Oh My Zsh after editing config
brew bundle      # install anything newly added to the Brewfile
./ai.sh          # re-apply agent configs after editing ai/
gwt new <branch> # spin up a worktree for a parallel agent
boost            # add Laravel Boost to the current project
hooks            # install Lefthook pre-commit hooks in this project
claude-init      # drop a CLAUDE.md template into this project
rules-init       # drop path-scoped .claude/rules into this project
spec             # GitHub Spec Kit (specify init, then /speckit.* commands)
ralph-init       # drop the autonomous Ralph build loop into this project
cauto "..."      # headless, budget-capped Claude run for automation
memview          # open the cavemem persistent-memory viewer
github-on        # enable the (opt-in) github MCP for this session; github-off after
browser-on       # enable Playwright + Chrome DevTools MCP; browser-off after
superpowers-on   # enable the Superpowers plugin for a heavy session; superpowers-off after
gstack-upgrade   # update gstack to the latest /gstack-* commands
mackup backup    # snapshot app preferences before a big change
```

## Troubleshooting

- **A `brew` cask fails to install:** check the exact name on
  [formulae.brew.sh](https://formulae.brew.sh/cask/); some apps change cask IDs.
- **`herd`/`php` not found:** start Herd.app once so it injects its shell config,
  then `reloadshell`.
- **Agent configs missing:** re-run `./ai.sh`; it logs each symlink it creates.
- **MCP servers not registered:** they only register if the `claude` CLI is
  installed — run `./ai.sh` again after the Brewfile install completes.

## Customizing

Want to base your own dotfiles on this? Fork the repo, then:

- Edit [`.macos`](./.macos) — set your computer name (`COMPUTER_NAME`), timezone,
  and locale near the top. More options live in
  [Mathias Bynens' script](https://github.com/mathiasbynens/dotfiles/blob/master/.macos).
- Trim/extend the [`Brewfile`](./Brewfile) ([cask search](https://formulae.brew.sh/cask/)).
- Add your aliases in [`aliases.zsh`](./aliases.zsh) and `$PATH` tweaks in
  [`path.zsh`](./path.zsh) (auto-loaded because `$ZSH_CUSTOM` points here).
- List the repos you want cloned in [`clone.sh`](./clone.sh).
- Tailor the agent instructions in [`ai/AGENTS.md`](./ai/AGENTS.md).

Back up your app preferences with Mackup (synced to iCloud by default):

```zsh
brew install mackup
mackup backup
```

> This repo deliberately uses a simple **symlink + Brewfile + Mackup** approach
> rather than a dedicated manager (chezmoi, stow, yadm). It's easy to read and
> extend; reach for one of those tools only if you need cross-platform templating
> or encrypted, multi-machine secret sync.

## Thanks To...

Forked from [driesvints/dotfiles](https://github.com/driesvints/dotfiles).
Inspiration from the [GitHub does dotfiles](https://dotfiles.github.io/) project,
[Zach Holman](https://github.com/holman/dotfiles), and
[Mathias Bynens](https://github.com/mathiasbynens/dotfiles).
[Sourabh Bajaj](https://twitter.com/sb2nov/)'s
[Mac Setup Guide](http://sourabhbajaj.com/mac-setup/) was invaluable, and the
minimal Zsh theme is by [@subnixr](https://github.com/subnixr/minimal).

Thanks to everyone who open-sources their dotfiles. 💛
