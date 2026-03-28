---
description: Write a new entry to agent memory with write-gate validation and correction propagation.
---

# Memory Write

Add a validated entry to agent memory.

## Steps

### 1. Identify Target

Which agent's memory should this go to?
- If it's about code review patterns → `code-reviewer`
- If it's about debugging → `debugger`
- If it's about architecture → `architect`
- If it's cross-cutting → `shared`
- If unsure → `shared`

### 2. Format the Entry

```markdown
### [Category] Title — YYYY-MM-DD

**Context**: Why this was learned (what triggered it)
**Insight**: What was learned (the actionable knowledge)
**Evidence**: File paths, code examples, or references
**Confidence**: High | Medium | Low
**Expires**: Never | YYYY-MM-DD | When [condition]
```

Categories: `[Pattern]`, `[Decision]`, `[Issue]`, `[Preference]`, `[Context]`

### 3. Validate via Write Gate

Before writing, the entry must pass at least ONE gate:

| Gate | Question | Example |
|------|----------|---------|
| **Behavioral** | Will this change how I act next time? | "Always use batch fetch for N+1" |
| **Commitment** | Is someone counting on this? | "API v2 deadline is March 30" |
| **Decision** | Why was X chosen over Y? | "Chose events over direct DB writes because..." |
| **Factual** | Will this remain true tomorrow? | "Orders have 7 states, only PENDING cancellable" |
| **Explicit** | Did the user say "remember this"? | User: "Remember, we never use DLT here" |

If the entry doesn't pass any gate, it's **ephemeral** — note it in the session but don't persist.

### 4. Check for Corrections

Is this entry correcting a previous entry?

If YES (correction propagation):
1. Find the old entry in memory
2. Mark old entry as `[SUPERSEDED by YYYY-MM-DD entry]`
3. Write new entry to:
   - Agent-specific memory (`agent-memory/{agent}/MEMORY.md`)
   - Shared memory (`agent-memory/shared/MEMORY.md`) if cross-cutting
4. Never silently overwrite — always mark superseded with timestamp

If NO (new knowledge):
1. Append to the target agent's `MEMORY.md`
2. Also add to `shared/MEMORY.md` if relevant to other agents

### 5. Confirm

Report what was written and where:
```
Memory written:
  → .claude/agent-memory/code-reviewer/MEMORY.md (1 entry)
  → .claude/agent-memory/shared/MEMORY.md (1 entry, cross-cutting)
  Write gate passed: Behavioral impact
```
