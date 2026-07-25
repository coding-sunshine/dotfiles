# The scroll engine (the hard part)

The source prompt specifies a native `<video>` + `currentTime` scrubber. That's the common
tutorial pattern — and it's the one Apple and the best cinematic sites **deliberately avoid**.
Apple's product pages scrub a **canvas image sequence**, not `<video>`, because video seeks
lag behind scroll and frame-sync isn't guaranteed (a Codrops team, OPTIKKA Oct 2025, abandoned
`<video>` scrubbing for the same reason).

**Decision that actually matters:** ship two renderers behind one `setProgress(0..1)` interface.
Pick by capability, not just aesthetics.

| Renderer | Use when | Smoothness | Cost |
|---|---|---|---|
| `SequenceScrubber` (canvas + WebP frames) | **default for an 8s hero**; always on iOS/Safari; reduced-motion → single frame | frame-accurate, bidirectional, no codec risk | frames preload (~3–5MB WebP / 60 frames @1080p) |
| `VideoScrubber` (native `<video>`, hardened) | capable desktop Chrome/Safari/Firefox, bandwidth-constrained, single-file convenience | good **only with the right encode**; janky on iOS | one small streamed file |

If you build only one, build `SequenceScrubber` — deterministic, no seek machinery, no iOS
fallback needed. Build `VideoScrubber` too only if a single streamed file matters.

> **Encoding is the #1 smoothness lever and the prompt omits it.** No JS gating fixes a sparsely
> keyframed file — on each seek the decoder jumps to the nearest keyframe and replays forward.
> Encode near-all-intra. See `ASSET_PIPELINE.md`. Non-negotiable.

## Documented constants (expose, don't bury)

```ts
export const ENGINE = {
  DAMP_LAMBDA: 6,        // playhead catch-up: higher = snappier. frame-rate-independent
  FRAME_EPS: 1 / 60,     // don't issue a seek within one frame of target (deadlock guard)
  SEEK_TIMEOUT_MS: 120,  // clear "seeking" if `seeked`/rVFC never fires (same-value-seek trap)
  SEQ_FRAMES_DESKTOP: 120,
  SEQ_FRAMES_MOBILE: 48,
  SCROLL_VH: 500,        // document height; tune to narrative
} as const;
```

## VideoScrubber — hardened native `<video>` path

Fixes the four gaps in the raw spec: (1) the near-all-intra encode (asset side), (2) the
**same-value-seek deadlock** (seeking to the current frame fires *no* `seeked` event — guard
with `FRAME_EPS` + a timeout), (3) an explicit iOS/reduced-motion fallback, (4) rVFC→rAF +
listener cleanup under StrictMode.

```tsx
import { useRef, useEffect } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { ENGINE } from "./engine";

gsap.registerPlugin(ScrollTrigger);
const damp = (a: number, b: number, l: number, dt: number) => a + (b - a) * (1 - Math.exp(-l * dt));

export function VideoScrubber({ src, poster }: { src: string; poster: string }) {
  const wrap = useRef<HTMLDivElement>(null);
  const vid = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    const video = vid.current!, reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;
    let raf = 0, target = 0, playhead = 0, seeking = false, seekAt = 0, duration = 0, last = 0;
    const state = { supportsRVFC: "requestVideoFrameCallback" in HTMLVideoElement.prototype };

    const onMeta = () => {
      duration = video.duration || 0;
      ScrollTrigger.create({
        trigger: wrap.current, start: "top top", end: "bottom bottom", scrub: true,
        onUpdate: self => { target = self.progress * duration; },   // set target ONLY
      });
      if (reduce) { video.currentTime = 0; return; }               // reduced-motion: first frame, no loop
      last = performance.now();
      const loop = (now: number) => {
        const dt = Math.min((now - last) / 1000, 0.05); last = now;
        playhead = damp(playhead, target, ENGINE.DAMP_LAMBDA, dt);
        // issue a seek only when idle AND meaningfully far from current frame
        if (!seeking && Math.abs(playhead - video.currentTime) > ENGINE.FRAME_EPS) {
          seeking = true; seekAt = now; video.currentTime = playhead;
        }
        // deadlock guard: same-value seeks never fire `seeked`
        if (seeking && now - seekAt > ENGINE.SEEK_TIMEOUT_MS) seeking = false;
        raf = requestAnimationFrame(loop);
      };
      raf = requestAnimationFrame(loop);
    };
    const onSeeked = () => { seeking = false; };
    const rvfc = () => { seeking = false; if (state.supportsRVFC) (video as any).requestVideoFrameCallback(rvfc); };

    video.addEventListener("loadedmetadata", onMeta);
    video.addEventListener("seeked", onSeeked);
    if (state.supportsRVFC) (video as any).requestVideoFrameCallback(rvfc);   // paint-confirm, else rAF loop covers it

    return () => {                                    // StrictMode-safe: kill timers + listeners, keep src
      cancelAnimationFrame(raf);
      video.removeEventListener("loadedmetadata", onMeta);
      video.removeEventListener("seeked", onSeeked);
      ScrollTrigger.getAll().forEach(t => t.trigger === wrap.current && t.kill());
    };
  }, []);

  return (
    <div ref={wrap} style={{ height: `${ENGINE.SCROLL_VH}vh` }}>
      <video ref={vid} src={src} poster={poster}
        muted playsInline preload="auto" disablePictureInPicture
        style={{ position: "fixed", inset: 0, width: "100%", height: "100%", objectFit: "cover" }} />
    </div>
  );
}
```

