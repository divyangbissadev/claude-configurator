---
description: Create an implementation plan for a feature or task before writing code.
---

# Plan

## Steps

### 1. Understand the Goal

Clarify: What are we building, why, and what does "done" look like?

### 2. Explore Existing Code

Read the relevant parts of the codebase. Understand existing patterns
before proposing changes.

### 3. Identify Files

List every file that will be created or modified. For existing files,
note the specific functions/sections affected.

### 4. Define Tasks

Break the work into small, testable tasks. Each task should:
- Produce a working, testable increment
- Take 5-15 minutes to implement
- Have a clear "done" condition

### 5. Order by Dependencies

Arrange tasks so each builds on the previous. Data models before logic,
logic before UI, infrastructure before features.

### 6. Write the Plan

Output a numbered task list with:
- Task description
- Files to create/modify
- Test approach
- Commit message
