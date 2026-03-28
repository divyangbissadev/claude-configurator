---
description: Guide test-driven development — write failing test first, then implement.
---

# TDD Workflow

## Steps

### 1. Clarify the Requirement

Ask: What specific behavior should this code exhibit?
Define the input, expected output, and edge cases.

### 2. Write the Failing Test

Write a test that asserts the expected behavior. The test MUST fail because
the implementation doesn't exist yet.

Run the test to confirm it fails with the expected error (not a syntax error).

### 3. Write Minimal Implementation

Write the simplest code that makes the test pass. No extra features, no
premature optimization, no speculative generality.

### 4. Run Tests

Run the full test suite to verify:
- The new test passes
- No existing tests broke

### 5. Refactor (if needed)

Clean up the implementation while keeping all tests green. Commit after each
successful refactor.

### 6. Repeat

Go back to step 1 for the next behavior.
