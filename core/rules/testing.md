---
paths:
  - tests/**/*
---

# Testing Conventions

- Every new code path must have a corresponding test
- Tests verify behavior, not implementation details
- Test names describe the scenario: test_<unit>_<condition>_<expected>
- One assertion per test when practical, multiple when testing a cohesive behavior
- Use fixtures for shared setup, not inheritance
- Tests must be independent — no ordering dependencies between tests
- Negative tests required: invalid input, missing data, error conditions
