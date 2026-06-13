<p align="center"><img src="art/banner-2x.png"></p>

## Introduction

My personal dotfiles for setting up and maintaining a **macOS Tahoe (macOS 26)**
machine on Apple Silicon. One script takes a clean Mac and installs my tooling
for a **mixed PHP/Laravel + JS/TS + Python** stack, applies sensible macOS
defaults, and — importantly — wires up a first-class **AI agent layer** (Claude
Code, Codex, Cursor, Gemini CLI) plus a self-hosted **Hermes Agent**.

Originally forked from [driesvints/dotfiles](https://github.com/driesvints/dotfiles)
and adapted for an AI-agent-driven 2026 workflow.

### What you get

- **Homebrew** packages, casks, and Mac App Store apps from a single [`Brewfile`](./Brewfile)
- **Zsh + Oh My Zsh** with a minimal theme, aliases, and `$PATH` setup
- Modern CLI tooling: `rg`, `fd`, `fzf`, `eza`, `zoxide`, `git-delta`, `lazygit`, `direnv`
- Per-language toolchains: Herd (PHP), `pnpm`/`bun` (JS/TS), `uv`/`ruff` (Python)
- An [AI agent layer](#ai-agent-layer): versioned configs for Claude Code, Codex,
  Gemini CLI, shared MCP servers, and a self-hosted Hermes Agent stack
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

Use **one** of:

- **1Password (recommended):** install 1Password and enable its
  [SSH agent](https://developer.1password.com/docs/ssh/get-started/#step-3-turn-on-the-1password-ssh-agent),
  then sync your keys locally.
- **Manual:** [generate a key](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) with:

  ```zsh
  curl https://raw.githubusercontent.com/coding-sunshine/dotfiles/HEAD/ssh.sh | sh -s "<your-email-address>"
  ```

Make sure the key is added to your [GitHub account](https://github.com/settings/keys).

### 3. Clone and install

```zsh
git clone --recursive git@github.com:coding-sunshine/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./fresh.sh
```

`fresh.sh` is idempotent — safe to re-run. It will:

1. Install Xcode Command Line Tools, Oh My Zsh, and Homebrew
2. Symlink [`.zshrc`](./.zshrc) into your home directory
3. Install everything in the [`Brewfile`](./Brewfile)
4. Create project directories (`~/Herd`, `~/Code/{php,js,python,ai}`)
5. Clone your repositories (edit [`clone.sh`](./clone.sh) first — it ships empty)
6. Set up the [AI agent layer](#ai-agent-layer) via [`ai.sh`](./ai.sh)
7. Symlink the Mackup config
8. Apply [`.macos`](./.macos) system defaults (this reloads the shell at the end)

### 4. Finish up

1. Start **Herd.app** and complete its install process (provides PHP/Node/DBs)
2. Copy the secrets template and fill in your keys:
   ```zsh
   cp ~/.dotfiles/.env.example ~/.env && $EDITOR ~/.env
   ```
3. Restore app preferences once Mackup has synced from your cloud storage:
   ```zsh
   mackup restore
   ```
4. Restart your Mac to finalize everything.

### 5. Verify

```zsh
brew bundle check --file ~/.dotfiles/Brewfile   # all packages installed?
ls -l ~/.claude ~/.codex ~/.gemini              # agent configs symlinked?
claude mcp list                                 # MCP servers registered?
echo $ANTHROPIC_API_KEY                          # ~/.env loaded? (non-empty)
```

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

### Self-hosted Hermes Agent

[`ai/hermes/`](./ai/hermes) runs the always-on
[Hermes Agent](https://hermes-agent.org) with a local Ollama model runtime via
Docker Compose.

```zsh
cp ai/hermes/.env.example ai/hermes/.env   # add your provider keys
hermes-up        # start  (alias for ai/hermes/hermes.sh up)
hermes-logs      # follow logs
hermes-down      # stop
```

> ⚠️ The compose file uses a **placeholder image**. Confirm the official Hermes
> Agent image/repo and update [`ai/hermes/docker-compose.yml`](./ai/hermes/docker-compose.yml)
> before first run.

### Secrets

API keys live in `~/.env` (git-ignored), which [`.zshrc`](./.zshrc) sources
automatically on shell start. Start from [`.env.example`](./.env.example).
Nothing secret is ever committed.

## What's in here

| Path | What it does |
| --- | --- |
| [`fresh.sh`](./fresh.sh) | Main bootstrap — orchestrates the whole install |
| [`ssh.sh`](./ssh.sh) | Generates an SSH key and adds it to the agent |
| [`clone.sh`](./clone.sh) | Clones your repositories (empty template) |
| [`ai.sh`](./ai.sh) | Sets up the AI agent layer (symlinks + MCP) |
| [`Brewfile`](./Brewfile) | All Homebrew formulae, casks, and MAS apps |
| [`.zshrc`](./.zshrc) | Zsh / Oh My Zsh config, Herd + tool init, `~/.env` |
| [`aliases.zsh`](./aliases.zsh) | Shell aliases (loaded via `$ZSH_CUSTOM`) |
| [`path.zsh`](./path.zsh) | `$PATH` additions (loaded via `$ZSH_CUSTOM`) |
| [`.macos`](./.macos) | macOS system defaults |
| [`.mackup.cfg`](./.mackup.cfg) | Mackup app-preferences sync config |
| [`ai/`](./ai) | Versioned AI agent configs (see above) |

## Day-to-day

```zsh
dotfiles         # cd into the dotfiles repo
reloadshell      # reload Oh My Zsh after editing config
brew bundle      # install anything newly added to the Brewfile
./ai.sh          # re-apply agent configs after editing ai/
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
