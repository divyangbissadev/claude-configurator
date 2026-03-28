---
description: Quick cost estimate for the current session or a specific time period.
---

# Cost Estimate

Show quick cost estimate without the full report.

## Steps

### 1. Read Stats

Read from `~/.claude/stats-cache.json` for today's counts.

### 2. Calculate

Using the pricing model:
- Estimate tokens from message and tool call counts
- Apply model-specific pricing
- Show running total for today

### 3. Output

```
Today's estimated usage:
  Messages:    [count]
  Tool calls:  [count]
  Est. tokens: [input] in / [output] out
  Est. cost:   $X.XX (model: [model])

This week:     $X.XX
This month:    $X.XX
```
