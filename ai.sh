#!/bin/sh

# Sets up the AI agent config layer by symlinking the versioned configs in
# ./ai into the locations each tool expects, and registering shared MCP servers.
# Idempotent: safe to re-run. Called by fresh.sh, or run standalone.

set -e

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
AI="$DOTFILES/ai"

echo "Setting up AI agent layer..."

link() {
  # link <source> <target> — works for files and directories
  mkdir -p "$(dirname "$2")"
  rm -rf "$2"
  ln -s "$1" "$2"
  echo "  linked $2 -> $1"
}

# Claude Code
link "$AI/claude/CLAUDE.md"      "$HOME/.claude/CLAUDE.md"
link "$AI/claude/settings.json"  "$HOME/.claude/settings.json"
link "$AI/claude/statusline.sh"  "$HOME/.claude/statusline.sh"
link "$AI/AGENTS.md"             "$HOME/.claude/AGENTS.md"
link "$AI/claude/hooks"          "$HOME/.claude/hooks"
link "$AI/claude/agents"         "$HOME/.claude/agents"
link "$AI/claude/commands"       "$HOME/.claude/commands"

# Reusable prompt library (tool-agnostic; not auto-loaded, just kept handy).
link "$AI/prompts"               "$HOME/.claude/prompts"

# Skills: symlink each one individually so externally-installed skills (e.g.
# caveman) can live alongside ours without writing into the repo.
[ -L "$HOME/.claude/skills" ] && rm -f "$HOME/.claude/skills"
mkdir -p "$HOME/.claude/skills"
for skill in "$AI"/claude/skills/*/; do
  [ -d "$skill" ] || continue
  name="$(basename "$skill")"
  rm -rf "$HOME/.claude/skills/$name"
  ln -s "${skill%/}" "$HOME/.claude/skills/$name"
  echo "  linked ~/.claude/skills/$name -> ${skill%/}"
done

# Wire up the cavemem persistent-memory engine (local, compressed, survives
# /compact). Best-effort — installed as a global npm package by fresh.sh.
if command -v cavemem >/dev/null 2>&1; then
  cavemem install >/dev/null 2>&1 \
    && echo "  cavemem memory engine wired" \
    || echo "  (cavemem install skipped)"
fi

# Install agent skills via the `npx skills` ecosystem (best-effort). These are
# thin, progressive-disclosure skills (~100 tokens frontmatter each), so they're
# cheap to keep always-on. Land in the user skills dir, coexisting with ours.
# The `skills` CLI itself is the only thing that EXECUTES here (npx runs it);
# the source repos are fetched as markdown and read by the agent, not run. So
# the CLI version is pinned — bump it deliberately after reading the diff.
# The CLI has no --ref flag, so sources still track their default branch.
SKILLS_CLI="skills@1.5.22"
if command -v npx >/dev/null 2>&1; then
  echo "  installing agent skills (npx $SKILLS_CLI)..."
  npx -y "$SKILLS_CLI" add vercel-labs/agent-browser -g -y >/dev/null 2>&1 || true            # token-lean browser CLI
  npx -y "$SKILLS_CLI" add anthropics/skills@frontend-design -g -y >/dev/null 2>&1 || true     # non-AI-looking UI
  npx -y "$SKILLS_CLI" add vercel-labs/agent-skills@web-design-guidelines -g -y >/dev/null 2>&1 || true  # UI audit
  npx -y "$SKILLS_CLI" add ast-grep/agent-skill@ast-grep -g -y >/dev/null 2>&1 || true        # structural code search
  npx -y "$SKILLS_CLI" add vercel-labs/skills@find-skills -g -y >/dev/null 2>&1 || true        # discover/install skills
  npx -y "$SKILLS_CLI" add nextlevelbuilder/ui-ux-pro-max-skill -g -y >/dev/null 2>&1 || true  # UI/UX design suite (7 skills)
  npx -y "$SKILLS_CLI" add pbakaus/impeccable -g -y >/dev/null 2>&1 || true                    # frontend polish/critique
  # mattpocock/skills — ideation set only; full repo has 35 skills, rest bloat
  # every session's context (~100 tok frontmatter each). Add more per-skill.
  for _mp in grill-me grilling grill-with-docs domain-modeling wayfinder to-tickets; do
    npx -y "$SKILLS_CLI" add "mattpocock/skills@$_mp" -g -y >/dev/null 2>&1 || true
  done
fi

# gstack — Garry Tan's command framework. Installed PREFIXED (/gstack-*) so it
# coexists with our /review //ship //plan instead of colliding. Best-effort.
#
# NOTE: this is the ONLY skill install that executes code from the clone
# (`./setup`), and gstack is also the most privileged thing here — it can ask
# for a Supabase PAT with full-account scope and registers MCP servers into
# ~/.claude.json. It is therefore PINNED. To upgrade: read the diff between
# GSTACK_SHA and the new HEAD, then bump the SHA. Never unpin it.
GSTACK_SHA="d078622b73539fc1a7a27e709861e9b6b058ae98"  # 2026-08-12
if command -v bun >/dev/null 2>&1 && command -v git >/dev/null 2>&1; then
  if [ ! -d "$HOME/.claude/skills/gstack" ]; then
    echo "  installing gstack (/gstack-* commands, pinned)..."
    if git clone --single-branch https://github.com/garrytan/gstack.git \
         "$HOME/.claude/skills/gstack" >/dev/null 2>&1 \
       && git -C "$HOME/.claude/skills/gstack" checkout -q "$GSTACK_SHA" 2>/dev/null; then
      ( cd "$HOME/.claude/skills/gstack" && ./setup --prefix >/dev/null 2>&1 ) \
        && echo "  gstack installed (pinned)" \
        || echo "  (gstack setup failed)"
    else
      # Pin didn't resolve — remove the clone rather than run an unpinned tree.
      rm -rf "$HOME/.claude/skills/gstack"
      echo "  (gstack skipped — pinned commit $GSTACK_SHA not found; update GSTACK_SHA)"
    fi
  fi
else
  echo "  (skipping gstack — needs bun + git)"
fi

# AI-related CLI tools via uv (best-effort). code-review-graph backs the
# opt-in code-review-graph MCP below, so install it before registering MCPs.
if command -v uv >/dev/null 2>&1; then
  echo "  installing uv tool CLIs..."
  uv tool install code-review-graph >/dev/null 2>&1 || true                       # crg + crg-daemon (code-review-graph MCP)
  uv tool install graphifyy >/dev/null 2>&1 || true                               # graphify + graphify-mcp
  command -v graphify >/dev/null 2>&1 && graphify install --platform claude >/dev/null 2>&1 || true  # register /graphify skill (idempotent)
  uv tool install git+https://github.com/github/spec-kit.git >/dev/null 2>&1 || true  # specify (GitHub spec-kit)
fi

# Register MCP servers with the Claude CLI (best-effort).
if command -v claude >/dev/null 2>&1; then
  echo "  registering MCP servers with claude..."
  # Nothing is always-on. A July 2026 audit of a month of session logs found
  # filesystem called 11 times (all covered by Read/Glob/Grep) and context7 zero,
  # against ~5-7k tokens of schema re-sent every turn and on every subagent spawn.
  # Everything is opt-in via `mcp-toggle <name> on` (github-on / browser-on).
  echo "  (no always-on MCP servers — use mcp-toggle <name> on)"
  # composio is heavy — register only when an API key is present.
  if [ -n "$COMPOSIO_API_KEY" ]; then
    claude mcp add-json --scope user composio \
      "$(jq -c '.mcpServers.composio | with_entries(select(.key|startswith("//")|not))' "$AI/mcp/mcp.json")" 2>/dev/null \
      || echo "  (composio MCP already registered or failed — skipping)"
  fi

  # Official plugins (best-effort; never fail setup).
  claude plugin marketplace add anthropics/claude-code >/dev/null 2>&1 || true
  for plugin in feature-dev code-review; do
    claude plugin install "$plugin" >/dev/null 2>&1 || true
  done

  # frontend-design, stripe — from Anthropic's claude-plugins-official marketplace.
  claude plugin marketplace add anthropics/claude-plugins-official >/dev/null 2>&1 || true
  claude plugin install frontend-design@claude-plugins-official >/dev/null 2>&1 || true
  claude plugin install stripe@claude-plugins-official >/dev/null 2>&1 || true

  # laravel — official Laravel Claude Code plugin.
  claude plugin marketplace add laravel/claude-code >/dev/null 2>&1 || true
  claude plugin install laravel@laravel >/dev/null 2>&1 || true

  # improve — shadcn's prompt/code improvement plugin.
  claude plugin marketplace add shadcn/improve >/dev/null 2>&1 || true
  claude plugin install improve@improve >/dev/null 2>&1 || true

  # warp — Warp terminal integration commands.
  claude plugin marketplace add warpdotdev/claude-code-warp >/dev/null 2>&1 || true
  claude plugin install warp@claude-code-warp >/dev/null 2>&1 || true

  # Superpowers: install but DISABLE by default (it preloads ~22k tokens when
  # active). Toggle per session with `superpowers-on` / `superpowers-off`.
  claude plugin marketplace add obra/superpowers-marketplace >/dev/null 2>&1 || true
  claude plugin install superpowers@superpowers-marketplace >/dev/null 2>&1 || true
  claude plugin disable superpowers@superpowers-marketplace >/dev/null 2>&1 || true

  # ponytail — lazy/minimal-code mode (/ponytail*).
  claude plugin marketplace add DietrichGebert/ponytail >/dev/null 2>&1 || true
  claude plugin install ponytail@ponytail >/dev/null 2>&1 || true

  # caveman — terse-output mode (pairs with ponytail). Installed ENABLED (on by
  # default every session); toggle ad-hoc with caveman-on / caveman-off.
  claude plugin marketplace add JuliusBrussee/caveman >/dev/null 2>&1 || true
  claude plugin install caveman@caveman >/dev/null 2>&1 || true

  # agent-review-panel — opt-in multi-agent adversarial review for PR/plan
  # boundaries (/roundtable:agent-review-panel). Token-heavy; invoke on demand.
  claude plugin marketplace add wan-huiyan/agent-review-panel >/dev/null 2>&1 || true
  claude plugin install roundtable@agent-review-panel >/dev/null 2>&1 || true
else
  echo "  claude CLI not found yet — re-run ./ai.sh after Brewfile install."
fi

# --- Cinematic / motion web-design skill stack --------------------------------
# Third-party skills for movie-feel, scroll-telling, WebGL sites. Cloned into
# ~/.agents/skills, symlinked into ~/.claude/skills. Companion authored skill
# `cinematic-scroll-video` is tracked in ai/claude/skills; reusable prompts in
# ai/prompts/cinematic-web. Curation rationale: memory note cinematic-web-skills.
# Best-effort — never fail setup.
if command -v git >/dev/null 2>&1; then
  AS="$HOME/.agents/skills"; mkdir -p "$AS"

  # _clone <owner/repo> <dir> <sha> — PINNED. A floating clone means whoever
  # controls that repo controls what lands in ~/.claude/skills on every fresh
  # install. If the pin can't be checked out, the clone is removed rather than
  # left at an unreviewed HEAD. To upgrade: read the diff, then bump the SHA.
  _clone() {
    [ -d "$AS/$2" ] && return 0
    git clone --filter=blob:none "https://github.com/$1" "$AS/$2" >/dev/null 2>&1 || return 0
    git -C "$AS/$2" checkout -q "$3" 2>/dev/null || {
      rm -rf "$AS/$2"
      echo "  (skipped $1 — pinned commit $3 not found; update the SHA)"
    }
  }
  _link()  { ln -sfn "$AS/$1" "$HOME/.claude/skills/$2"; }   # <clone-subpath> <link-name>

  # GSAP official — 8 sub-skills (the cinematic scroll backbone).
  _clone greensock/gsap-skills gsap-skills aed9cfd3277740755f6bfc1155c7aa645403b760
  for s in core timeline scrolltrigger plugins react frameworks utils performance; do
    _link "gsap-skills/skills/gsap-$s" "gsap-$s"; done

  # Single-skill repos (SKILL.md at clone root or one level down).
  _clone tsogjavklann/awwwards-3d awwwards-3d 01072bd4a16f2936633b6209ee3b2aa3fb3b2e4f;     _link awwwards-3d awwwards-3d
  _clone threerocks/hand-drawn-styles hand-drawn-styles 9f150d9f4c90f3a4ace78a751d2d8263d818220c; _link hand-drawn-styles hand-drawn
  _clone Vincentwei1021/video-shotcraft video-shotcraft 41ee360d82f4c491ba9d88a24a4add7d8ff1cf8b;  _link video-shotcraft video-shotcraft
  _clone wshuyi/remotion-video-skill remotion-video-skill d16ebd9ca330d636cf82bfd33d48ae12df74fadd; _link remotion-video-skill remotion-video
  _clone mvanhorn/last30days-skill last30days-skill 1004324ad35a3ba656e6df0faabd54749e398455;      _link last30days-skill/skills/last30days last30days
  _clone 199-biotechnologies/motion-dev-animations-skill motion-dev-animations-skill 3feedfb4dba8adae40fc9a5f9a23e3dda2121205; _link motion-dev-animations-skill motion-dev-animations
  _clone leonxlnx/taste-skill taste-skill e988add20dab0fa97d7a76781c48961c8184288e;               _link taste-skill/skills/taste-skill taste-skill

  # MengTo/Skills (aura.build's design system, 79 skills) — link the curated
  # cinematic + editorial subset as mt-*. Add/remove names to re-curate.
  _clone MengTo/Skills Skills 3f4c22d10055d3fdddb17248d59d0c1b731cb8d3
  MT_PICKS="agency-grid-layout-minimal animation-on-scroll animation-systems background-grid-webgl book-serif-index cinematic-gsap-lenis-motion-system cinematic-scroll-storytelling clean-minimal-beige-light-mode documentary-brutalist-agency editorial-portfolio-chapters editorial-service-booking editorial-tech gsap-scrolltrigger-storytelling image-first-grid-layout light-mode-paper-technical marquee-loop masked-reveal nested-container-clean-agency number-details product-proof-saas progressive-blur reveal-hover-effect scroll-progress-timeline scroll-scrubbed-visual-sequence scroll-scrubbed-word-reveal scroll-world-storytelling shaders-cursor-ripples split-layout-technical staggered-word-reveal technical-wireframe-info-layout threejs unicorn-studio webgl-3d-object webgl-landing-steering webgl-laser"
  for s in $MT_PICKS; do
    [ -d "$AS/Skills/agent-skills/web-design/$s" ] && _link "Skills/agent-skills/web-design/$s" "mt-$s"; done

  echo "  cinematic web skill stack linked"
fi

# --- Copywriting skill ---------------------------------------------------------
# Third-party skill: clickbait titles, microcopy, LinkedIn/blog copy, plus an
# AI-writing humanizer (Wikipedia Signs-of-AI-writing patterns). Overlaps our
# authored humanizer/humanize-text skills but adds copywriting mode; kept
# alongside rather than replacing them. Best-effort — never fail setup.
if command -v git >/dev/null 2>&1; then
  AS="$HOME/.agents/skills"; mkdir -p "$AS"
  if [ ! -d "$AS/ai-copywriter" ]; then
    if git clone --filter=blob:none https://github.com/mikiarlo3/ai-copywriter "$AS/ai-copywriter" >/dev/null 2>&1; then
      git -C "$AS/ai-copywriter" checkout -q 08b53b1ad39887cd94cbaab61cac3b6aae2d8518 2>/dev/null \
        || { rm -rf "$AS/ai-copywriter"; echo "  (ai-copywriter skipped — pin not found)"; }
    fi
  fi
  [ -d "$AS/ai-copywriter" ] && ln -sfn "$AS/ai-copywriter" "$HOME/.claude/skills/ai-copywriter" \
    && echo "  ai-copywriter skill linked"
fi

# --- Daily auto-update: REMOVED (deliberately) --------------------------------
# There used to be a launchd agent here that ran bin/ai-tools-update.sh every
# day at 09:00: git pull on gstack + every repo in ~/.agents/skills, re-run
# gstack's ./setup, and `claude plugin update` for every plugin.
#
# That was an unattended daily arbitrary-code-execution channel from ~30
# third-party upstreams, with no pinning and no review. It is exactly the kind
# of standing exposure that turns one upstream compromise into a local one.
# Update deliberately instead: bump a pin, read the diff, re-run ./ai.sh.
#
# If the old agent is still loaded from a previous install, remove it:
if [ "$(uname)" = "Darwin" ]; then
  if launchctl print "gui/$(id -u)/com.hardikshah.ai-tools-update" >/dev/null 2>&1; then
    launchctl bootout "gui/$(id -u)/com.hardikshah.ai-tools-update" 2>/dev/null || true
    launchctl disable "gui/$(id -u)/com.hardikshah.ai-tools-update" 2>/dev/null || true
    rm -f "$HOME/Library/LaunchAgents/com.hardikshah.ai-tools-update.plist"
    echo "  removed legacy daily auto-update agent"
  fi
fi

echo "AI agent layer ready. Edit configs in $AI and re-run ./ai.sh to update."
