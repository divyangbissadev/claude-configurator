# Agent Memory System

Persistent, structured memory for Claude Code agents. Prevents context rot by preserving learned patterns, decisions, and project knowledge across sessions.

## How It Works

Each agent has a memory file at `.claude/agent-memory/{agent-name}/MEMORY.md`. Agents read their memory before starting work and write new insights after completing tasks.

## Memory Structure

```
.claude/agent-memory/
├── shared/
│   └── MEMORY.md          # Cross-agent knowledge (architecture, domain)
├── code-reviewer/
│   └── MEMORY.md          # Review patterns, recurring issues, author tendencies
├── debugger/
│   └── MEMORY.md          # Root causes found, debugging paths, known issues
├── planner/
│   └── MEMORY.md          # Planning decisions, estimation accuracy, scope patterns
└── {agent-name}/
    └── MEMORY.md          # Agent-specific learned context
```

## Memory Entry Format

Each entry in MEMORY.md follows this format:

```markdown
### [Category] Title — YYYY-MM-DD

**Context**: Why this was learned
**Insight**: What was learned
**Evidence**: File paths, code examples, or references
**Confidence**: High | Medium | Low
**Expires**: Never | YYYY-MM-DD | When [condition]
```

## Categories

| Category | What to Store | Example |
|----------|--------------|---------|
| `[Pattern]` | Recurring code patterns (good or bad) | "N+1 queries in UserService — use batch fetch" |
| `[Decision]` | Agreed architectural choices | "Events over direct DB writes for cross-service comms" |
| `[Issue]` | Known bugs, workarounds, gotchas | "Flaky test in auth module — timing-dependent on CI" |
| `[Preference]` | Team corrections and style preferences | "Team prefers explicit error types over generic Result" |
| `[Context]` | Domain knowledge | "Orders can be in 7 states, only PENDING can be cancelled" |

## When to Write Memory

- After a code review that found a pattern worth remembering
- After debugging that revealed a non-obvious root cause
- After a user correction ("don't do X, do Y instead")
- After discovering a codebase convention not in CLAUDE.md
- After an architectural discussion that produced a decision

## When NOT to Write Memory

- Trivial facts derivable from reading the code
- Temporary state (current branch, in-progress work)
- Information already in CLAUDE.md or docs
- One-off fixes unlikely to recur

## Memory Hygiene

Run `/memory-prune` periodically to:
- Remove entries with expired dates
- Remove entries contradicted by newer entries
- Remove entries about code that no longer exists
- Consolidate duplicate insights

## For Agent Authors

To make your agent memory-aware, add this to the agent's prompt:

```markdown
## Memory Protocol

Before starting work:
1. Read `.claude/agent-memory/{your-name}/MEMORY.md` if it exists
2. Read `.claude/agent-memory/shared/MEMORY.md` for cross-agent context
3. Apply relevant memories to your current task

After completing work:
1. If you learned something worth remembering, append to your MEMORY.md
2. If the insight is relevant to other agents, also add to shared/MEMORY.md
3. Use the standard entry format with category, context, evidence, confidence
```
