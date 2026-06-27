# Shortcuts
alias copyssh="pbcopy < $HOME/.ssh/id_ed25519.pub"
alias reloadshell="omz reload"
alias update="dotup"   # pull + brew bundle/upgrade + refresh AI layer (bin/dotup)
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
# Default `claude` (and the `cc` shortcut, which expands to it) to skip the
# per-action permission prompts. Only affects interactive shells, not the
# `claude ...` calls inside scripts like ai.sh / bin/claude-auto.
alias claude="claude --dangerously-skip-permissions"
alias cc="claude"
alias cx="codex"
alias gem="gemini"
alias agents="$EDITOR $DOTFILES/ai/AGENTS.md"

# Laravel Boost — give agents real project context via MCP (run inside a project)
alias boost="composer require laravel/boost --dev && herd php artisan boost:install"

# Git worktrees for parallel agents (bin/gwt). `gwtcd <branch>` jumps into one.
gwtcd() { cd "$(gwt path "$1")"; }

# Drop a starter lefthook.yml into the current project and install the hooks
alias hooks="cp -n $DOTFILES/templates/lefthook.yml ./lefthook.yml; lefthook install"

# Drop a starter CLAUDE.md into the current project
alias claude-init="cp -n $DOTFILES/templates/CLAUDE.md ./CLAUDE.md && \${EDITOR:-zed} ./CLAUDE.md"

# GitHub Spec Kit — spec-driven development (`specify init`, then /speckit.* commands)
alias spec="specify"

# Drop the Ralph autonomous-loop template into the current project (.ralph/)
alias ralph-init="cp -r $DOTFILES/templates/ralph ./.ralph && echo 'edit .ralph/prd.json, work on a throwaway branch, then ./.ralph/ralph.sh'"

# Drop a feature-list template for autobuild (feature list -> plan -> Ralph loop -> PR)
alias autobuild-init="cp -n $DOTFILES/templates/features.md ./features.md && echo 'edit features.md, then: autobuild features.md'"

# Drop path-scoped Claude rules into the current project (.claude/rules/)
alias rules-init="mkdir -p ./.claude/rules && cp -n $DOTFILES/templates/claude-rules/*.md ./.claude/rules/"

# Headless, budget-capped Claude for automation (bin/claude-auto)
alias cauto="claude-auto"

# Persistent-memory viewer (cavemem). caveman = terse-output mode, installed as a
# plugin by ai.sh and ON by default; these just toggle it for the odd session.
alias memview="cavemem viewer"
alias caveman-on="claude plugin enable caveman@caveman"
alias caveman-off="claude plugin disable caveman@caveman"

# Opt-in MCP toggles (bin/mcp-toggle) — keep the always-on set lean, enable on demand
alias github-on="mcp-toggle github on"
alias github-off="mcp-toggle github off"
alias browser-on="mcp-toggle playwright on && mcp-toggle chrome-devtools on && echo 'Browser MCP on. Agent Browser (npx agent-browser) is the lean default; run npx agent-browser install once.'"
alias browser-off="mcp-toggle playwright off && mcp-toggle chrome-devtools off"

# code-review-graph MCP (uv-installed by fresh.sh). Off by default; toggle on
# from inside the target project, after the one-time per-repo build.
alias review-on="mcp-toggle code-review-graph on && echo 'code-review-graph on. Run \`code-review-graph build\` once in this repo first.'"
alias review-off="mcp-toggle code-review-graph off"

# OpenTelemetry observability (opt-in, heavy). `otel-up` clones+starts the local
# Grafana/Prometheus/Loki stack (ColeMurray/claude-code-otel) and exports the
# telemetry env into THIS shell, so any `claude` launched here streams per-session
# cost/token/cache metrics. `otel-down` stops it. Grafana: localhost:3000.
otel-up() {
  local dir="$HOME/Code/claude-code-otel"
  [ -d "$dir" ] || git clone --depth 1 https://github.com/ColeMurray/claude-code-otel.git "$dir" || return 1
  export CLAUDE_CODE_ENABLE_TELEMETRY=1 OTEL_METRICS_EXPORTER=otlp OTEL_LOGS_EXPORTER=otlp \
    OTEL_EXPORTER_OTLP_PROTOCOL=grpc OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
  ( cd "$dir" && make up ) && echo "OTel up → Grafana http://localhost:3000 (admin/admin). Launch 'claude' from THIS shell to capture."
}
otel-down() { ( cd "$HOME/Code/claude-code-otel" 2>/dev/null && make down ); unset CLAUDE_CODE_ENABLE_TELEMETRY; echo "OTel stack stopped."; }

# Build the free code-only graph + install auto-update git hooks in this repo.
# graphify's semantic graph stays manual (costs tokens): run `/graphify .`.
alias graph-init="code-review-graph build && graphify hook install && echo 'graph built + auto-updates on commit. Run /graphify . for the full semantic graph.'"

# Superpowers plugin — installed but disabled by default (preloads ~22k tokens);
# turn on only for heavy structured-dev sessions, then off again.
alias superpowers-on="claude plugin enable superpowers@superpowers-marketplace"
alias superpowers-off="claude plugin disable superpowers@superpowers-marketplace"

# Update gstack to the latest (re-runs setup, keeping the /gstack-* prefix)
alias gstack-upgrade="(cd ~/.claude/skills/gstack && git pull && ./setup --prefix)"

# Modern CLI replacements (only if installed)
command -v eza >/dev/null 2>&1 && alias ls="eza --icons --group-directories-first" \
  && alias la="eza --icons --group-directories-first -a" \
  && alias lt="eza --icons --tree --level=2"
command -v bat >/dev/null 2>&1 && alias cat="bat --paging=never"
command -v rg >/dev/null 2>&1 && alias grep="rg"
command -v lazygit >/dev/null 2>&1 && alias lg="lazygit"
command -v yazi >/dev/null 2>&1 && alias y="yazi"
command -v btop >/dev/null 2>&1 && alias btm="btop"

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
