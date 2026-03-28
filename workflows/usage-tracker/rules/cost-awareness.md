---
paths:
  - .claude/agents/**/*
---

# Cost Awareness Conventions

- Use the cheapest model that can handle the task (haiku for mechanical, sonnet for standard, opus for complex)
- Avoid dispatching agents for tasks that can be done with direct tool calls
- Batch related file reads into single operations where possible
- Prefer Grep/Glob over Agent tool for simple searches
- Log agent dispatches with token counts when available
- Review `/usage` report weekly to identify optimization opportunities
