# Scroll-video site — reconstruction prompt

One self-contained prompt that builds a full scroll-scrubbed cinematic landing page from
scratch. Fill the `{{PLACEHOLDERS}}`, drop in the film, paste to a coding agent. Brand-agnostic
distillation of a shipped build. Pairs with the `cinematic-scroll-video` skill for the engine code.

---

## Paste this

> Build **{{BRAND}} — {{CONCEPT_NAME}}**: a scroll-scrubbed cinematic landing page for {{WHAT_THE_BRAND_IS}}.
>
> **VIDEO:** `/public/media/{{VIDEO_FILE}}` (reference as `/media/{{VIDEO_FILE}}`). {{ONE_LINE_FILM_DESCRIPTION — the macro-journey}}. Runs WITHOUT the file too: until it's present, render an animated canvas poster as the hero and upgrade automatically when the video is added.
>
> **BRAND:** {{BRAND}} — {{POSITIONING}}. Voice: {{VOICE — e.g. precise, quietly confident, editorial}}. Conversion goal: {{CTA_GOAL — e.g. book a 30-min call}}. Through-line metaphor: {{METAPHOR}}.
>
> **ART DIRECTION:** {{GROUND_COLOR}} ground, {{INK_COLOR}} ink, exactly ONE accent — {{ACCENT}} used under ~1% (active nodes, hairline, HUD). Display: {{GROTESK}} 800, tight negative tracking; mono: {{MONO}} for instruments/labels. Restraint over spectacle; the film is the world, the UI annotates it. (Hold the editorial-art-direction bar — no purple/pink hero gradient, one real subject, light↔dark rhythm.)
>
> **NARRATIVE:** the {{JOURNEY}} mapped to {{N}} chapters, each a capability:
>   01 {{CHAPTER_1}} — {{line}} ({{capability}})
>   02 {{CHAPTER_2}} — {{line}} ({{capability}})
>   03 {{CHAPTER_3}} — {{line}} ({{capability}})
>   04 {{CHAPTER_4}} — {{line}} ({{capability}})
>   Then a commercial finale: "{{FINALE_HEADLINE}}" → {{CTA}}.
>
> **NAVIGATION:** concept-native, not a generic menu — e.g. a vertical "{{SPINE_METAPHOR}}" of {{N}} nodes on a drawing accent path (active node lit, click to jump) + a live HUD readout ({{HUD_METRICS}}) that updates with scroll.
>
> **SIGNATURE MOTION:** (1) fixed fullscreen scrubbed hero driven by total scroll progress; (2) masked line reveals on chapter titles; (3) the nav path draws via `strokeDashoffset` on scrub; (4) scroll-synced HUD counters; (5) active-node handoff between chapters; (6) subtle depth in the background field.
>
> **STACK:** React 19 + TypeScript + Vite + Tailwind v4 (`@tailwindcss/vite`) + GSAP/ScrollTrigger + Lenis + react-router-dom (BrowserRouter) + lucide-react.
>
> **SCROLL-VIDEO ENGINE:** two renderers behind one `setProgress(0..1)` — a hardened `<video>` scrubber (target-time only in ScrollTrigger.onUpdate; one rAF loop damps a playhead with `1-exp(-λ·dt)`; seek only when idle AND `|target-current|>frameEps`; clear the seeking flag on `'seeked'` OR `requestVideoFrameCallback` OR a timeout to dodge the same-value-seek deadlock; keep `src` on cleanup; StrictMode-safe) — and a canvas image-sequence scrubber for iOS/smoothest. Reduced-motion → static poster, page fully usable. Encode the mp4 near-all-intra (`-g 1 -keyint_min 1 -sc_threshold 0 -bf 0 -fps_mode cfr -movflags +faststart -crf 18 -an`).
>
> **SMOOTH SCROLL:** Lenis driven only by the GSAP ticker (never a second RAF); forward scroll to `ScrollTrigger.update`; reset on route change; expose an imperative `scrollToProgress` for an Auto Tour; disable under reduced motion.
>
> **AUTO TOUR:** fixed control on `/` only. Start→Pause→Resume→Replay, live %, Restart after >2%, 1×/2× (1×=20s, 2×=10s), a linear GSAP tween driving Lenis, any manual input pauses, Escape stops without resetting scroll, no per-frame React re-render, aria-live + visible focus.
>
> **RESPONSIVE/A11Y:** authored desktop + mobile, no horizontal overflow, semantic HTML, keyboard-operable real buttons/links, visible focus, decorative media `aria-hidden`, reduced-motion respected. Routes: `/` (experience) and `/prompt` (this archive) with SPA fallback (`public/_redirects` → `/* /index.html 200`).

---

**Tip:** the `cinematic-scroll-video` skill's `references/SCROLL_VIDEO_ENGINE.md` carries the
full hardened `ScrollVideo.tsx` — hand it to the agent alongside this prompt so it doesn't
re-derive the deadlock guards.
