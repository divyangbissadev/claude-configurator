---
paths:
  - src/**/*.test.ts
  - src/**/*.test.tsx
  - src/**/*.spec.ts
---

# Frontend Testing Conventions

- React Testing Library — test behavior, not implementation
- Query by role, label, or text — not by test ID unless necessary
- User events via `@testing-library/user-event`
- Mock external services, not internal components
- Snapshot tests: sparingly, only for stable UI components
- Coverage: focus on business logic and user interactions
