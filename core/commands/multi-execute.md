---
description: Execute a multi-plan by dispatching agents in coordinated waves.
---

# Multi-Execute

## Steps

1. **Load plan**: Read the multi-plan output
2. **Wave 1**: Dispatch all independent tasks in parallel
3. **Collect results**: Wait for all Wave 1 agents to complete
4. **Verify**: Check each result meets its acceptance criteria
5. **Handoff context**: Pass relevant results to dependent tasks
6. **Wave 2+**: Dispatch next wave, repeat collect → verify → handoff
7. **Synthesize**: Combine all results into final deliverable
8. **Report**: Summary of what was done, by whom, with outcomes
