---
name: github-wiki
description: GitHub Wiki documentation provider — manages wiki pages via git clone of the repository wiki.
---

# GitHub Wiki Documentation Provider

## Provider Overview

This provider manages documentation through GitHub's built-in wiki feature. GitHub wikis are backed by a separate git repository (`{repo}.wiki.git`) that can be cloned, edited, and pushed like any other git repo. Pages are written in GitHub-Flavored Markdown (GFM).

This approach requires no API tokens beyond standard git authentication and gives full version control over documentation.

## Required Configuration

| Environment Variable | Description |
|---|---|
| `GITHUB_TOKEN` | GitHub personal access token or fine-grained token with repo scope (used for git push authentication) |
| `GITHUB_OWNER` | Repository owner (user or organization) |
| `GITHUB_REPO` | Repository name |

**Prerequisite**: The wiki must be enabled on the repository. Go to the repo Settings > Features > Wikis and ensure it is checked. You must also create at least one page via the GitHub UI before the wiki git repo becomes available for cloning.

### Git Authentication

```bash
git clone https://${GITHUB_TOKEN}@github.com/${GITHUB_OWNER}/${GITHUB_REPO}.wiki.git
```

Or configure credential-based auth:

```bash
git clone https://github.com/${GITHUB_OWNER}/${GITHUB_REPO}.wiki.git
# Git will prompt for credentials; use GITHUB_TOKEN as password
```

## Page Operations

### Clone Wiki Repository

```bash
git clone https://${GITHUB_TOKEN}@github.com/${GITHUB_OWNER}/${GITHUB_REPO}.wiki.git /tmp/${GITHUB_REPO}-wiki
```

### Create Page

Page filenames determine the page title. Spaces in titles become hyphens in filenames.

```bash
# Write the page content
cat > "/tmp/${GITHUB_REPO}-wiki/{Page-Title}.md" << 'CONTENT'
# Page Title

Your markdown content here.
CONTENT

# Stage, commit, and push
cd /tmp/${GITHUB_REPO}-wiki
git add "{Page-Title}.md"
git commit -m "Add {Page-Title} documentation"
git push origin master
```

### Update Page

```bash
# Edit the existing file
cat > "/tmp/${GITHUB_REPO}-wiki/{Page-Title}.md" << 'CONTENT'
# Page Title

Updated markdown content here.
CONTENT

cd /tmp/${GITHUB_REPO}-wiki
git add "{Page-Title}.md"
git commit -m "Update {Page-Title} documentation"
git push origin master
```

### Read Page

```bash
cat "/tmp/${GITHUB_REPO}-wiki/{Page-Title}.md"
```

### List All Pages

```bash
ls /tmp/${GITHUB_REPO}-wiki/*.md
```

### Delete Page

```bash
cd /tmp/${GITHUB_REPO}-wiki
git rm "{Page-Title}.md"
git commit -m "Remove {Page-Title} documentation"
git push origin master
```

### Pull Latest Changes

Always pull before editing to avoid conflicts:

```bash
cd /tmp/${GITHUB_REPO}-wiki
git pull origin master
```

## Special Pages

### Sidebar Navigation (`_Sidebar.md`)

The sidebar appears on every wiki page and provides navigation. Create or update it to maintain a table of contents.

```bash
cat > "/tmp/${GITHUB_REPO}-wiki/_Sidebar.md" << 'CONTENT'
## Navigation

- [[Home]]
- **Architecture**
  - [[System Overview]]
  - [[Component Diagrams]]
- **API Documentation**
  - [[REST API Reference]]
  - [[Data Models]]
- **Guides**
  - [[Getting Started]]
  - [[Development Setup]]
- **Sprint Reports**
  - [[Sprint 1]]
  - [[Sprint 2]]
CONTENT
```

### Footer (`_Footer.md`)

The footer appears at the bottom of every wiki page.

```bash
cat > "/tmp/${GITHUB_REPO}-wiki/_Footer.md" << 'CONTENT'
---
_Documentation maintained by the engineering team. Last updated automatically via SDLC agent._
CONTENT
```

### Home Page (`Home.md`)

The default landing page for the wiki.

```bash
cat > "/tmp/${GITHUB_REPO}-wiki/Home.md" << 'CONTENT'
# Project Documentation

Welcome to the project wiki.

## Quick Links

- [[Getting Started]]
- [[Architecture Overview]]
- [[API Reference]]
- [[Sprint Reports]]
CONTENT
```

## Formatting Notes

GitHub Wiki uses **GitHub-Flavored Markdown (GFM)** with these additional wiki-specific features:

### Wiki Links

Link to other wiki pages using double-bracket syntax:

```markdown
[[Page Title]]
[[Display Text|Page Title]]
```

### Standard GFM Features

| Feature | Syntax |
|---|---|
| Headings | `# H1` through `###### H6` |
| Bold | `**bold**` |
| Italic | `*italic*` |
| Code inline | `` `code` `` |
| Code block | Triple backticks with language |
| Links | `[text](url)` |
| Images | `![alt](url)` |
| Tables | Pipe-delimited tables |
| Task lists | `- [ ] task` / `- [x] done` |
| Blockquotes | `> quote` |
| Horizontal rule | `---` |

### Images in Wiki

Images can be added to the wiki repo and referenced locally:

```bash
# Copy image to wiki repo
cp diagram.png /tmp/${GITHUB_REPO}-wiki/images/diagram.png

# Reference in markdown
# ![Architecture Diagram](images/diagram.png)
```

## Content Templates

### Sprint Report

```markdown
# Sprint {sprint_number} Report - {date_range}

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
- [ ] {action_item} — @{owner}
```

### Architecture Document

```markdown
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

```markdown
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

## Limitations

- **No subdirectories**: GitHub wiki repos are flat. All `.md` files live at the root level. Use naming conventions (e.g., `Architecture-System-Overview.md`) to simulate hierarchy.
- **Branch support**: Wiki repos only use the `master` branch (not `main`). There is no pull request or branch workflow for wiki changes.
- **No CI/CD hooks**: GitHub wiki repos do not trigger GitHub Actions workflows. Changes cannot be validated automatically before they go live.
- **Wiki must be initialized**: The wiki git repo does not exist until at least one page has been created through the GitHub web UI.
- **Concurrent edits**: Since the wiki is a git repo, concurrent pushes from multiple agents can cause merge conflicts. Pull before editing and handle push failures.
- **Access control**: Wiki access follows the repository permissions. There is no separate access control for the wiki. Public repos have publicly readable wikis.
- **Size limits**: Individual wiki pages should stay under 1MB. The total wiki repo has no hard limit but very large repos may be slow to clone.
- **No API for wiki pages**: GitHub does not provide a REST or GraphQL API for wiki page CRUD. All operations must go through the git repo.
- **Markdown only on GitHub.com**: While the wiki repo supports other formats (AsciiDoc, reStructuredText), GitHub.com rendering is most reliable with Markdown.
