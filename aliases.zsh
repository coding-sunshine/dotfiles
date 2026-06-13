# Shortcuts
alias copyssh="pbcopy < $HOME/.ssh/id_ed25519.pub"
alias reloadshell="omz reload"
alias reloaddns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
alias ll="/opt/homebrew/opt/coreutils/libexec/gnubin/ls -AhlFo --color --group-directories-first"
alias phpstorm='open -a /Applications/PhpStorm.app "`pwd`"'
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
alias compile="commit 'compile'"
alias timestamp="date +%s"
alias version="commit 'version'"

# Directories
alias dotfiles="cd $DOTFILES"
alias library="cd $HOME/Library"
alias projects="cd $HOME/Code"
alias sites="cd $HOME/Herd"

# Laravel
alias a="herd php artisan"
alias fresh="herd php artisan migrate:fresh --seed"
alias tinker="herd php artisan tinker"
alias seed="herd php artisan db:seed"
alias serve="herd php artisan serve"
alias cloud="php $HOME/Code/laravel/cloud-cli/cloud"

# PHP
alias cfresh="rm -rf vendor/ composer.lock && composer i"
alias composer="herd composer"
alias php="herd php"
alias test="pest --no-coverage"

# JS
alias nfresh="rm -rf node_modules/ package-lock.json && npm install"
alias watch="npm run dev"

# Python (uv)
alias uvr="uv run"
alias uvs="uv sync"
alias uva="uv add"
alias venv="uv venv && source .venv/bin/activate"

# AI agents
alias cc="claude"
alias cx="codex"
alias gem="gemini"
alias agents="$EDITOR $DOTFILES/ai/AGENTS.md"

# Laravel Boost — give agents real project context via MCP (run inside a project)
alias boost="composer require laravel/boost --dev && herd php artisan boost:install"

# Git worktrees for parallel agents (bin/gwt). `gwtcd <branch>` jumps into one.
gwtcd() { cd "$(gwt path "$1")"; }

# Modern CLI replacements (only if installed)
command -v eza >/dev/null 2>&1 && alias ls="eza --group-directories-first" && alias lt="eza --tree --level=2"
command -v bat >/dev/null 2>&1 && alias cat="bat --paging=never"
command -v lazygit >/dev/null 2>&1 && alias lg="lazygit"

# Docker
alias docker-composer="docker-compose"

# SQL Server
alias mssql="docker run -e ACCEPT_EULA=Y -e SA_PASSWORD=LaravelWow1986! -p 1433:1433 mcr.microsoft.com/mssql/server:2017-latest"

# Git
alias gs="git status"
alias gb="git branch --sort=-committerdate"
alias gc="git checkout"
alias gl="git log --oneline --decorate --color"
alias amend="git add . && git commit --amend --no-edit"
alias commit="git add . && git commit -m"
alias diff="git diff"
alias force="git push --force-with-lease"
alias nuke="git clean -df && git reset --hard"
alias pop="git stash pop"
alias prune="git fetch --prune"
alias pull="git pull"
alias push="git push"
alias resolve="git add . && git commit --no-edit"
alias stash="git stash -u"
alias unstage="git restore --staged ."
alias wip="commit wip"
