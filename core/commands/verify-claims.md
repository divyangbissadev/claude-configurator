---
description: Verify factual claims about the codebase — check file paths, function existence, and stated behavior.
---

# Verify Claims

Systematically verify claims made during a conversation to catch hallucinations.

## Steps

### 1. Collect Claims

Identify factual claims from the conversation:
- File paths mentioned ("this is in `src/services/OrderService.java`")
- Functions/methods referenced ("the `validateOrder()` method handles...")
- Features claimed ("the codebase supports X")
- API behavior stated ("this endpoint returns Y")
- Configuration options mentioned ("set `enableFeature` in config")

### 2. Verify Each Claim

For each claim, run the appropriate check:

**File paths:**
```bash
# Does the file exist?
ls -la <claimed-path>

# If referencing a specific line:
sed -n '<line>p' <claimed-path>
```

**Functions/methods:**
```bash
# Does the function exist?
grep -rn "def <function_name>\|function <function_name>\|fun <function_name>" <search-path>

# What does it actually do? (read the implementation)
```

**Features:**
```bash
# Is the feature implemented?
grep -rn "<feature-keyword>" <search-path> --include="*.py" --include="*.java" --include="*.ts"
```

**API behavior:**
```bash
# Read the actual handler/endpoint code
# Check tests for expected request/response schemas
```

**Configuration:**
```bash
# Does the config option exist?
grep -rn "<config-key>" <search-path> --include="*.yml" --include="*.json" --include="*.py"
```

### 3. Report

```markdown
## Claim Verification Report

| # | Claim | Source | Verified? | Evidence |
|---|-------|--------|-----------|----------|
| 1 | File `src/foo.py` exists | Agent response | YES | `ls` confirms |
| 2 | `validateOrder()` in OrderService | Agent response | NO — PHANTOM | Grep found no match |
| 3 | Endpoint returns `{order_id}` | Agent response | PARTIAL | Returns `{id}` not `{order_id}` |

### Hallucinations Found: [count]
### Corrections Needed: [list]
```
