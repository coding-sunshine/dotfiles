# Taps
tap 'stripe/stripe-cli'
tap 'oven-sh/bun'
tap 'manaflow-ai/cmux' # for the cmux cask below
tap 'mobile-dev-inc/tap' # for the maestro mobile E2E CLI below

# Binaries
brew 'awscli'
brew 'bash' # Latest Bash version
brew 'bat' # Used for spatie/visit
brew 'caddy' # reverse proxy / local HTTPS
brew 'coreutils' # Those that come with macOS are outdated
brew 'ffmpeg'
brew 'gh'
brew 'git'
brew 'gitleaks' # scan git history/staged changes for leaked secrets
brew 'grep'
brew 'httpie'
brew 'jq' # Used for spatie/visit
brew 'mas' # Mac App Store CLI
brew 'pkg-config' # https://github.com/driesvints/dotfiles/issues/20
brew 'stripe/stripe-cli/stripe'

# Spatie Medialibrary
brew 'jpegoptim'
brew 'optipng'
brew 'pngquant'
brew 'svgo'
brew 'gifsicle'

# Development
brew 'imagemagick'

# JS/TS toolchain (Node itself comes from Herd's NVM)
brew 'pnpm'
brew 'oven-sh/bun/bun'
brew 'vercel-cli' # Vercel deploy CLI

# Python toolchain
brew 'uv'   # fast Python package/project manager
brew 'ruff' # linter/formatter

# Rust toolchain
# rustup is keg-only — .zshrc puts $(brew --prefix rustup)/bin and ~/.cargo/bin
# on PATH. After install run: rustup default stable
brew 'rustup'

# Mobile (React Native + Expo, macOS/iOS only — no Android Studio here)
brew 'watchman'   # RN Metro file watcher
brew 'cocoapods'  # iOS native deps for bare/prebuild RN projects
brew 'fastlane'   # signing/build/upload automation when EAS isn't the answer
brew 'mobile-dev-inc/tap/maestro' # mobile E2E flows (also an EAS Workflows job)
# NOTE: name collision — `cask 'maestro'` below is RunMaestro.ai (AI agent
# console), a different product. The cask ships only Maestro.app with no CLI, so
# `brew link --overwrite maestro` is safe and is what puts this CLI on PATH.
# Expo itself stays per-project (`npx expo`); only eas-cli is global:
#   pnpm add -g eas-cli

# Zsh enhancements
brew 'zsh-autosuggestions'
brew 'zsh-syntax-highlighting'
brew 'zsh-you-should-use' # nudges you toward your aliases when you type the long form

# Modern CLI quality-of-life (great for both humans and AI agents)
brew 'ripgrep'   # rg — fast search
brew 'ast-grep'  # sg — structural (AST) code search/rewrite
brew 'fd'        # friendlier find
brew 'fzf'       # fuzzy finder
brew 'eza'       # modern ls
brew 'zoxide'    # smarter cd
brew 'git-delta'   # better git diffs (line-based, default pager)
brew 'difftastic'  # difft — AST-aware diff, ignores pure reformat noise
brew 'git-absorb'  # auto-fixup staged hunks into the commit that introduced them
brew 'hyperfine'   # statistical CLI benchmarking
brew 'watchexec'   # re-run a command when files change
brew 'jj'          # jujutsu — git-compatible VCS, no staging area, `jj undo` anything
brew 'lazygit'     # git TUI
brew 'lazydocker'  # container TUI (lazygit for Docker/OrbStack)
brew 'lefthook'  # fast, parallel git hooks (format/lint on commit)
brew 'direnv'    # per-directory env (.envrc)
brew 'tldr'      # concise man pages
brew 'starship'  # cross-shell prompt

# Terminal candy + extra modern CLI (nerdy & useful)
brew 'atuin'      # magical shell history (full-screen fuzzy Ctrl-R)
brew 'fastfetch'  # system-info splash on shell start
brew 'btop'       # gorgeous resource monitor
brew 'yazi'       # blazing TUI file manager
brew 'zellij'     # terminal multiplexer (persistent split sessions)
brew 'glow'       # render markdown in the terminal
brew 'jless'      # JSON/YAML viewer
brew 'dust'       # du, but pretty
brew 'duf'        # df, but pretty
brew 'procs'      # ps, but pretty
brew 'sd'         # sed, but simple
brew 'gping'      # ping with a live graph
brew 'sevenzip'   # archives (also a yazi preview dep)
brew 'poppler'    # PDF previews for yazi

# AI / agents
brew 'terminal-notifier' # clickable macOS notifications (Claude notify hook)

# Apps
cask 'blockblock' # alerts on new persistence (LaunchAgents/Daemons, cron, login items) before it can run again
cask 'caffeine'
cask 'claude'
cask 'claude-code'
cask 'cleanshot'
cask 'cmux' # Ghostty-based terminal for running AI coding agents in parallel
cask 'orbstack' # Docker-compatible containers + k8s, ~80% less idle RAM than Docker Desktop
cask 'figma'
cask 'firefox'
cask 'flock-app' # Flock team messaging
cask 'font-jetbrains-mono-nerd-font' # prompt/terminal glyphs (Starship icons)
cask 'github'
cask 'google-chrome'
cask 'helo'
cask 'herd'
cask 'httpie-desktop' # renamed upstream from 'httpie'; GUI companion to the brew CLI
cask 'imageoptim'
cask 'little-snitch' # outbound network firewall — blocks C2/exfil/mining callbacks, unlike the built-in inbound-only firewall
cask 'micro-snitch' # alerts on mic/camera access — catches spyware component of a compromise
cask 'maestro' # RunMaestro.ai — AI agent command center
cask 'pastebot'
cask 'raycast' # launcher: window mgmt, clipboard, snippets, AI
cask 'sequel-ace' # MySQL/MariaDB GUI
cask 'setapp' # app subscription launcher
cask 'slack'
cask 'sublime-text'
cask 'telegram-desktop'
cask 'the-unarchiver'
cask 'tinkerwell'
cask 'tunnelbear'
cask 'warp' # AI-powered terminal
cask 'warp-agent-cli' # `warp` agent CLI (replaces the old curl|bash installer in fresh.sh)
cask 'whatsapp' # native WhatsApp desktop client
cask 'zed' # primary GUI editor
cask 'zoom'

# No Homebrew cask exists for these — install manually, tracked here so `brew bundle` isn't the only record:
# - Grok (x.ai desktop bot): https://x.ai/bot
