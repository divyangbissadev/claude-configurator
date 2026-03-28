---
description: Systematic incident debugging — triage, diagnose, fix, verify.
---

# Debug Incident

## Steps

1. **Gather context**: error messages, stack traces, affected services
2. **Check recent changes**: `git log --oneline -20`, recent deployments
3. **Form hypotheses**: rank 2-3 most likely causes
4. **Investigate**: start with highest probability, gather evidence
5. **Fix**: apply minimal change, verify, commit
6. **Report**: summarize root cause and prevention steps
