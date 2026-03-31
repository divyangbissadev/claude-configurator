---
description: "Documentation flow — write, review, and publish technical docs to your configured platform (Confluence, Notion, Wiki, or local)."
---

# SDLC Documentation Flow

Dedicated documentation pipeline. Takes a topic or requirement, generates technical documentation, reviews it for accuracy, and publishes to your configured docs platform.

## Input

`$ARGUMENTS`

Accepted formats:
- `"Architecture overview"` — write docs on a topic
- `sprint-report` — generate report for current/last sprint
- `api` — generate API documentation from code
- `onboarding` — generate developer onboarding guide
- `adr "Decision Title"` — create an Architecture Decision Record
- `review <path>` — review existing documentation for accuracy
- `publish <path>` — publish local markdown to configured docs platform
- `claude-md` — generate or update CLAUDE.md for the project

---

## PROVIDER LOADING

```bash
cat .claude/sdlc-config.yml 2>/dev/null
```

Read `providers.docs` to determine target platform.
Load the corresponding adapter from `providers/docs/`.

---

## DOCUMENTATION TYPES

### `sdlc-docs "Topic"` — Write Documentation

1. **Analyze request** — determine doc type:
   - Architecture doc (system design, components, data flow)
   - API doc (endpoints, schemas, auth, examples)
   - Guide/Tutorial (step-by-step instructions)
   - Runbook (operational procedures)
   - README (project overview)

2. **Dispatch doc-writer agent**:
   - Reads the codebase for context
   - Reads existing docs for voice/style consistency
   - Generates the document in the target format

3. **Dispatch doc-reviewer agent**:
   - Verifies code examples against actual codebase
   - Checks file paths and references exist
   - Validates completeness
   - Returns APPROVED or NEEDS REVISION

4. **If revision needed**: doc-writer fixes issues, reviewer re-checks

5. **Publish to configured provider**:
   - **Confluence**: Dispatch confluence-writer agent → creates/updates page
   - **Notion**: Use Notion API to create page with blocks
   - **GitHub Wiki**: Write markdown, push to wiki repo
   - **Local markdown**: Write to `docs/` directory

6. **Report**: Show the user what was created and where

### `sdlc-docs sprint-report` — Sprint Report

1. Load current/last sprint from ticket provider
2. Gather metrics: tickets planned/completed, PRs merged, velocity
3. Dispatch doc-writer agent with sprint data
4. Generate report with:
   - Summary stats
   - Completed items table
   - Carryover items
   - Velocity trends
   - Retrospective notes
5. Publish to docs provider
6. Link from sprint milestone/ticket

### `sdlc-docs api` — API Documentation

1. Scan codebase for:
   - Route definitions (Express, FastAPI, Django, Spring, etc.)
   - Request/response types and schemas
   - Auth middleware
   - OpenAPI/Swagger specs if present
2. Dispatch doc-writer agent to generate:
   - Endpoint reference table
   - Request/response examples
   - Authentication guide
   - Error codes
3. Review with doc-reviewer
4. Publish to docs provider

### `sdlc-docs onboarding` — Developer Onboarding Guide

1. Analyze the full codebase:
   - Tech stack, frameworks, languages
   - Project structure and key directories
   - Build, test, run commands
   - Environment setup requirements
   - Key architectural patterns
2. Dispatch doc-writer agent to create:
   - Prerequisites and setup guide
   - Architecture overview with diagram
   - Key concepts and patterns
   - Common tasks walkthrough
   - Troubleshooting FAQ
3. Review and publish

### `sdlc-docs adr "Title"` — Architecture Decision Record

1. Ask user for:
   - Context (what's the situation?)
   - Decision (what are we doing?)
   - Alternatives considered
   - Consequences (what changes?)
2. Generate ADR with:
   - Status: Proposed | Accepted | Deprecated | Superseded
   - Numbered (ADR-NNN) based on existing ADRs
3. Publish to docs provider
4. If Confluence: use status macros and structured format

### `sdlc-docs review <path>` — Review Existing Docs

1. Read the document at the given path
2. Dispatch doc-reviewer agent:
   - Check accuracy against current codebase
   - Flag stale references
   - Check completeness
   - Verify code examples
3. Output review report with APPROVED / NEEDS REVISION

### `sdlc-docs publish <path>` — Publish to Docs Platform

1. Read the local markdown file
2. Convert to target format:
   - Confluence: markdown → storage format (XHTML)
   - Notion: markdown → Notion blocks
   - GitHub Wiki: copy as-is
3. Create or update the page on the platform
4. Report the published URL/location

### `sdlc-docs claude-md` — Manage CLAUDE.md

1. Dispatch claude-md-manager agent
2. Agent analyzes codebase and existing CLAUDE.md
3. Generates or updates CLAUDE.md with:
   - Project overview and tech stack
   - Build/test/run commands
   - Development conventions
   - Available SDLC commands
   - Key files and architecture notes
4. Preserves any manually written sections

---

## EXAMPLES

```
/sdlc-docs "Architecture overview of the auth system"
/sdlc-docs sprint-report
/sdlc-docs api
/sdlc-docs onboarding
/sdlc-docs adr "Switch from REST to GraphQL"
/sdlc-docs review docs/architecture.md
/sdlc-docs publish docs/api-reference.md
/sdlc-docs claude-md
```
