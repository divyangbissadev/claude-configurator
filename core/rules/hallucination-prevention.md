---
paths:
  - "**/*"
---

# Hallucination Prevention Rules

## Before Referencing Any File
- VERIFY the file exists before referencing it: use Glob or Read
- Never say "this file should be at X" — check if it IS at X
- If you read a file in a previous turn, it may have changed — re-read if acting on its content

## Before Referencing Any Function/Class/Method
- VERIFY it exists in the current code: use Grep
- Never assume a function exists because it "should" based on the class name
- Never assume method signatures — read the actual definition

## Before Claiming a Feature Exists
- VERIFY by reading the implementation, not by inferring from names
- "The codebase has X" requires evidence: file path + line number
- "This function does X" requires reading the function, not guessing from the name

## Before Stating API Behavior
- VERIFY by reading the actual endpoint/handler code
- Never fabricate request/response schemas — read them from code or tests
- If you haven't read the code, say "I haven't verified this yet"

## Before Using Training Knowledge
- Codebase-specific claims MUST be verified against actual code
- Framework knowledge (e.g., "Spring does X") is acceptable for well-known patterns
- Custom implementations may deviate from standard patterns — always check

## When Uncertain
- Say "I'm not sure" rather than guessing
- Say "Let me verify" and then actually verify
- Prefix uncertain claims with "I believe" or "Based on the pattern, I expect"
- Never present uncertainty as certainty

## Evidence Requirements
- Every factual claim about the codebase must have a source:
  - File reference: `path/to/file.py:42`
  - Command output: "I ran `make test` and got..."
  - Git history: "According to `git log`, this was changed in commit..."
- Claims without evidence should be flagged by reviewers
