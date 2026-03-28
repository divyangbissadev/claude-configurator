---
paths:
  - "**/*"
---

# Git Workflow Conventions

- Commits: one logical change per commit, descriptive message
- Branch naming: feature/, bugfix/, hotfix/ prefixes
- PRs: small and focused — under 400 lines of diff preferred
- Never force-push to shared branches (main, develop, release/*)
- Rebase feature branches before merge to keep history linear
- Delete feature branches after merge
