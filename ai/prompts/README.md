# Prompts

Reusable, tool-agnostic prompt library. Paste into any agent (Claude Code,
aura.build) or a video model. Kept in dotfiles so it's versioned and travels.

Symlinked to `~/.claude/prompts` by `ai.sh` for quick access.

## cinematic-web/ — movie-feel agency websites

Everything to go from idea → a scroll-scrubbed, award-style site. Brand-agnostic;
fill the `{{PLACEHOLDERS}}`. Pairs with the `cinematic-scroll-video` skill (which
carries the production engine code).

| File | Use it to |
| --- | --- |
| `editorial-art-direction.md` | Set the visual bar (the anti-AI-slop brief) BEFORE building. |
| `macro-journey-video-prompts.md` | Write the 8s macro-video-model prompt (Kling/Veo) — formula + 10 archetypes. |
| `scroll-video-site-reconstruction.md` | One prompt that rebuilds a full scroll-video site from scratch. |
| `motion-journey-system.md` | Turn any subject into a 4-chapter cinematic scroll narrative. |

**Order:** art-direction (set the bar) → motion-journey (structure) → macro-video
(the film) → reconstruction (build the site).
