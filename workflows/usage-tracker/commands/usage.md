---
description: Show token usage, cost estimates, and analytics for this project or globally.
---

# Usage Report

Generate a usage report with token estimates and cost breakdown.

## Steps

### 1. Read Usage Data

Check for usage logs:
- Project-level: `.claude/usage/usage-log.csv`
- Global: `~/.claude/usage/global-usage.csv`
- Claude Code stats: `~/.claude/stats-cache.json`

### 2. Generate Report

Parse the CSV and stats data to produce:

```markdown
## Usage Report — [project name]

### Today
| Metric | Value |
|--------|-------|
| Sessions | X |
| Messages | X |
| Tool calls | X |
| Est. input tokens | X |
| Est. output tokens | X |
| Est. cost | $X.XX |

### Last 7 Days
| Date | Sessions | Messages | Tools | Est. Cost |
|------|----------|----------|-------|-----------|
| YYYY-MM-DD | X | X | X | $X.XX |
| ... | | | | |
| **Total** | **X** | **X** | **X** | **$X.XX** |

### By Model
| Model | Messages | Est. Tokens | Est. Cost | % of Total |
|-------|----------|-------------|-----------|------------|
| opus | X | X | $X.XX | X% |
| sonnet | X | X | $X.XX | X% |
| haiku | X | X | $X.XX | X% |

### Top Agents (by usage)
| Agent | Dispatches | Est. Tokens | Est. Cost |
|-------|-----------|-------------|-----------|
| code-reviewer | X | X | $X.XX |
| ... | | | |

### Cost Optimization Tips
- [If opus usage is high] Consider using sonnet for mechanical tasks (3-5x cheaper)
- [If tool calls are high] Batch related searches to reduce round-trips
- [If sessions are short] Combine related tasks into fewer sessions (reduce context loading)
```

### 3. Compare with Budget (if configured)

If `vars.monthly_budget_usd` is set in `claude-pod.yml`, show:
- Current month spend vs budget
- Projected end-of-month spend
- Warning if on track to exceed

### 4. Cost Model Reference

| Model | Input (per 1M tokens) | Output (per 1M tokens) |
|-------|----------------------|----------------------|
| Claude Opus 4 | $15.00 | $75.00 |
| Claude Sonnet 4 | $3.00 | $15.00 |
| Claude Haiku 3.5 | $0.80 | $4.00 |

Note: These are estimates based on message/tool-call counts. Actual token counts
may vary. For precise tracking, use the Anthropic API dashboard or integrate with
Langfuse/Helicone for production AI features.
