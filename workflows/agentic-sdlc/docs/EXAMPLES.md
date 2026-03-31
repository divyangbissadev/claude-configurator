# Examples

Step-by-step walkthroughs showing how the Agentic SDLC handles different prompt types.

---

## Example 1: "Build a landing page"

**Prompt**: `build landing page for an AI code assistant`
**Route**: CODE flow (full pipeline)
**Providers**: GitHub + GitHub Issues + Confluence

### Phase-by-Phase

**Phase 0 — Init**:
```
Detected: GitHub (divyangbissadev/my-project), Next.js 14, TypeScript, Tailwind
→ User confirms ✓
```

**Phase 1 — Polish** (`/prompt-optimize`):
```
Intent: FEATURE | Scope: MEDIUM
Clarifying questions:
  1. What sections? → Hero, features, pricing, testimonials, CTA
  2. Design style? → Dark theme, purple accent
  3. Any reference? → No
→ Structured spec generated → User approves ✓
```

**Phase 2 — Validate** (`/product-lens`):
```
✓ Clear need — product needs public-facing page
⚠️ Carousel adds JS complexity → User: "keep it"
→ User approves ✓
```

**Phase 3 — Brainstorm** (`/brainstorm`):
```
3 approaches: Server-only | Full client Framer | Hybrid (recommended)
→ User picks Hybrid ✓
→ spec-document-reviewer: APPROVED ✓
```

**Phase 4 — Plan** (`/blueprint` + `/writing-plans`):
```
5 blueprint steps, 13 detailed tasks
Steps 1-3 parallelizable, Step 4 depends on 1, Step 5 depends on all
→ plan-document-reviewer: APPROVED ✓
→ User approves ✓
```

**Phase 5 — Sprint Setup**:
```
Milestone: "Sprint 1 - Landing Page" (due 2 weeks)
Issues: #1 Hero, #2 Features, #3 Pricing, #4 Carousel, #5 CTA+SEO
→ User approves board ✓
```

**Phase 6 — Execute** (`/devfleet`):
```
Batch 1 (parallel): Agents A, B, C in worktrees → #1, #2, #3
  Each: /search-first → /tdd → /verification-loop → PR
  → PRs #6, #7, #8 created
  → User: "Continue" ✓

Batch 2 (sequential): Agent D → #4 (depends on #1)
  → PR #9 created → User: "Continue" ✓

Batch 3 (sequential): Agent E → #5 (depends on all)
  → PR #10 created → User: "Continue" ✓
```

**Phase 7 — Quality** (all reviewers):
```
5 PRs: all pass tests, lint, build, security
code-reviewer: 1 suggestion (extract shared Button)
→ User: "Fix suggestion" → Agent fixes → Re-review passes
→ User approves ✓
```

**Phase 8 — Merge + Retro**:
```
5 PRs squash-merged to main
Sprint report published to Confluence
CLAUDE.md updated with new components
→ User provides retro feedback ✓
```

**Result**: 5 PRs merged, 14 files, 1,247 lines, 87% coverage, Lighthouse 94.

---

## Example 2: "Document the API"

**Prompt**: `document our REST API endpoints`
**Route**: DOCS flow (Phase 4-DOCS)
**Providers**: GitHub + GitHub Issues + Confluence

### Phase-by-Phase

**Phase 0 — Init**: Detect repo, stack ✓

**Phase 1 — Polish** (`/prompt-optimize`):
```
Intent: DOCUMENTATION | Scope: MEDIUM
→ Routes to DOCS flow
→ User approves spec ✓
```

**Phase 4-DOCS — Documentation Flow** (`/sdlc-docs api`):
```
1. doc-writer scans codebase:
   - Found 12 Express routes in src/routes/
   - Found Zod schemas for request/response validation
   - Found JWT auth middleware

2. doc-writer generates API reference:
   - Endpoint table (method, path, auth, description)
   - Request/response examples per endpoint
   - Authentication guide
   - Error codes reference

3. doc-reviewer checks:
   ✅ All 12 endpoints documented
   ✅ Examples match actual Zod schemas
   ⚠️ Missing: rate limit info
   → doc-writer adds rate limit section

4. confluence-writer publishes:
   → Page created at: DEV space / API Reference
   → Code blocks use Confluence code macro
   → Table of contents auto-generated

→ User approves ✓
```

**Phase 8 — Close**: Doc published, CLAUDE.md updated.

**Result**: API doc with 12 endpoints published to Confluence.

---

## Example 3: "Fix the login bug"

**Prompt**: `users can't log in, getting 401 on the /auth/login endpoint`
**Route**: CODE flow (bug fix)
**Providers**: GitLab + Jira + Local Markdown

### Phase-by-Phase

**Phase 0 — Init**: GitLab detected, Jira configured ✓

**Phase 1 — Polish**:
```
Intent: BUG FIX | Scope: LOW
→ Spec: 401 on /auth/login, likely auth middleware issue
→ User approves ✓
```

**Phase 2 — Validate**: Skip for bugs (scope LOW) ✓

**Phase 3 — Brainstorm**: Skip for bugs (clear problem) ✓

**Phase 4 — Plan**:
```
2 tasks:
  1. Write failing test reproducing 401
  2. Fix auth middleware, verify test passes
→ User approves ✓
```

**Phase 5 — Sprint** (Jira):
```
Jira ticket PROJ-456 created in current sprint
→ User approves ✓
```

**Phase 6 — Execute**:
```
Single ticket, single agent:
  Branch: fix/PROJ-456-login-401
  /tdd → wrote test: POST /auth/login returns 200 with valid creds
  → Found: JWT secret env var missing in production config
  → Fixed: added fallback + validation
  → Test passes ✓
  MR created on GitLab
→ User approves ✓
```

**Phase 7 — Quality**:
```
Tests: ✅ | Lint: ✅ | Security: ✅ (no secrets in code)
→ User approves ✓
```

**Phase 8 — Merge**: MR merged, PROJ-456 transitioned to Done.

**Result**: 1 MR, 2 files changed, bug fixed.

---

## Example 4: Sprint Management Only

No `/sdlc` — just using `/sprint` and `/ticket` directly.

```bash
# Create a sprint
/sprint new "Q2 Auth Overhaul"

# Add tickets manually
/sprint add "Implement OAuth2 with Google"
/sprint add "Add 2FA support"
/sprint add "Migrate sessions to Redis"

# Plan all tickets
/sprint plan all

# Execute the sprint
/sprint run

# Check progress mid-sprint
/sprint status

# Work a single ticket
/ticket next

# Close when done
/sprint close
```

---

## Example 5: Mixed Code + Docs

**Prompt**: `add a webhook system and document it`
**Route**: BOTH flow (full pipeline + doc agents)

The pipeline runs the full code pipeline AND adds `doc-writer` + `doc-reviewer` to the Phase 6 team. After implementation, docs are auto-generated from the actual code and published to the docs provider.

Sprint tickets include both code and docs tickets:
```
#1  feat: Webhook event system          [feature]
#2  feat: Webhook delivery queue        [feature]
#3  feat: Webhook management API        [feature]
#4  docs: Webhook integration guide     [docs]      ← doc-writer agent
#5  docs: Webhook API reference         [docs]      ← doc-writer agent
```

Code and doc tickets execute in parallel. Doc agents read the implemented code to generate accurate documentation.
