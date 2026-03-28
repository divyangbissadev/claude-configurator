---
paths:
  - "**/*"
---

# Performance Conventions

- Never use O(n^2) algorithms when O(n log n) or O(n) alternatives exist
- Never make synchronous blocking calls in async contexts
- Never load entire datasets into memory when streaming/pagination is available
- Cache expensive computations — but invalidate correctly
- Prefer batch operations over individual operations in loops
- Profile before optimizing — measure, don't guess
- Database queries: use indexes, avoid N+1, paginate large result sets
- Log at appropriate levels — never log in hot paths at DEBUG without gating
