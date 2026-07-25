# Asset pipeline — encode, frames, serve, fall back

The engine can only be as smooth as the file you feed it. Do this before building.

## 1. Encode the hero video (near-all-intra — the #1 smoothness lever)

Each seek decodes forward from the nearest keyframe, so a keyframe on (almost) every frame is
what makes `<video>` scrubbing feel frame-accurate. For an 8s clip the size cost stays bounded.

```bash
ffmpeg -i raw.mp4 \
  -t 8 \
  -vf "scale=1920:-2" -fps_mode cfr -r 30 \
  -c:v libx264 -profile:v high -level 4.2 -pix_fmt yuv420p \
  -preset slow -crf 18 \
  -g 1 -keyint_min 1 -sc_threshold 0 -bf 0 \
  -an -movflags +faststart \
  public/media/hero.mp4
```

- **`-fps_mode cfr -r 30` forces constant frame rate.** AI clips are often variable-fps, and
  time-based seeking assumes a stable frame↔time mapping — VFR makes seeks land wrong. This is a
  correctness fix, not an optimization. (`-fps_mode` replaced the deprecated `-vsync` in FFmpeg 5.1.)
- `-g 1 -keyint_min 1 -sc_threshold 0 -bf 0` → effectively all-intra, no B-frames (frame-accurate seeks).
  Relax to `-g 5` if file size matters more than perfect smoothness.
- `-pix_fmt yuv420p` is mandatory for Safari/iOS (yuv444/422 won't play on Apple).
- `-crf 18` (not the streaming default ~23) — every frame can be paused on, so each must hold up.
- `-an` drops audio (muted hero). `+faststart` = fast first paint (moov atom up front; does NOT
  change seek speed — that's purely GOP-driven).
- **Codec:** H.264 is the pragmatic default (universal hardware decode, cheapest per-seek CPU).
  AV1 is ~30–50% smaller but hardware decode isn't universal on low-end devices — the exact risk
  for scrub smoothness. Optionally add an AV1 `<source>` only for confirmed-HW-decode devices.

Lower-res mobile variant:
```bash
ffmpeg -i raw.mp4 -t 8 -vf "scale=1280:-2,fps=30" -c:v libx264 -profile:v high \
  -pix_fmt yuv420p -preset slow -crf 20 -g 1 -keyint_min 1 -sc_threshold 0 -bf 0 \
  -an -movflags +faststart public/media/hero-720.mp4
```

## 2. Frame sequence for `SequenceScrubber` (the smoother default path)

WebP is ~3–5MB for 60 frames @1080p vs 15–20MB for PNG. Budget ~120 desktop / ~48 mobile frames.

```bash
# 120 frames, 1600px wide, WebP
ffmpeg -i raw.mp4 -t 8 -vf "scale=1600:-2,fps=15" -q:v 80 -compression_level 6 \
  public/media/frames/%04d.webp
# reference in code as /media/frames/0000.webp ... (0-indexed; adjust padStart to match)
```
Tune frame count to `SCROLL_VH` and clip length; more frames = smoother but heavier preload.
Scale the canvas by `devicePixelRatio` (capped at 2) so frames aren't blurry on Retina.

## 3. Poster (first frame) — used for LCP + reduced-motion + iOS-slow fallback

```bash
ffmpeg -i raw.mp4 -vf "select=eq(n\,0),scale=1920:-2" -frames:v 1 -q:v 3 public/media/poster.jpg
```
Set it as the `<video poster>` and paint it first so a blank hero never becomes the LCP element.

## 4. Responsive + performance budget

- **Poster is the LCP element** — a `<video poster>` (or a hero `<img>`) is LCP-eligible. Ship it
  optimized (JPG/WebP, ~1920w) with **`fetchpriority="high"` + `loading="eager"`** (never `lazy` on
  above-fold hero media — lazy defers the poster fetch and tanks LCP). Let the video/frames load after.
- **Byte budget:** desktop hero ~2–6MB; swap the 720p variant (or the frame sequence) under
  `(max-width: 820px)` / Save-Data / slow connection (`navigator.connection.effectiveType`).
- **`preload="auto"`** for the video path (it must buffer to seek); for sequence, preload frames and
  show a buffered-progress indicator until the first N are ready.
- **iOS:** muted + `playsInline` required; **Low Power Mode blocks muted-inline autoplay** — detect the
  rejected `play()` promise and fall back to poster/tap. Per-tab memory ceilings kill the tab silently —
  keep exactly one decoder/canvas alive, pause work when scrolled off-screen.
- Cap `devicePixelRatio` at 2 for canvas; no `console.log` in rAF loops.

## 5. Reduced-motion + accessibility fallback (non-negotiable)

- `prefers-reduced-motion: reduce` → **no scrub**: show the poster (or a few key still frames as
  chapter dividers), let the page scroll normally. The narrative/copy must be fully usable with the
  film absent — the video is decorative.
- Mark decorative media `aria-hidden="true"`; keep chapter copy in semantic headings **outside** the
  hidden wrapper (`aria-hidden` cascades to descendants) so the story reads with the film absent.
- **`aria-hidden` does NOT remove an element from focus order** — a `<video controls>` stays tabbable
  (focusable-but-hidden bug). Decorative hero → no `controls` (or `tabindex="-1"`).
- Idiomatic gate: `gsap.matchMedia().add("(prefers-reduced-motion: no-preference)", () => { …init scrub… })`
  — ScrollTriggers created inside auto-revert when the preference flips.
- Never trap focus; Auto Tour and all controls are real `<button>`/`<a>` with visible focus + `aria-live`.

## 6. Serving (Vite) + SPA fallback for `/prompt/`

- Files in `public/` are copied to the dist root as-is. `public/media/hero.mp4` → reference as
  **`/media/hero.mp4`** (root-absolute, never a relative path, never `import`ed). Correct per Vite docs.
- The `/prompt/` route is client-side, so a static host must rewrite unknown paths to `index.html`:
  - **Netlify** `public/_redirects`: `/*  /index.html  200`
  - **Vercel** `vercel.json`: `{ "rewrites": [{ "source": "/(.*)", "destination": "/index.html" }] }`
  - **GitHub Pages:** the `404.html` redirect trick (encode path → query, restore via `history.replaceState`).
```
