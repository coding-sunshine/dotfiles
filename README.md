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
- GUI apps: Raycast (launcher), Sequel Ace + TablePlus (DB), VS Code/Cursor, and more
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

```zsh
git clone --recursive git@github.com:coding-sunshine/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./fresh.sh
```

`fresh.sh` is idempotent — safe to re-run. It will:

1. Install Xcode Command Line Tools, Oh My Zsh, and Homebrew
2. Symlink [`.zshrc`](./.zshrc) and [`.gitconfig`](./.gitconfig) into your home directory
3. Install everything in the [`Brewfile`](./Brewfile)
4. Create project directories (`~/Herd`, `~/Code/{php,js,python,ai}`)
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
| [`ai/claude/settings.json`](./ai/claude/settings.json) | `~/.claude/settings.json` | Claude Code model / permissions |
| [`ai/codex/config.toml`](./ai/codex/config.toml) | `~/.codex/config.toml` | Codex CLI config |
| [`ai/gemini/settings.json`](./ai/gemini/settings.json) | `~/.gemini/settings.json` | Gemini CLI config |
| [`ai/mcp/mcp.json`](./ai/mcp/mcp.json) | registered via `claude mcp add-json` | Shared MCP servers (filesystem, github) |

To update: edit a file under `ai/`, then run `./ai.sh`.

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

### Auto-format hook + skills

Claude Code runs [`ai/claude/hooks/format.sh`](./ai/claude/hooks/format.sh) after
every edit (PostToolUse), formatting the touched file with Pint (PHP), Ruff
(Python), or Prettier (JS/TS) — deterministic, so it can't be skipped. The
[`verify`](./ai/claude/skills/verify/SKILL.md) skill runs the right lint/test/
type-check gates for whatever stack a project uses.

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
| [`config/`](./config) | App configs symlinked into `~/.config` (ghostty, starship) |
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
