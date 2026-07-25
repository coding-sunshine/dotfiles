---
name: cinematic-scroll-video
description: Build an award-style scroll-scrubbed cinematic-video landing page — one continuous ~8s extreme-macro camera journey as a fixed fullscreen hero whose playback is driven by scroll, with chapters/annotations synced to the film. Use when the user wants a "cinematic scroll journey", "scroll-scrubbed video", "Apple-style scroll video", "video that plays on scroll", a hero video microsite, or references the Kimi-K3 / 8-second macro-journey site genre. Covers the full pipeline: ideate the journey, write the video-model prompt, generate the clip, encode it for smooth seeking, and build the React/GSAP/Lenis site with a production scroll-video engine. Does NOT generate the video itself (needs a video model) — but plans, prompts, encodes, and builds everything around it.
---

# Cinematic scroll-video journey

One continuous ~8-second extreme-macro camera film, fixed fullscreen, scrubbed by scroll, with a
concept-specific interface (chapters, instruments, annotations) layered sparingly over it. The film
is the spatial world; the UI explains and dramatizes the journey without covering it.

Read `references/PROMPT_PIPELINE.md` for the source creative prompts (the canonical brief).

## Three corrections over the naive version (why this skill exists)

1. **"Kimi K3" does not generate video.** It's the LLM creative-director/author. The film comes from
   a dedicated video model — **Kling 3.0 + Motion Control** (primary) or **Veo 3.1** (runner-up).
   Avoid Sora 2 (being discontinued 2026). → `references/VIDEO_GENERATION.md`
2. **Native `<video>` + `currentTime` scrubbing is the tutorial pattern, not the pro one.** Apple and
   the best sites scrub a **canvas image sequence** because video seeks lag scroll. Ship two renderers
   behind one `setProgress(0..1)` interface; pick by capability; iOS gets the sequence, not the video.
   → `references/SCROLL_VIDEO_ENGINE.md`
3. **Encoding is the biggest smoothness lever and the prompt omits it.** Near-all-intra (`-g 1`) +
   faststart. No JS cleverness rescues a sparsely-keyframed file. → `references/ASSET_PIPELINE.md`

## Workflow

**Stage A — Ideate** (`PROMPT_PIPELINE.md` Prompt 0): 10 distinct 8s macro journeys; pick one. Best
arcs cross a *medium* (air→water→structure), not just zoom.

**Stage B — Generate the film** (`VIDEO_GENERATION.md`): write the prompt with the formula (genre
anchor · one camera verb per phase · concrete material nouns · `strong forward parallax` ·
`seamless one-take, no cuts` late · restrained color last). Generate at the model's native duration,
trim to the cleanest continuous 8s (don't stitch). **QA frame-by-frame**: zero cuts, no flicker,
strictly monotonic motion, uniform speed.

**Stage C — Encode** (`ASSET_PIPELINE.md`): near-all-intra mp4 + faststart; WebP frame sequence for
the canvas path; poster (LCP + reduced-motion); optional 720p mobile variant.

**Stage D — Build** (`SCROLL_VIDEO_ENGINE.md` + `PROMPT_PIPELINE.md` Prompt 2): React 19 + TS + Vite
+ Tailwind v4 + GSAP/ScrollTrigger + Lenis + react-router. `/` = full experience, `/prompt/` =
reconstruction-prompt archive with a working Copy button. ~500vh. Derive brand, narrative, palette,
typography, chapters, concept-inspired navigation and instruments from the concept — never a generic
centered SaaS hero.

## File manifest (standalone project)

```
package.json  index.html  vite.config.ts  tsconfig*.json
src/main.tsx  src/App.tsx  src/index.css
src/engine/engine.ts                 # ENGINE constants + pickRenderer()
src/components/ScrollVideo.tsx        # VideoScrubber + SequenceScrubber behind setProgress()
src/components/SmoothScroll.tsx       # Lenis on the GSAP ticker
src/components/AutoTour.tsx + .css    # / only; 1×=20s, 2×=10s; any input pauses
src/components/PromptPage.tsx         # /prompt/ archive + Copy Prompt
src/experience/Experience.tsx + .css  # concept-specific hero, chapters, SVG instruments
public/media/hero.mp4 (+ frames/, poster.jpg)
public/_redirects  (or vercel.json)   # SPA fallback for /prompt/
```

## Anti-patterns (the prompt's own "avoid" list, enforced)

Random floating UI · glassmorphism piles · constant blur · gradient blobs · generic feature cards ·
SaaS template sections · animating every element · scroll hijacking · fake loading delays · motion
unrelated to the film · large opaque panels covering the video · horizontal overflow · tiny labels.
Cross-check with the `ai-slop-check` skill before shipping; gate delivery with `polish-pass`.

## Definition of done

`npm run build` clean · no TS errors / unused imports · no runtime console errors · no duplicate GSAP
registration · StrictMode + `/prompt/` direct-load both work · reduced-motion path fully usable ·
60fps desktop / graceful iOS fallback · film is the primary anchor, copy is legible, page is responsive.
```
