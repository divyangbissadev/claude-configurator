#!/usr/bin/env bash
# Pre-compaction hook: saves high-value context before context window compaction
# Captures current working state so it survives the compaction

CHECKPOINT_FILE=".claude/pre-compact-checkpoint.md"

mkdir -p .claude

cat > "$CHECKPOINT_FILE" <<EOF
# Pre-Compaction Checkpoint
**Saved**: $(date '+%Y-%m-%d %H:%M:%S')

## Git State
$(git status --short 2>/dev/null || echo "Not a git repo")

## Recent Commits
$(git log --oneline -5 2>/dev/null || echo "No commits")

## Modified Files
$(git diff --name-only 2>/dev/null || echo "No changes")
EOF

echo "Pre-compaction checkpoint saved to $CHECKPOINT_FILE"
