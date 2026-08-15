---
name: mt
description: Finder/router for the 127 installed MengTo skills (mt-* prefix, hidden from context by default). Use when the user types /mt <query>, asks "is there a mengto skill for X", or whenever a task matches MengTo's catalog — web design styles (dark glass, editorial, brutalist, skeuomorphic, paper/beige, mesh gradients), scroll storytelling, GSAP/Lenis motion, WebGL/Three.js effects (lasers, dither, globes, particles, shaders, weather, landscapes), landing/pricing pages, marquees, reveals, borders/shadows, Three.js game development (combat, enemies, inventory, levels, VFX, mobile, shipping), or MengTo workflow skills (TTS, screenshots, publish to GitHub). Search the catalog, pick the best skill, then invoke it.
---

# MengTo skill finder

127 skills from github.com/MengTo/Skills are installed as `mt-<name>` with the
`user-invocable-only` override, so their descriptions never load into context.
This skill is the index: search `catalog.tsv` (in this directory), pick matches,
invoke via the Skill tool.

## How to use

1. Take the query (from `/mt <query>` args, or infer keywords from the current task).
2. Search the catalog — try a few synonyms, it's one line per skill (`name<TAB>description`):
   ```bash
   rg -i 'keyword1|keyword2' ~/.claude/skills/mt/catalog.tsv
   ```
3. One clear winner → invoke it directly: `Skill(skill: "mt-<name>")`, then follow it.
   Several plausible → list the top 3–5 (name + one-line description) and let the
   user pick, unless mid-task — then pick the best yourself and say which you chose.
4. No args (`/mt` alone) → show the category map below and a couple of examples.

## Category map

- **Style systems** (~20): `mt-dark-glass-clean-layout`, `mt-clean-minimal-beige-light-mode`, `mt-orange-clean-paper-saas`, `mt-mesh-gradient-dark-blue-clean`, `mt-skeuomorphic-ui`, `mt-documentary-brutalist-agency`, `mt-editorial-tech`, …
- **Layout patterns**: `mt-agency-grid-layout-minimal`, `mt-framed-grid-layout`, `mt-nested-container-frames`, `mt-split-layout-technical`, `mt-image-first-grid-layout`, …
- **Scroll & motion**: `mt-gsap`, `mt-cinematic-gsap-lenis-motion-system`, `mt-scroll-scrubbed-*`, `mt-staggered-word-reveal`, `mt-masked-reveal`, `mt-marquee-loop`, `mt-animation-on-scroll`, …
- **WebGL / Three.js effects**: `mt-threejs`, `mt-webgl-laser`, `mt-dither-background`, `mt-globe-gl`, `mt-globe-particles`, `mt-shaders-cursor-ripples`, `mt-threejs-weather`, `mt-threejs-landscape`, `mt-falling-leaves`, `mt-vantajs`, `mt-matterjs`, `mt-cobejs`, …
- **Micro details**: `mt-beautiful-shadows`, `mt-css-border-gradient`, `mt-progressive-blur`, `mt-corner-diagonals`, `mt-container-lines`, `mt-number-details`, `mt-company-logos`, …
- **Page playbooks**: `mt-landing-page`, `mt-pricing-page`, `mt-build-awwwards-quality-sites`, `mt-product-proof-saas`, `mt-operational-enterprise-ai`, …
- **Game dev** (20): `mt-build-isometric-arpg`, `mt-design-action-combat`, `mt-tune-enemy-ai`, `mt-build-game-inventory`, `mt-create-game-vfx`, `mt-optimize-threejs-games`, `mt-ship-web-games`, …
- **Workflow/misc**: `mt-elevenlabs-tts`, `mt-publish-project-to-github`, `mt-stitched-full-page-capture`, `mt-unsplash-asset-images`, `mt-write-like-meng-on-x`, …

## Maintenance

Source clone: `~/.agents/skills/Skills`. After `git pull` there, re-link any new
skill dirs as `mt-<name>` symlinks in `~/.claude/skills/`, add
`"mt-<name>": "user-invocable-only"` to `skillOverrides` in
`~/.claude/settings.json`, and regenerate `catalog.tsv` (one `name<TAB>description`
line per skill, parsed from each SKILL.md frontmatter).
