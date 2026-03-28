#!/usr/bin/env bash
# Memory write gate: validates entries before persisting
# Called by agents before writing to MEMORY.md
# Usage: echo "<entry>" | bash memory-write-gate.sh <agent-name>
#
# Write gates (entry must pass at least ONE):
#   1. Behavioral impact — will this change how Claude acts next time?
#   2. Commitment value — is someone counting on this?
#   3. Decision reasoning — why was X chosen over Y?
#   4. Stable factuality — will this remain true tomorrow?
#   5. Explicit instruction — user said "remember this"
#
# Exit 0 = pass (write allowed)
# Exit 1 = fail (entry rejected with reason on stderr)

AGENT_NAME="${1:-unknown}"
ENTRY=$(cat)

# Check for empty entry
if [[ -z "$ENTRY" ]]; then
    echo "REJECTED: Empty entry" >&2
    exit 1
fi

# Check minimum length (too short = not useful)
ENTRY_LEN=${#ENTRY}
if [[ $ENTRY_LEN -lt 20 ]]; then
    echo "REJECTED: Entry too short ($ENTRY_LEN chars) — add context and evidence" >&2
    exit 1
fi

# Check for prohibited content
if echo "$ENTRY" | grep -qiE "(password|secret|api_key|bearer|token)\s*[:=]"; then
    echo "REJECTED: Entry contains potential secret/credential — never store secrets in memory" >&2
    exit 1
fi

# Check for required format fields
HAS_CATEGORY=false
HAS_INSIGHT=false
HAS_CONFIDENCE=false

echo "$ENTRY" | grep -q "^\[" && HAS_CATEGORY=true
echo "$ENTRY" | grep -qi "insight\|learned\|found\|discovered\|decision\|preference" && HAS_INSIGHT=true
echo "$ENTRY" | grep -qi "confidence:" && HAS_CONFIDENCE=true

if [[ "$HAS_CATEGORY" = false ]]; then
    echo "WARNING: Entry missing category tag ([Pattern], [Decision], [Issue], [Preference], [Context])" >&2
fi

if [[ "$HAS_CONFIDENCE" = false ]]; then
    echo "WARNING: Entry missing Confidence level (High|Medium|Low)" >&2
fi

# Write gate checks (must pass at least one)
PASSES_GATE=false

# Gate 1: Behavioral impact — contains actionable guidance
if echo "$ENTRY" | grep -qiE "(always|never|prefer|avoid|instead of|should|must|don't)"; then
    PASSES_GATE=true
fi

# Gate 2: Commitment value — references deadlines, deliverables
if echo "$ENTRY" | grep -qiE "(deadline|due|deliver|promise|commit|by [0-9]|sprint|milestone)"; then
    PASSES_GATE=true
fi

# Gate 3: Decision reasoning — explains a choice
if echo "$ENTRY" | grep -qiE "(decided|chose|because|reason|trade.?off|over|instead|alternative)"; then
    PASSES_GATE=true
fi

# Gate 4: Stable factuality — domain knowledge
if echo "$ENTRY" | grep -qiE "(\[Context\]|\[Domain\]|architecture|schema|table|column|endpoint|service)"; then
    PASSES_GATE=true
fi

# Gate 5: Explicit instruction — user asked to remember
if echo "$ENTRY" | grep -qiE "(remember|note for future|keep in mind|important:)"; then
    PASSES_GATE=true
fi

if [[ "$PASSES_GATE" = false ]]; then
    echo "REJECTED: Entry doesn't pass any write gate. Must demonstrate:" >&2
    echo "  - Behavioral impact (will change future actions)" >&2
    echo "  - Commitment value (someone is counting on this)" >&2
    echo "  - Decision reasoning (explains why X over Y)" >&2
    echo "  - Stable factuality (domain knowledge)" >&2
    echo "  - Explicit instruction (user said 'remember')" >&2
    exit 1
fi

# Entry passes — allow write
exit 0
