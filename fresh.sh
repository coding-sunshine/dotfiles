#!/bin/sh

echo "Setting up your Mac..."

# Check if Xcode Command Line Tools are installed
if ! xcode-select -p &>/dev/null; then
  echo "Xcode Command Line Tools not found. Installing..."
  xcode-select --install
else
  echo "Xcode Command Line Tools already installed."
fi

# Check for Oh My Zsh and install if we don't have it
if test ! $(which omz); then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm -rf $HOME/.zshrc
ln -sw $HOME/.dotfiles/.zshrc $HOME/.zshrc

# Symlink the global git config
ln -sf $HOME/.dotfiles/.gitconfig $HOME/.gitconfig

# Symlink npm config (ignore-scripts=true — blocks malicious postinstall scripts)
ln -sf $HOME/.dotfiles/.npmrc $HOME/.npmrc

# Update Homebrew recipes
brew update

# Trust third-party taps before bundling. Newer Homebrew refuses to load
# formulae from untrusted taps, which aborts `brew bundle` partway (everything
# after the offending line — bun, claude-code, etc. — then silently fails to
# install). Best-effort so it's a no-op on Homebrew versions without `trust`.
for tap in stripe/stripe-cli oven-sh/bun manaflow-ai/cmux mobile-dev-inc/tap; do
  brew tap "$tap" >/dev/null 2>&1 || true
  brew trust "$tap" >/dev/null 2>&1 || true
done

# Install all our dependencies with bundle (See Brewfile)
brew bundle --file ./Brewfile

# Make sure everything brew just installed (bun, claude, ...) is on PATH for the
# rest of this script, so the AI layer setup below doesn't skip gstack/MCP.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Set default MySQL root password and auth type (only if a standalone mysql is
# installed — Herd ships its own database services).
if command -v mysql >/dev/null 2>&1; then
  mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY 'password'; FLUSH PRIVILEGES;"
fi

# Create project directories
mkdir -p $HOME/Herd                        # Laravel/PHP apps served by Herd
mkdir -p $HOME/Code/Personal               # Personal projects
mkdir -p $HOME/Code/Clients                # Client work
mkdir -p $HOME/Code/Cogneiss               # Cogneiss

# Install global Composer tools (best-effort — composer is provided by Herd, so
# this only runs once Herd has injected it; re-run fresh.sh after starting Herd,
# or run `composer global require laravel/installer` manually).
if command -v composer >/dev/null 2>&1; then
  composer global require laravel/installer
fi

# Install global AI tooling (best-effort; needs node/uv from the Brewfile).
# Done before ai.sh so `cavemem install` can wire its MCP during that step.
if command -v npm >/dev/null 2>&1; then
  npm install -g cavemem >/dev/null 2>&1 || true   # persistent compressed memory (MCP)
  npm install -g @alibaba-group/open-code-review >/dev/null 2>&1 || true   # `ocr` — diff/scan code review CLI
  npm install -g @socketsecurity/cli >/dev/null 2>&1 || true   # `socket` — supply-chain scanner, wraps npm/pnpm installs (see .zshrc)
fi
if command -v bun >/dev/null 2>&1; then
  bun add -g ccusage >/dev/null 2>&1 || true       # per-session cost/token visibility (statusline)
fi
# EAS CLI for Expo/React Native builds and submissions. Expo itself stays
# per-project (`npx expo`); only this one is global. PNPM_HOME must be set (see
# .zshrc) or pnpm refuses to install global binaries.
if command -v pnpm >/dev/null 2>&1; then
  PNPM_HOME="$HOME/.local/share/pnpm" PATH="$HOME/.local/share/pnpm/bin:$PATH" \
    pnpm add -g eas-cli >/dev/null 2>&1 || true
fi
# rustup installs no toolchain by default, so `cargo` would not exist yet.
if [ -x "/opt/homebrew/opt/rustup/bin/rustup" ]; then
  /opt/homebrew/opt/rustup/bin/rustup default stable >/dev/null 2>&1 || true
fi
# The maestro formula cannot link while the RunMaestro.ai cask of the same name
# is installed. That cask ships only Maestro.app with no CLI, so overriding is
# safe and is what puts the mobile E2E `maestro` binary on PATH.
brew link --overwrite maestro >/dev/null 2>&1 || true
# Warp Agent CLI now comes from the `warp-agent-cli` cask in the Brewfile
# (provides the same `warp` binary) instead of `curl … | bash`. Piping a remote
# script straight into a shell means the vendor — or anyone who can spoof that
# endpoint — executes as you, with nothing pinned and nothing reviewable.
if command -v uv >/dev/null 2>&1; then
  uv tool install specify-cli --from git+https://github.com/github/spec-kit.git >/dev/null 2>&1 || true  # GitHub Spec Kit
  uv tool install code-review-graph >/dev/null 2>&1 || true   # opt-in code-review graph (review-on)
fi

# Check out git submodules (plugins/artisan — the zsh-artisan plugin). Without
# this the directory exists but is empty, and every shell you open prints
# "[oh-my-zsh] plugin 'artisan' not found".
if command -v git >/dev/null 2>&1; then
  git -C "$HOME/.dotfiles" submodule update --init --recursive || true
fi

# Install the fzf-tab zsh plugin (fuzzy Tab completion). It's git-only (not on
# Homebrew) and git-ignored, so it lives in the custom plugins dir without
# dirtying the repo. Best-effort.
# Pinned: this one is sourced by .zshrc, so it runs in every shell you open.
if command -v git >/dev/null 2>&1 && [ ! -d "$HOME/.dotfiles/plugins/fzf-tab" ]; then
  if git clone --filter=blob:none https://github.com/Aloxaf/fzf-tab "$HOME/.dotfiles/plugins/fzf-tab" >/dev/null 2>&1; then
    git -C "$HOME/.dotfiles/plugins/fzf-tab" checkout -q 24105b15714bfec37989ed5c5b6e60f572253019 2>/dev/null \
      || { rm -rf "$HOME/.dotfiles/plugins/fzf-tab"; echo "  (fzf-tab skipped — pin not found)"; }
  fi
fi

# Clone Github repositories (edit clone.sh first — ships empty)
./clone.sh

# Symlink ~/.config app configs (starship, zed, ...)
mkdir -p $HOME/.config
for item in $HOME/.dotfiles/config/*; do
  name=$(basename "$item")
  rm -rf "$HOME/.config/$name"
  ln -sf "$item" "$HOME/.config/$name"
done

# Set up the AI agent config layer (symlinks + MCP registration)
./ai.sh

# Upgrade everything Homebrew installed and run a health check. Done near the end
# so it catches anything pulled in above. `brew doctor` is advisory (non-zero
# just means warnings), so it never aborts the run.
if command -v brew >/dev/null 2>&1; then
  brew upgrade
  brew doctor || true
fi

# Snapshot the known-good persistence baseline (LaunchAgents/Daemons, cron,
# login items, npm globals) for `security-check` to diff future changes
# against — run `security-check` any time something feels off.
$HOME/.dotfiles/bin/security-check --update

# Set macOS preferences - we will run this last because this will reload the shell
source ./.macos
