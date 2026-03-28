---
paths:
  - .claude/agents/**/*
---

# Agent Usage Conventions

- Use the most specific agent for the task (e.g., database-reviewer for SQL, not code-reviewer)
- Provide agents with full context — don't make them guess
- Review agent output before applying — agents are assistants, not authorities
- One agent per task — don't ask an agent to do multiple unrelated things
- Prefer delegation to the right agent over doing everything in one session
