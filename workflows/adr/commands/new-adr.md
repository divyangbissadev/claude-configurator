---
description: Create a new Architecture Decision Record (ADR).
---

# New ADR

## Steps

1. **Find next number**: Check `docs/architecture/adr/` for the highest-numbered ADR
2. **Scaffold**: Create `docs/architecture/adr/NNN-<title>.md` with template:

```markdown
# ADR-NNN: <Title>

**Status**: Proposed | Accepted | Deprecated | Superseded
**Date**: YYYY-MM-DD
**Deciders**: [who was involved]

## Context
[What is the issue that we're seeing that is motivating this decision?]

## Decision
[What is the change that we're proposing and/or doing?]

## Consequences
[What becomes easier or harder as a result of this decision?]

## Alternatives Considered
[What other options were evaluated and why were they rejected?]
```

3. **Fill in context**: based on the current discussion
4. **Commit**: with message referencing the ADR number
