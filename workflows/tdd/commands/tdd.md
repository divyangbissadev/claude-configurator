---
description: Guide test-driven development — red, green, refactor cycle.
---

# TDD

Strict red-green-refactor cycle.

## Steps

1. **Red**: Write a failing test that defines expected behavior
2. **Verify Red**: Run the test — it MUST fail (not with a syntax error)
3. **Green**: Write the minimal code to make the test pass
4. **Verify Green**: Run all tests — they MUST all pass
5. **Refactor**: Clean up while keeping tests green
6. **Commit**: Small, atomic commit after each green state
