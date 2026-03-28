---
paths:
  - src/**/*.ts
  - src/**/*.tsx
---

# TypeScript & React Conventions

- Strict TypeScript: `strict: true` in tsconfig
- Named exports only — no default exports
- Functional components with hooks — no class components
- Props: interface with descriptive names, not inline types
- State: useState for local, context/Zustand/Redux for shared
- Side effects: useEffect with proper cleanup and dependency arrays
- Formatting: Prettier, ESLint with recommended rules
