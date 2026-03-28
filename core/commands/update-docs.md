---
description: Update project documentation to match current codebase state.
---

# Update Docs

## Steps

1. **Check staleness**: Compare doc timestamps with recent code changes via git log
2. **Identify affected docs**: Which docs reference changed files/functions?
3. **Update CLAUDE.md**: Verify commands, anti-patterns, agents, and architecture are current
4. **Update README**: Verify setup instructions, quick start, and feature list
5. **Update API docs**: Verify endpoints, request/response schemas match code
6. **Verify links**: All referenced files and URLs exist
7. **Commit**: One commit per doc category
