# Generating the 8-second macro hero video

The whole site hangs on one clip. Get it right before building anything.

> **Naming correction:** "Kimi K3" (Moonshot) is a text/agentic LLM — it does **not** generate
> video. In this pipeline the LLM is the creative director + frontend author; the video comes
> from a dedicated video model below. Don't tell users an LLM made the film.

## Which video model (2026)

**Primary — Kling 3.0 + Motion Control.** Native 15s duration (trim to the cleanest 8s),
explicit dolly / rack-focus controls for macro depth, verified focus/lighting consistency —
directly serves "no cuts, seamless one-take."

**Runner-up — Veo 3.1.** Best color/lighting realism among broadly-accessible models; camera
control is prompt-native (matches the verb-chain style below). Native window is tighter to 8s.

**Avoid — Sora 2.** Strong output but being discontinued (API dies ~Sept 2026). Don't build a
reusable skill on it.

**Watch — Seedance 2.0 (ByteDance):** best camera-intelligence signal, cheapest, but invite-only.
**Runway Gen-4.5** if you need a longer single take (up to 60s) with granular manual camera paths.

End-to-end cost is ~$1–2 per concept.

## The prompt formula

```
Single continuous [N]-second [genre anchor] shot [camera verb 1] from [start location],
[camera verb 2] through/beneath/into [transition medium], [camera verb 3] toward [end subject].
[Photorealism qualifier], [material/physical specificity], [parallax/depth cue],
seamless one-take motion, no cuts, [color/grade restraint].
```

Why each part earns its place:
- **Journey arc = medium transitions, not just zoom.** air → water → structure. Medium changes
  give the model unambiguous per-segment targets (wave caustics → machined steel). Far stronger
  than pure scale change.
- **Camera verb chain** — `moving forward` → `descending` → `approaching`, each pinned to a
  location (`from above X`, `beneath Y`, `toward Z`), chained by prepositions not "and then" so
  it reads as one trajectory. **One motion per phase** — stacking push+orbit+tilt is the #1 cause
  of muddy AI camera motion.
- **Concrete material nouns** (`steel`, `stormy`, `monumental`) bind to texture/reflectance priors;
  abstract adjectives ("dramatic", "epic") render nothing.
- **`strong forward parallax`** — explicitly asks for foreground/background differential motion,
  the strongest signal of a real dolly vs a slideshow.
- **`seamless one-take motion, no cuts`** placed late — suppresses the model's strong prior toward
  multi-shot editing (training data is mostly cut footage). Critical for scrubbing.
- **Color/grade restraint last** — kills the oversaturated teal-orange "AI video" look and keeps
  the footage compatible with any brand palette layered on top.
- **Genre anchor = `documentary cinematography`, not `cinematic`.** "Cinematic" is a near no-op in
  AI-video corpora now. Borrow a real camera tradition instead.
- **Positive phrasing only.** Models parse "restrained natural color" reliably but ignore negations
  ("not oversaturated").

## Example prompts (steal + adapt)

- **Tidal energy (the reference):** *Single continuous 8-second cinematic engineering shot moving
  forward from above a stormy cold North Atlantic ocean, descending beneath the waves through
  bubbles and suspended particles, approaching a monumental steel tidal turbine anchored to the
  rocky seabed, passing through the center of its slowly rotating structure, continuing beside
  glowing subsea transmission cables, ending emerging toward a coastal city at blue hour as warm
  lights activate. Photorealistic documentary cinematography, physically accurate materials, strong
  forward parallax, seamless one-take motion, no cuts, restrained natural color.*
- **Semiconductor:** *…moving forward across a mirror-polished silicon wafer, descending into its
  etched surface, approaching a single exposed transistor gate. Photorealistic macro cinematography,
  physically accurate materials, strong forward parallax, seamless one-take motion, no cuts,
  restrained cool-neutral color.*
- **Coffee:** *…moving forward across a bed of dark-roasted beans, descending through grinder chaff,
  approaching a ribbon of espresso falling into white porcelain. Photorealistic food cinematography,
  physically accurate materials, strong forward parallax, seamless one-take motion, no cuts,
  restrained warm natural color.*
- **Pharma:** *…moving forward across a single white tablet's surface, descending through its
  dissolving coating, approaching crystalline active-compound structures beneath. Photorealistic
  scientific cinematography, physically accurate materials, strong forward parallax, seamless
  one-take motion, no cuts, restrained clinical color.*

## QA the raw clip BEFORE building (scrubbing is unforgiving)

- [ ] **Zero internal cuts** — any shot change lands at an arbitrary scroll position.
- [ ] **No temporal flicker** — invisible at playback, glaring when stepped/reversed. Screen it
      frame-by-frame.
- [ ] **Strictly monotonic, one-direction motion** — any reverse/oscillation/hold reads as broken
      when scrolled fast or backward.
- [ ] **Uniform motion speed** — models "settle" (fast→slow) near the end, so equal scroll stops
      mapping to equal motion. If it settles, re-time in post or fit an eased scroll→time curve.
- [ ] **Widest safe aspect** (generate 16:9, crop with `object-fit: cover`).
- [ ] **One native generation, not stitched** — stitching via first/last-frame conditioning
      reintroduces seams; prefer a single generation at the model's native max, trimmed to 8s.

Post: interpolate 24/30 → 60fps to cut scrub jank, grade to the brand palette, export a poster
frame. Then hand off to `ASSET_PIPELINE.md` for encode/fallback.
