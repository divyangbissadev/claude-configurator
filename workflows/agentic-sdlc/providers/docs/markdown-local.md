---
name: markdown-local
description: Local markdown documentation provider — writes docs directly to the repository's docs/ directory. Default fallback when no external platform is configured.
---

# Local Markdown Documentation Provider

## Provider Overview

This is the **default documentation provider** used when no external documentation platform (Confluence, Notion, GitHub Wiki) is configured. It writes documentation as markdown files directly into the repository's `docs/` directory.

This approach keeps documentation co-located with the code, versioned in the same git history, and reviewable through pull requests. It requires no external services, API tokens, or additional setup.

## Required Configuration

No environment variables or external services are required. This provider works out of the box.

| Setting | Default | Description |
|---|---|---|
| `DOCS_ROOT` | `docs/` | Root directory for documentation (relative to repo root) |
| `DOCS_INDEX` | `docs/README.md` | Table of contents / index file |

The only prerequisite is that the agent has write access to the repository.

## Directory Structure

```
docs/
  README.md              # Table of contents / index
  architecture/          # System design and architecture decisions
    overview.md
    components.md
    adrs/
      001-database-choice.md
      002-auth-strategy.md
  api/                   # API reference documentation
    rest-endpoints.md
    data-models.md
    error-codes.md
  guides/                # How-to guides and tutorials
    getting-started.md
    development-setup.md
    deployment.md
  sprints/               # Sprint reports and planning docs
    sprint-001.md
    sprint-002.md
```

## Page Operations

### Create Page

```bash
# Ensure directory exists
mkdir -p docs/{category}

# Write the page
cat > "docs/{category}/{filename}.md" << 'CONTENT'
# {Title}

{content}
CONTENT
```

### Read Page

```bash
cat "docs/{category}/{filename}.md"
```

### Update Page

```bash
# Overwrite with updated content
cat > "docs/{category}/{filename}.md" << 'CONTENT'
# {Title}

{updated_content}
CONTENT
```

### List All Pages

```bash
find docs/ -name "*.md" -type f | sort
```

### List Pages by Category

```bash
ls docs/architecture/*.md
ls docs/api/*.md
ls docs/guides/*.md
ls docs/sprints/*.md
```

### Search Pages

```bash
grep -rl "{query}" docs/
```

### Update Index

After creating or removing pages, regenerate the table of contents:

```bash
cat > "docs/README.md" << 'CONTENT'
# Project Documentation

## Architecture
- [System Overview](architecture/overview.md)
- [Components](architecture/components.md)

## API Reference
- [REST Endpoints](api/rest-endpoints.md)
- [Data Models](api/data-models.md)

## Guides
- [Getting Started](guides/getting-started.md)
- [Development Setup](guides/development-setup.md)

## Sprint Reports
- [Sprint 1](sprints/sprint-001.md)
- [Sprint 2](sprints/sprint-002.md)
CONTENT
```

### Commit Documentation Changes

```bash
git add docs/
git commit -m "docs: {description_of_changes}"
git push origin {branch}
```

## Formatting Notes

Uses **standard Markdown** with **GitHub-Flavored Markdown (GFM)** extensions when the repo is hosted on GitHub.

### Supported Syntax

| Feature | Syntax |
|---|---|
| Headings | `# H1` through `###### H6` |
| Bold | `**bold**` |
| Italic | `*italic*` |
| Code inline | `` `code` `` |
| Code block | Triple backticks with optional language |
| Links | `[text](relative/path.md)` or `[text](https://url)` |
| Images | `![alt](images/diagram.png)` |
| Tables | Pipe-delimited GFM tables |
| Task lists | `- [ ] task` / `- [x] done` |
| Blockquotes | `> quote` |
| Horizontal rule | `---` |
| Footnotes | `[^1]` with `[^1]: definition` |

### Relative Links

Always use relative links between doc files so they work both on GitHub and locally:

```markdown
See the [Architecture Overview](../architecture/overview.md) for details.
```

### Images

Store images in a dedicated directory:

```
docs/
  images/
    architecture-diagram.png
    data-flow.png
```

Reference them with relative paths:

```markdown
![Architecture Diagram](../images/architecture-diagram.png)
```

### Frontmatter (Optional)

Pages can include YAML frontmatter for metadata. This is useful if docs are later processed by a static site generator (Jekyll, Hugo, MkDocs, etc.):