Notes: never null `src` on cleanup (avoids re-buffer/flicker under StrictMode double-mount).
`playsInline` (camelCase in JSX) is the #1 silent iOS failure. Handle a rejected `play()`
promise (iOS Low Power Mode blocks muted-inline autoplay) → fall back to poster.

## SequenceScrubber — canvas image sequence (the smoother default)

```tsx
import { useRef, useEffect } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { ENGINE } from "./engine";

export function SequenceScrubber({ base, count, poster }: { base: string; count: number; poster: string }) {
  const wrap = useRef<HTMLDivElement>(null);
  const cv = useRef<HTMLCanvasElement>(null);
  useEffect(() => {
    const canvas = cv.current!, ctx = canvas.getContext("2d")!;
    const dpr = Math.min(devicePixelRatio, 2);
    const frames: HTMLImageElement[] = [];
    let loaded = 0, target = 0, cur = 0, raf = 0, last = performance.now();
    const size = () => { canvas.width = innerWidth * dpr; canvas.height = innerHeight * dpr; draw(cur); };
    const draw = (i: number) => {
      const img = frames[Math.max(0, Math.min(count - 1, Math.round(i)))];
      if (!img?.complete) return;
      const s = Math.max(canvas.width / img.width, canvas.height / img.height);   // cover
      const w = img.width * s, h = img.height * s;
      ctx.drawImage(img, (canvas.width - w) / 2, (canvas.height - h) / 2, w, h);
    };
    for (let i = 0; i < count; i++) {
      const img = new Image(); img.src = `${base}/${String(i).padStart(4, "0")}.webp`;
      img.onload = () => { if (++loaded === 1) draw(0); }; frames.push(img);
    }
    addEventListener("resize", size); size();
    ScrollTrigger.create({ trigger: wrap.current, start: "top top", end: "bottom bottom", scrub: true,
      onUpdate: self => { target = self.progress * (count - 1); } });
    const loop = (now: number) => {
      const dt = Math.min((now - last) / 1000, 0.05); last = now;
      cur += (target - cur) * (1 - Math.exp(-ENGINE.DAMP_LAMBDA * dt));
      draw(cur); raf = requestAnimationFrame(loop);
    };
    raf = requestAnimationFrame(loop);
    return () => { cancelAnimationFrame(raf); removeEventListener("resize", size);
      ScrollTrigger.getAll().forEach(t => t.trigger === wrap.current && t.kill()); };
  }, []);
  return (
    <div ref={wrap} style={{ height: `${ENGINE.SCROLL_VH}vh` }}>
      <canvas ref={cv} style={{ position: "fixed", inset: 0, width: "100%", height: "100%" }} />
    </div>
  );
}
```

## Renderer selection

```ts
export function pickRenderer() {
  const reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const iOS = /iP(hone|ad|od)/.test(navigator.platform) ||
    (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1);   // iPadOS masquerades as Mac
  if (reduce) return "poster";        // static first frame, normal scroll
  if (iOS) return "sequence";         // native video seek is genuinely bad on iOS
  return "video";                     // capable desktop + a proper encode
}
```

## SmoothScroll — Lenis driven by the GSAP ticker (never a second RAF)

```tsx
import { useEffect } from "react";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import Lenis from "lenis";
export function SmoothScroll() {
  useEffect(() => {
    if (matchMedia("(prefers-reduced-motion: reduce)").matches) return;   // no smoothing
    const lenis = new Lenis({ lerp: 0.09, anchors: true });
    lenis.on("scroll", ScrollTrigger.update);
    const tick = (t: number) => lenis.raf(t * 1000);
    gsap.ticker.add(tick); gsap.ticker.lagSmoothing(0);
    return () => { gsap.ticker.remove(tick); lenis.destroy(); };   // StrictMode-safe
  }, []);
  return null;
}
```
Reset scroll on route change (`useLocation` → `lenis.scrollTo(0,{immediate:true})` / `ScrollTrigger.refresh()`).
Export a small imperative API (`scrollToProgress(p)`) for Auto Tour.

## AutoTour — spec (follow the source prompt verbatim)

A fixed control on `/` only. States: Start → Pause → Resume → Replay; live %; Restart after >2%;
1×/2× toggle (1× = whole page in exactly 20s, 2× = 10s). Drive Lenis with a **linear GSAP tween**
of a normalized 0..1 progress (normalize against document height so speed is height-independent).
**Any** manual input pauses it (wheel, touch, drag, PageUp/Down/Home/End/Space/arrows); Escape stops
without resetting scroll; route change kills tweens. **No React re-render per frame** — write progress
through a ref / CSS custom property, expose an `aria-live` status + visible focus ring.

## Build checklist (engine)

- [ ] Encode near-all-intra + faststart (`ASSET_PIPELINE.md`) — before touching JS.
- [ ] `setProgress(0..1)` interface; renderer chosen by `pickRenderer()`.
- [ ] Video path: target-only in `onUpdate`; one rAF damping loop; `FRAME_EPS` + `SEEK_TIMEOUT_MS`
      deadlock guards; rVFC with rAF fallback; keep `src`, cancel rAF + remove listeners on cleanup.
- [ ] iOS → sequence; reduced-motion → poster + normal scroll (page fully usable with no scrub).
- [ ] Loading overlay + buffered/preload progress; poster paints first (protect LCP).
- [ ] Desktop-only mouse parallax; disabled on touch.
- [ ] `useGSAP` / `gsap.context`; StrictMode double-mount is the default test.
- [ ] No `console.log` in any rAF loop; motion is `delta`-driven.
```
