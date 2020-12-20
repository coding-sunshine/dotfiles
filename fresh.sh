#!/bin/sh

#Inspirations
#https://github.com/mikeprivette/yanmss/blob/master/setup.sh
#https://github.com/driesvints/dotfiles

echo "Setting up your Mac..."

# Install command-line tools using Homebrew.

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &


if [ ! -f $HOME/.ssh/id_rsa ]; then
    echo "Creating an SSH key for you..."
    ssh-keygen -t rsa

    echo "Please add this public key to Github \n"
    echo "https://github.com/account/ssh \n"
    read -p "Press [Enter] key after this..."
fi


# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

echo "Installing xcode-stuff"
xcode-select --install

# Install XCode Command Line Tools
echo 'Checking to see if XCode Command Line Tools are installed...'
brew config

# Updating Homebrew.
echo "Updating Homebrew..."
brew update

# Upgrade any already-installed formulae.
echo "Upgrading Homebrew..."
brew upgrade

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle

# Remove outdated versions from the cellar.
echo "Running brew cleanup..."
brew cleanup
echo "You're done!"

# Start mysql
brew services start mysql

# Set default MySQL root password and auth type.
mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY ''; FLUSH PRIVILEGES;"

# Install PHP extensions with PECL
printf "\n" | pecl install memcached imagick

# Install global Composer packages
/usr/local/bin/composer global require laravel/valet beyondcode/expose laravel-zero/installer tightenco/lambo tightenco/takeout friendsofphp/php-cs-fixer phpmd/phpmd squizlabs/php_codesniffer sebastian/phpcpd phpdocumentor/phpdocumentor phploc/phploc

#remove
expose token 7d235ef9-70ca-413a-816a-8a9914d70f6a

# Global Node packages
./node.sh

# Install Laravel Valet
$HOME/.composer/vendor/bin/valet install

# Create a Sites directory
# This is a default directory for macOS user accounts but doesn't comes pre-installed
if [ -d $HOME/Code ]
then
    # Create sites subdirectories
    if [ ! -d $HOME/Code/Codeasea ]
    then
      mkdir $HOME/Code/Codeasea
    fi
    if [ ! -d $HOME/Code/Aecor ]
    then
      mkdir $HOME/Code/Aecor
    fi
    if [ ! -d $HOME/Code/Zero ]
    then
      mkdir $HOME/Code/Zero
    fi
    if [ ! -d $HOME/Code/Personal ]
    then
      mkdir $HOME/Code/Personal
    fi
    if [ ! -d $HOME/Code/Experiments ]
    then
      mkdir $HOME/Code/Experiments
    fi
else
    mkdir $HOME/Code
    mkdir $HOME/Code/Codeasea
    mkdir $HOME/Code/Aecor
    mkdir $HOME/Code/Zero
    mkdir $HOME/Code/Personal
    mkdir $HOME/Code/Experiments
fi

# Clone Github repositories
./clone.sh

# Update the Terminal
# Install oh-my-zsh
echo "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc

# Removes .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
rm -rf $HOME/.zshrc
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/themes/powerlevel10k
rm -rf $HOME/.p10k.zsh
ln -s $HOME/.dotfiles/.p10k.zsh $HOME/.p10k.zsh

# Symlink the Mackup config file to the home directory
ln -s $HOME/.dotfiles/.mackup.cfg $HOME/.mackup.cfg

# Global gitignore
ln -s $HOME/.dotfiles/.gitignore_global $HOME/.gitignore_global
git config --global core.excludesfile $HOME/.gitignore_global

# Set macOS preferences
# We will run this last because this will reload the shell
#temporary
source .macos

echo "Need to logout now to start the new SHELL..."
exit

