---
paths:
  - "**/*.test.*"
  - "**/*_test.*"
  - "**/test_*.*"
  - "**/tests/**"
---

# Tests

- Cover the happy path, edge cases, and any bug being fixed (add a regression test).
- Match the project's framework and naming (Pest/PHPUnit, Vitest/Jest, pytest).
- Keep tests deterministic and isolated — no network or real services unless required.
- A change isn't done until its tests pass — show the run output.
