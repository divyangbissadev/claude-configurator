---
paths:
  - src/test/**/*.java
---

# Java Testing Conventions

- Unit tests: JUnit 5, Mockito for dependencies
- Integration tests: `@SpringBootTest` with `@Testcontainers`
- Naming: `should_<expected>_when_<condition>`
- One assertion per test when practical
- `@MockBean` for external service stubs
- Test data: builder pattern or test fixtures
