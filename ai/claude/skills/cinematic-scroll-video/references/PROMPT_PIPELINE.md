# The 3-stage creative pipeline (source prompts)

The genre: a scroll-scrubbed fullscreen hero **video** — one continuous ~8s extreme-macro
camera journey — with a React microsite whose chapters sync to the film. Three prompts run
in sequence: ideate → write the video prompt → build the site.

Keep this file as the canonical creative direction. Stage 3 is the heavy one; its technical
requirements are hardened in `SCROLL_VIDEO_ENGINE.md`.

---

## Prompt 0 — Ideation

> You're the sole creative director and senior frontend author for a premium interactive
> portfolio. Give me creative ideas (videos) for TEN radically different, scroll-driven
> commercial landing pages. Each must be a single, continuous 8-second extreme macro camera
> journey — this journey is the main captivating feature of the site, so make them as
> interesting as possible.

Output = 10 distinct one-take macro journeys across different industries.

---

## Prompt 1 — Write the macro-video prompt

> Use the concept to generate a high-quality macro-video prompt for an advanced video model.
> Follow the structure of this reference and adapt it to [concept]:

Reference (analyze WHY it works — see `VIDEO_GENERATION.md` for the formula):

> "Single continuous 8-second cinematic engineering shot moving forward from above a stormy
> cold North Atlantic ocean, descending smoothly beneath the waves through bubbles and
> suspended particles, approaching a monumental steel tidal turbine anchored to the rocky
> seabed, camera passing through the center of its slowly rotating structure with powerful
> water currents visible, continuing forward beside glowing subsea electrical transmission
> cables across the seabed, entering a vast concrete seawall conduit, ending emerging toward
> a realistic coastal city at blue hour as thousands of warm city lights activate,
> photorealistic documentary cinematography, physically accurate materials, strong forward
> parallax, seamless one-take motion, no cuts, restrained natural color."

Output = one video-model prompt. Generate the clip, place it at `/public/media/NAME.mp4`.

---

## Prompt 2 — Build the site (the big one)

Inputs: `VIDEO_FILENAME` and `CONCEPT`. The model acts as sole creative director + senior
frontend author and builds ONE complete production website around the supplied video. No
follow-up questions — infer brand, purpose, identity, narrative, copy, interaction system.

Feel: award-winning commercial microsite — highly animated and cinematic, but grounded,
legible, commercially plausible, usable. ONE website, not a portfolio.

**Creative-direction phase (derive internally, express in the build; document on `/prompt/`):**
1. Distinctive brand name
2. Specific product / institution / offering
3. Realistic conversion goal
4. Hero headline, subcopy, CTA
5. 4–5 narrative chapters mapped to stages of the video
6. Navigation physically inspired by the concept
7. Cohesive palette with exact hex
8. Typography system
9. 5+ signature motion behaviors
10. Strong final commercial climax + CTA

The interface must feel **inseparable from the physical material and motion** in the film.
(pharma → dosage scales, molecular diagrams, clinical labels · mechanical → engraved gauges,
exploded diagrams · organic → branching structures, growth measurements · archival →
registration marks, folio numbers.) Never default to a centered SaaS hero / floating cards /
interchangeable luxury template.

**Routes:** `/` (full experience) and `/prompt/` (reconstruction-prompt archive with brand +
art-direction brief + video path + full reconstruction prompt + stack + working "Copy Prompt"
button + link back). No portfolio index.

**Core:** ~500vh tall. Video fixed + fullscreen behind the interface. Scroll top→bottom scrubs
the film first→last frame. Chapters animate over the film; film is the spatial world, the
interface annotates/dramatizes without needlessly covering it.

See `SCROLL_VIDEO_ENGINE.md` (ScrollVideo, SmoothScroll, AutoTour, engine constants),
`VIDEO_GENERATION.md` (which model, prompt formula), `ASSET_PIPELINE.md` (encode/fallback),
and `SKILL.md` for the build checklist and file manifest.
