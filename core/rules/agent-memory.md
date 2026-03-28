---
paths:
  - .claude/agent-memory/**/*
---

# Agent Memory Conventions

- Memory entries must follow the standard format: category, title, date, context, insight, evidence, confidence, expires
- Never store secrets, credentials, or PII in memory files
- Keep entries concise — one insight per entry, not a narrative
- Set `Expires` for time-sensitive information (sprint deadlines, temporary workarounds)
- Set `Confidence: Low` for uncertain insights — they'll be pruned first
- Update existing entries rather than adding contradictory new ones
- Cross-agent insights go in `shared/MEMORY.md`, agent-specific in `{agent}/MEMORY.md`
- Memory files are committed to git — they're team knowledge, not personal notes
