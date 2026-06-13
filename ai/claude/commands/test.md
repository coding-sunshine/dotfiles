---
description: Add tests for the current changes
allowed-tools: Read, Edit, Grep, Glob, Bash
---

Add focused tests for the current working-tree changes. Delegate to the
`test-writer` subagent if available; otherwise detect the stack (Pest/PHPUnit,
Vitest/Jest, or pytest), match existing conventions, and cover the happy path,
key edge cases, and any bug being fixed. Run the suite and iterate until green,
then report what you added and the passing output.

$ARGUMENTS
