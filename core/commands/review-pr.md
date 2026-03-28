---
description: Run a multi-pass code review on the current branch or a specific PR.
---

# Review PR

Review code changes using the code-reviewer agent.

## Steps

### 1. Identify Changes

```bash
# Changes on current branch vs main
git diff main...HEAD --stat
git log main..HEAD --oneline
```

### 2. Delegate to Code Reviewer

Use the `code-reviewer` agent to perform a full multi-pass review covering:
- Design assessment
- Line-by-line review (functionality, complexity, naming, tests, security)
- Anti-pattern scan (using stack-specific rules if available)

### 3. Output

Produce a structured review with verdict (LGTM / LGTM with Nits / Request Changes),
confidence score, and categorized findings (Must Fix, Should Fix, Nit, Positives).
