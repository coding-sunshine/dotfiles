# Motion-journey system — subject → cinematic scroll narrative

Turn any brand/subject into a structured cinematic scroll story. Three staged prompts:
map the journey (0) → write the film prompt (1) → spec the site (2). Run in order; each
feeds the next. Keeps the metaphor coherent from concept to code.

---

## Prompt 0 — Map the journey

> You are an art director for award-winning agency sites. I'll give you a subject.
> Return a **single continuous physical journey** (one camera, one direction, no cuts)
> whose stages map to what the subject *does*.
>
> Subject: `{{SUBJECT / brand + what it does}}`.
>
> Give me:
> 1. **The through-line metaphor** — one physical world the whole film lives in (e.g. neuron→cosmos, seed→forest, ink→interface). Pick the one whose transformation mirrors the subject.
> 2. **4 chapters**, each = one stage of the descent AND one capability/value of the subject. For each: a 2-3 word stage name, a 3-6 word emotional line, the capability it maps to.
> 3. **A HUD metaphor** — 3-4 instrument readouts that could tick up as you scroll (concept-native numbers, not generic stats).
> 4. **A nav metaphor** — a concept-native vertical navigation (a "spine", a "thread", a "timeline") instead of a menu.
> 5. **A finale headline** — one commercial line + the CTA.
>
> Constraints: strictly monotonic motion; concrete material nouns only; restraint over spectacle. No rainbow, no rule-of-three copy.

## Prompt 1 — Write the film

> From the journey above, write the **8-second macro video-model prompt** using this formula:
>
> `Single continuous 8-second [genre] shot moving forward toward [concrete subject], [camera verb] through [material 1 → material 2], [camera verb] as [transformation], ending [emerging/pulling out] toward [resolution]. Photorealistic [genre] cinematography, physically accurate materials, strong forward parallax, seamless one-take motion, no cuts, restrained [color] color.`
>
> One camera verb per phase. Medium transitions over pure zoom. One palette. Output the single paste-ready line for Kling 3.0 / Veo 3.1.
>
> (See `macro-journey-video-prompts.md` for 10 worked archetypes + the ffmpeg encode.)

## Prompt 2 — Spec the site

> Using the journey (Prompt 0) and film (Prompt 1), fill the reconstruction template in
> `scroll-video-site-reconstruction.md` and hand it to a coding agent along with the
> `cinematic-scroll-video` skill's engine reference. Hold the `editorial-art-direction.md` bar.

---

**Why staged:** the model writes a coherent film only after the metaphor is fixed, and a
coherent site only after the film exists. Skipping 0 is how you get a decorative starfield
instead of a subject — the exact v1 mistake.
