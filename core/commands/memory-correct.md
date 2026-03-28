---
description: Correct a previous memory entry — supersedes the old entry and propagates the correction.
---

# Memory Correct

Fix an incorrect or outdated memory entry with full correction propagation.

## Steps

### 1. Find the Entry to Correct

Search across all agent memories:
```bash
grep -rn "<search term>" .claude/agent-memory/ --include="*.md"
```

### 2. Show the Current Entry

Display the full entry with its location, date, and confidence.

### 3. Write the Correction

Create a new entry that:
- References the old entry it supersedes
- Explains what changed and why
- Has `Confidence: High` (corrections are deliberate)

### 4. Propagate

1. **Mark old entry as superseded** in its original file:
   ```
   ### ~~[Pattern] Old title — 2026-03-15~~ [SUPERSEDED 2026-03-28]
   ```

2. **Write new entry** to the same agent's memory

3. **Cross-propagate** to shared memory if the correction is cross-cutting

4. **Check other agents** — does any other agent's memory reference the corrected fact?
   If yes, add a note to their memory too.

### 5. Verify

```bash
grep -rn "SUPERSEDED" .claude/agent-memory/ --include="*.md"
```

Report all changes made.
