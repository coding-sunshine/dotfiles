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

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew bundle --file ./Brewfile

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
fi
if command -v uv >/dev/null 2>&1; then
  uv tool install specify-cli --from git+https://github.com/github/spec-kit.git >/dev/null 2>&1 || true  # GitHub Spec Kit
fi

# Clone Github repositories (edit clone.sh first — ships empty)
./clone.sh

# Symlink ~/.config app configs (ghostty, starship, ...)
mkdir -p $HOME/.config
for item in $HOME/.dotfiles/config/*; do
  name=$(basename "$item")
  rm -rf "$HOME/.config/$name"
  ln -sf "$item" "$HOME/.config/$name"
done

# Set up the AI agent config layer (symlinks + MCP registration)
./ai.sh

# Symlink the Mackup config file to the home directory
ln -sf $HOME/.dotfiles/.mackup.cfg $HOME/.mackup.cfg

# Set macOS preferences - we will run this last because this will reload the shell
source ./.macos
