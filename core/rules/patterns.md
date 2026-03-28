---
paths:
  - "**/*"
---

# Code Pattern Conventions

- Prefer composition over inheritance
- Keep functions focused — one function, one responsibility
- Use dependency injection for testability — no hardcoded dependencies
- Prefer explicit over implicit — no magic globals or hidden state
- Error handling: fail fast, fail loudly, provide context
- Configuration: externalize, don't hardcode — environment variables or config files
- Naming: intention-revealing names that describe WHY, not HOW
- Files: one concept per file, group by feature not by layer