```yaml
---
title: System Overview
author: engineering-team
date: 2026-03-31
tags: [architecture, system-design]
---
```

## Content Templates

### Sprint Report

File: `docs/sprints/sprint-{number}.md`

```markdown
---
title: Sprint {sprint_number} Report
date: {date_range}
---

# Sprint {sprint_number} Report

**Date:** {date_range}
**Sprint Goal:** {sprint_goal}

## Completed Items

| Ticket | Title | Points | Status |
|--------|-------|--------|--------|
| {ticket_id} | {ticket_title} | {points} | Done |

## Carried Over

| Ticket | Title | Reason |
|--------|-------|--------|
| {ticket_id} | {ticket_title} | {reason} |

## Metrics

- **Velocity:** {velocity} points
- **Planned:** {planned} | **Completed:** {completed}
- **Bugs Found:** {bugs_found} | **Bugs Fixed:** {bugs_fixed}

## Retrospective

### What went well
- {positive_item}

### What could improve
- {improvement_item}

### Action items
- [ ] {action_item} -- @{owner}
```

### Architecture Document

File: `docs/architecture/{component-name}.md`

```markdown
---
title: "Architecture: {component_name}"
author: {owner}
date: {date}
status: {status}
---

# Architecture: {component_name}

> **Owner:** {owner} | **Status:** {status} | **Last Updated:** {date}

## Overview

{overview}

## Context & Problem Statement

{problem_statement}

## Decision

{decision}

## Components

| Component | Responsibility | Tech Stack |
|-----------|---------------|------------|
| {component_1} | {description_1} | {tech_1} |
| {component_2} | {description_2} | {tech_2} |

## Data Flow

{data_flow_description}

## Dependencies

| Service | Purpose | SLA |
|---------|---------|-----|
| {service} | {purpose} | {sla} |

## Non-Functional Requirements

- **Latency:** {latency_target}
- **Throughput:** {throughput_target}
- **Availability:** {availability_target}

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| {risk} | {impact} | {mitigation} |
```

### API Documentation

File: `docs/api/{api-name}.md`

```markdown
---
title: "API: {api_name}"
version: {version}
---

# API: {api_name}

**Base URL:** `{base_url}`
**Version:** {version}

## Authentication

{auth_description}

## Endpoints

### {method} `{endpoint_path}`

{endpoint_description}

**Request:**

```json
{request_body_example}
```

**Response:**

```json
{response_body_example}
```

**Error Codes:**

| Code | Description |
|------|-------------|
| {error_code} | {error_description} |
```

### Architecture Decision Record (ADR)

File: `docs/architecture/adrs/{number}-{slug}.md`

```markdown
---
title: "ADR-{number}: {title}"
date: {date}
status: Accepted | Proposed | Deprecated | Superseded
---

# ADR-{number}: {title}

## Status

{status}

## Context

{context}

## Decision

{decision}

## Consequences

### Positive
- {positive_consequence}

### Negative
- {negative_consequence}

## Alternatives Considered

| Alternative | Pros | Cons |
|-------------|------|------|
| {alternative} | {pros} | {cons} |
```

## Limitations

- **No collaboration features**: Unlike Confluence or Notion, local markdown has no built-in commenting, inline discussions, or real-time collaboration. Use pull request reviews for feedback.
- **No rich embeds**: Cannot embed dynamic content like Jira tickets, live dashboards, or interactive diagrams. Use static images or links instead.
- **No search UI**: There is no built-in search interface. Search relies on `grep`, IDE search, or GitHub's code search when hosted there.
- **No access control**: Documentation visibility matches the repository visibility. There is no per-page or per-section access control.
- **Manual index maintenance**: The table of contents (`docs/README.md`) must be manually updated when pages are added or removed. Consider using a script or agent step to auto-generate it.
- **Rendering depends on host**: Markdown rendering varies between GitHub, GitLab, Bitbucket, and local editors. Stick to standard GFM to maximize compatibility.
- **No versioned publishing**: There is no concept of "published" vs "draft" states. All committed content is immediately visible. Use branches for draft documentation.
- **Image management**: Images must be committed to the repository, which increases repo size. Consider using Git LFS for large image assets.
- **No notification system**: Unlike wiki platforms, there are no built-in notifications when documentation changes. Rely on git log or CI notifications.
