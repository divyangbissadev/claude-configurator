---
description: Generate, run, and maintain end-to-end tests for critical user journeys.
---

# E2E Tests

## Steps

1. **Identify journeys**: List critical user flows (auth, core features, data integrity)
2. **Prioritize**: HIGH (auth, payments), MEDIUM (search, navigation), LOW (UI polish)
3. **Create tests**: One test per journey, stable selectors, condition-based waits
4. **Run**: Execute locally 3-5 times to check for flakiness
5. **Quarantine**: Mark flaky tests with skip + issue reference
6. **Report**: Pass/fail counts, screenshots on failure
