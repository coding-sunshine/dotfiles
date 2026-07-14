# Path to your dotfiles.
export DOTFILES=$HOME/.dotfiles

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Prompt is provided by Starship (initialized at the bottom of this file), so
# Oh My Zsh's own theme is disabled. To revert to the bundled minimal theme,
# set ZSH_THEME="minimal" and remove the `starship init` line below.
ZSH_THEME=""

# Minimal theme settings (only used if you re-enable ZSH_THEME="minimal")
export MNML_INSERT_CHAR="$"
export MNML_PROMPT=(mnml_git mnml_keymap)
export MNML_RPROMPT=('mnml_cwd 20')

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="dd/mm/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$DOTFILES

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  artisan git fzf-tab
  sudo            # press Esc twice to prepend sudo to the last command
  dirhistory      # Alt + ←/→/↑/↓ to navigate directory history
  colored-man-pages
  extract         # `x <archive>` extracts any archive format
  copypath copyfile
  composer npm docker brew gh macos web-search
)

source $ZSH/oh-my-zsh.sh

# Completion styling (case-insensitive) + fzf-tab fuzzy completion previews
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu no                      # fzf-tab replaces the menu
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' fzf-flags --height=50% --border
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath 2>/dev/null || ls -la $realpath'

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# Preferred editor: Zed locally, vim over SSH
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='zed --wait'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Herd injected PHP binary.
export PHP_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/":$PHP_INI_SCAN_DIR

# Herd injected NVM configuration
export NVM_DIR="$HOME/Library/Application Support/Herd/config/nvm"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

[[ -f "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh" ]] && builtin source "/Applications/Herd.app/Contents/Resources/config/shell/zshrc.zsh"

# Herd injected PHP 7.4 configuration.
export HERD_PHP_74_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/74/"

# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/83/"

# Herd injected PHP 8.2 configuration.
export HERD_PHP_82_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/82/"

# Herd injected PHP 8.1 configuration.
export HERD_PHP_81_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/81/"

# Herd injected PHP 8.0 configuration.
export HERD_PHP_80_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/80/"

# Herd injected PHP binary.
export PATH="$HOME/Library/Application Support/Herd/bin/":$PATH


# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/84/"


# Herd injected PHP 8.5 configuration.
export HERD_PHP_85_INI_SCAN_DIR="$HOME/Library/Application Support/Herd/config/php/85/"

# Modern CLI tool initialization (only if installed)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"
# Atuin: magical shell history (Ctrl-R). Up-arrow left as normal zsh history.
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh --disable-up-arrow)"

# Zsh autosuggestions (installed via Homebrew)
HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"
[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && \
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# you-should-use: if you type a command that has an alias defined, it reminds
# you of the shorter alias ("Found existing alias..."). Reinforces muscle memory.
export YSU_MESSAGE_POSITION="after"
[ -f "$HOMEBREW_PREFIX/share/zsh-you-should-use/you-should-use.plugin.zsh" ] && \
  source "$HOMEBREW_PREFIX/share/zsh-you-should-use/you-should-use.plugin.zsh"

# Starship prompt (owns the prompt)
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Load secrets and API keys (git-ignored). See .env.example for the template.
if [[ -f "$HOME/.env" ]]; then
  set -a
  source "$HOME/.env"
  set +a
fi

export PATH="$HOME/.local/bin:$PATH"

# Zsh syntax highlighting MUST be sourced last (after all ZLE widgets)
[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && \
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ── "Use the modern tool" nudges ─────────────────────────────────────────────
# When you run a legacy command that has a better modern replacement installed,
# print a one-line tip. Fires at most once per command per shell session, and
# only if the suggested tool is actually installed, so it never gets spammy.
# (Commands already aliased to modern tools — ls→eza, cat→bat, grep→rg — are omitted.)
typeset -gA _MODERN_TOOLS=(
  find "fd     (friendlier, faster find)"
  du   "dust   (visual disk usage)"
  df   "duf    (prettier disk-free)"
  ps   "procs  (modern process viewer)"
  sed  "sd     (simpler find & replace)"
  man  "tldr   (concise, example-first help)"
  ping "gping  (ping with a live graph)"
  top  "btop   (gorgeous resource monitor)"
  cd   "z      (zoxide — jump to frequent dirs)"
)
typeset -gA _MODERN_TOOLS_SEEN=()
_modern_tool_nudge() {
  local cmd=${1%% *} tip tool
  tip=${_MODERN_TOOLS[$cmd]}
  [[ -n $tip && -z ${_MODERN_TOOLS_SEEN[$cmd]} ]] || return
  tool=${tip%% *}
  command -v "$tool" >/dev/null 2>&1 || return
  _MODERN_TOOLS_SEEN[$cmd]=1
  print -P "%F{yellow}💡 try:%f %F{green}${tip}%f"
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec _modern_tool_nudge

# System splash on new interactive shells (comment out the next line to disable)
command -v fastfetch >/dev/null 2>&1 && [[ -o interactive ]] && fastfetch


# Herd injected PHP 8.4 configuration.
export HERD_PHP_84_INI_SCAN_DIR="/Users/hardikshah/Library/Application Support/Herd/config/php/84/"


# Herd injected PHP 8.0 configuration.
export HERD_PHP_80_INI_SCAN_DIR="/Users/hardikshah/Library/Application Support/Herd/config/php/80/"


# Herd injected PHP 7.4 configuration.
export HERD_PHP_74_INI_SCAN_DIR="/Users/hardikshah/Library/Application Support/Herd/config/php/74/"


# Herd injected PHP 8.5 configuration.
export HERD_PHP_85_INI_SCAN_DIR="/Users/hardikshah/Library/Application Support/Herd/config/php/85/"


# Herd injected PHP 8.3 configuration.
export HERD_PHP_83_INI_SCAN_DIR="/Users/hardikshah/Library/Application Support/Herd/config/php/83/"


# Herd injected PHP 8.2 configuration.
export HERD_PHP_82_INI_SCAN_DIR="/Users/hardikshah/Library/Application Support/Herd/config/php/82/"


# Herd injected PHP 8.1 configuration.
export HERD_PHP_81_INI_SCAN_DIR="/Users/hardikshah/Library/Application Support/Herd/config/php/81/"


# Herd injected PHP binary.
export PATH="/Users/hardikshah/Library/Application Support/Herd/bin/":$PATH
