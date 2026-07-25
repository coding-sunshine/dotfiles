# Editorial art-direction brief (the anti-AI-slop bar)

The visual bar that separates a "$10-20K agency" site from AI slop. Distilled from
vectrfl.com / sofihealth.com. Paste as the art-direction constraint BEFORE any build.
The v1→v2 lesson: the gap is rarely missing tech — it's violating this DNA.

---

## Paste this

> ART DIRECTION — hold this bar, no exceptions:
>
> - **Restraint over spectacle.** The content is the subject; the UI annotates it. If an
>   effect doesn't earn its place, cut it.
> - **Light, editorial ground.** Off-white / warm paper (`#f2f1ec`-ish), near-black ink.
>   Dark sections exist for *rhythm* (light↔dark cadence), not as the default.
> - **One huge neutral grotesk.** Archivo / Neue Haas / similar, 800–900 weight, tight
>   negative tracking, set BIG (hero `clamp(48px, 11vw, 150px)`). No ornate serif display.
> - **Near-monochrome + exactly ONE accent**, used under ~1% of the surface (active states,
>   a hairline, one number). No trendy purple/pink hero gradients — that is the #1 slop tell.
> - **A real subject that bleeds off the edge.** Real photography, a product shot, or one
>   subtle same-tone 3D/canvas piece — not a decorative starfield or glow behind text.
> - **Generous whitespace, hard grid.** Big margins, strong left rail, honest baseline.
> - **Motion is craft, not confetti.** Masked line reveals, one signature scroll move,
>   word-brighten-on-scroll scrub (the Sofi effect), a drawing path. Everything eased,
>   nothing bouncy. Respect `prefers-reduced-motion`.
> - **Copy is quiet and confident.** Short, declarative, editorial. No exclamation, no
>   "revolutionize", no rule-of-three padding.

## Self-check before shipping (fail any = not done)

- Would this pass on Awwwards, or does it read as a template? (no generic SaaS hero)
- Is there a purple/pink gradient behind the hero text? → remove it.
- Is there ONE real subject, or just typography floating on a gradient? → add a subject.
- Is the accent under ~1% of the surface, or is color everywhere? → pull it back.
- Is the display face a neutral grotesk set large, or a decorative/serif font? → swap.
- Does the page breathe (whitespace, rhythm), or is it wall-to-wall content? → cut.
- Reduced-motion: is the page fully usable and still handsome? → verify.

Run the `ai-slop-check` + `hierarchy-rhythm-review` skills against the result;
gate with `polish-pass`.
