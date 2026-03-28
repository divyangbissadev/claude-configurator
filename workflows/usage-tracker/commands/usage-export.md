---
description: Export usage data as CSV or JSON for external analysis (Langfuse, spreadsheets, dashboards).
---

# Usage Export

Export usage tracking data for external analysis tools.

## Steps

### 1. Select Format

Ask: CSV (default) or JSON?

### 2. Select Scope

- `project` — current project only (from `.claude/usage/usage-log.csv`)
- `global` — all projects (from `~/.claude/usage/global-usage.csv`)
- `date-range` — specific dates (e.g., last 7 days, this month)

### 3. Export

**CSV export:**
```bash
# Project usage
cp .claude/usage/usage-log.csv usage-export-$(date +%Y%m%d).csv

# Global usage
cp ~/.claude/usage/global-usage.csv global-usage-export-$(date +%Y%m%d).csv
```

**JSON export:**
```bash
# Convert CSV to JSON
python3 -c "
import csv, json, sys
reader = csv.DictReader(open('.claude/usage/usage-log.csv'))
print(json.dumps(list(reader), indent=2))
" > usage-export-$(date +%Y%m%d).json
```

### 4. Langfuse Integration Guide

To send this data to Langfuse:

```python
from langfuse import Langfuse
import csv

langfuse = Langfuse(
    public_key='your-public-key',
    secret_key='your-secret-key',
    host='https://cloud.langfuse.com'
)

with open('.claude/usage/usage-log.csv') as f:
    reader = csv.DictReader(f)
    for row in reader:
        if row['event'] == 'session_end':
            langfuse.trace(
                name=f"claude-code-{row['project']}",
                metadata={
                    'session_id': row['session_id'],
                    'model': row['model'],
                    'messages': int(row['messages']),
                    'tool_calls': int(row['tool_calls']),
                },
                input={'tokens': int(row['estimated_input_tokens'])},
                output={'tokens': int(row['estimated_output_tokens'])},
            )
            langfuse.generation(
                name=f"session-{row['session_id'][:8]}",
                model=row['model'],
                usage={
                    'input': int(row['estimated_input_tokens']),
                    'output': int(row['estimated_output_tokens']),
                    'total': int(row['estimated_input_tokens']) + int(row['estimated_output_tokens']),
                    'unit': 'TOKENS',
                },
                metadata={'cost_usd': float(row['estimated_cost_usd'])},
            )

langfuse.flush()
```

For Helicone integration, use the proxy approach with the Anthropic API.
