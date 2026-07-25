# Macro-journey video-model prompts

Write the ~8-second extreme-macro one-take film that becomes a scroll-scrubbed hero.
Generate with **Kling 3.0 + Motion Control** (primary) or **Veo 3.1** (runner-up).
Avoid Sora 2 (discontinued 2026). "Kimi K3" is an authoring LLM, NOT a video generator.

## The formula (order matters)

```
Single continuous 8-second [GENRE] shot
moving forward toward [CONCRETE SUBJECT in a material world],
[CAMERA VERB] through [MATERIAL 1 → MATERIAL 2 transition],
[CAMERA VERB] as [TRANSFORMATION happens],
ending [emerging/pulling out] toward [RESOLUTION].
Photorealistic [GENRE] cinematography, physically accurate materials,
strong forward parallax, seamless one-take motion, no cuts,
restrained [COLOR] color.
```

Rules that make it read as film, not AI:
- **One camera verb per phase** (moving forward · descending · threading · pulling back). Never stack.
- **Concrete material nouns**, not abstractions ("copper canyons", "fibrous paper", not "data", "energy").
- **Medium transitions** (air→water, ink→pixel, paper→sound) give the model unambiguous per-segment targets — far stronger than pure zoom.
- **Strictly monotonic motion** (one direction) so reverse-scrolling never looks broken.
- **`strong forward parallax` + `seamless one-take, no cuts`** are load-bearing — keep them.
- **Restrained color, stated last.** One palette (cool indigo, warm dawn), never rainbow.
- Generate 16:9; the site crops with `object-fit: cover`. Trim to the cleanest continuous 8s; QA frame-by-frame (no cut, no flicker, monotonic).

## 10 archetypal journeys (swap the subject for the brand)

Each maps a physical descent to a meaning. Pick the one whose metaphor fits the brand.

1. **Neuron → cosmos** — a firing neuron, down the axon through synapses, the web widening until neurons resolve into stars. *(intelligence, AI, thought)*
2. **Silicon** — across a polished wafer, into etched copper canyons, to a transistor igniting, out over a chip city. *(engineering, hardware)*
3. **Ink → interface** — along a pen tip, into a bead of ink spreading on paper fibers that resolve into a pixel grid → a lit interface. *(brand → product)*
4. **Server → city** — down a data-center aisle to a blinking LED, into the fiber behind it, out over a night city pulsing in sync. *(infrastructure, scale)*
5. **Letter → language** — across embossed letterforms dissolving into audio waveforms, through a stream of tokens assembling into meaning → a calm chat UI. *(NLP, comms)*
6. **Seed → forest** — toward a seed in dark soil, a root threading through minerals, branching into a lattice, rising to a sapling in first light. *(growth, empowerment)*
7. **Lens → clarity** — into a stack of lens elements, between glass and aperture blades, through the point of focus → a crisp product resolving. *(UX, precision)*
8. **Circuit → board** — along a copper trace to a molten solder joint cooling, threading between capacitor towers, out over a PCB at blue hour. *(systems, reliability)*
9. **Dust → constellation** — through drifting dust motes igniting into stars that align into a form/face of light → a full sky map. *(vision, the mark)*
10. **Thread → emblem** — across dark fabric weave, between fibers as a luminous thread stitches a form, pulling back to a finished embossed emblem. *(craft, brand)*

## Encode for smooth scrubbing (the #1 lever — do not skip)

```bash
ffmpeg -i raw.mp4 -an -c:v libx264 -crf 18 -preset slow \
  -g 1 -keyint_min 1 -sc_threshold 0 -bf 0 \
  -fps_mode cfr -r 30 -movflags +faststart hero.mp4
```

Near-all-intra (`-g 1`) makes every frame a seek target — the single biggest smoothness
lever for `<video>.currentTime` scrubbing. For iOS, also export a WebP frame sequence and
use the image-sequence renderer (see the `cinematic-scroll-video` skill).
