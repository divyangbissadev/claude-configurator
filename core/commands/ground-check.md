---
description: Quick grounding check — verify the last response's claims against actual code before proceeding.
---

# Ground Check

Fast verification of the most recent response's factual claims.

## Steps

### 1. Extract Key Claims

From the last assistant message, identify:
- Any file paths mentioned
- Any function/class/method names
- Any "this does X" statements about code behavior
- Any configuration values or options

### 2. Spot-Check (fast, not exhaustive)

Verify the 3 most important claims:

```bash
# For each claimed file path:
test -f "<path>" && echo "EXISTS" || echo "PHANTOM: <path>"

# For each claimed function:
grep -rn "<function>" . --include="*.py" --include="*.java" --include="*.ts" -l | head -3

# For each claimed behavior:
# Read the actual implementation
```

### 3. Verdict

- **GROUNDED** — all spot-checks pass, safe to proceed
- **SUSPICIOUS** — 1+ claims don't check out, verify more before acting
- **HALLUCINATING** — multiple phantom references, don't trust this response

If SUSPICIOUS or HALLUCINATING:
1. Re-read the actual code
2. Correct the inaccurate claims
3. Re-plan based on reality, not the hallucinated version
