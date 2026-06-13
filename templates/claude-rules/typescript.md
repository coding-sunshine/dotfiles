---
paths:
  - "**/*.{ts,tsx}"
---

# TypeScript

- Type-check before declaring done (`pnpm typecheck` / `tsc --noEmit`).
- Prefer `pnpm`; use `bun` for scripts. Don't add dependencies without reason.
- Avoid `any`; model state with precise/discriminated types where it clarifies.
- Match the existing module and import conventions; reuse existing utilities.
