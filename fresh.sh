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
mkdir -p $HOME/Herd                       # Laravel/PHP apps served by Herd
mkdir -p $HOME/Code/php                    # PHP packages
mkdir -p $HOME/Code/js                     # JavaScript/TypeScript
mkdir -p $HOME/Code/python                 # Python
mkdir -p $HOME/Code/ai                     # AI / agent projects

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
