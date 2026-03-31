---
name: confluence
description: Atlassian Confluence documentation platform provider — publishes and manages pages via the Confluence REST API v2.
---

# Confluence Documentation Provider

## Provider Overview

This provider integrates with Atlassian Confluence Cloud (or Data Center) to create, update, search, and organize documentation pages. It uses the Confluence REST API v2 for page operations and the v1 CQL search endpoint for queries.

All content must be in **Confluence Storage Format** (an XHTML-based markup), so markdown output from agents must be converted before publishing.

## Required Configuration

| Environment Variable | Description |
|---|---|
| `CONFLUENCE_HOST` | Your Confluence instance hostname (e.g., `your-domain.atlassian.net`) |
| `CONFLUENCE_EMAIL` | Email address of the API user |
| `CONFLUENCE_TOKEN` | Atlassian API token (generate at https://id.atlassian.com/manage-profile/security/api-tokens) |

All API requests use Basic Auth:

```
Authorization: Basic $(echo -n "$CONFLUENCE_EMAIL:$CONFLUENCE_TOKEN" | base64)
```

Optional configuration:

| Variable | Description |
|---|---|
| `CONFLUENCE_SPACE_KEY` | Default space key for page operations |
| `CONFLUENCE_SPACE_ID` | Default space ID (numeric) for v2 API calls |
| `CONFLUENCE_PARENT_PAGE_ID` | Default parent page for new pages |

### Atlassian Plugin (Native Integration)

If the `@atlassian/confluence-mcp` or equivalent MCP server is available, prefer using it for native integration instead of raw REST calls. The MCP server handles authentication and provides higher-level operations. Check for its availability before falling back to curl-based API calls.

## Page Operations

### Create Page

```bash
curl -s -X POST \
  "https://${CONFLUENCE_HOST}/wiki/api/v2/pages" \
  -H "Authorization: Basic $(echo -n "${CONFLUENCE_EMAIL}:${CONFLUENCE_TOKEN}" | base64)" \
  -H "Content-Type: application/json" \
  -d '{
    "spaceId": "{space_id}",
    "status": "current",
    "title": "{title}",
    "parentId": "{parent_page_id}",
    "body": {
      "representation": "storage",
      "value": "{html_content}"
    }
  }'
```

### Update Page

To update a page you must supply the current version number incremented by 1. First fetch the page to get the current version, then update.

```bash
# Step 1: Get current version
CURRENT_VERSION=$(curl -s \
  "https://${CONFLUENCE_HOST}/wiki/api/v2/pages/{page_id}" \
  -H "Authorization: Basic $(echo -n "${CONFLUENCE_EMAIL}:${CONFLUENCE_TOKEN}" | base64)" \
  | jq '.version.number')

# Step 2: Update with incremented version
curl -s -X PUT \
  "https://${CONFLUENCE_HOST}/wiki/api/v2/pages/{page_id}" \
  -H "Authorization: Basic $(echo -n "${CONFLUENCE_EMAIL}:${CONFLUENCE_TOKEN}" | base64)" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "{page_id}",
    "status": "current",
    "title": "{title}",
    "body": {
      "representation": "storage",
      "value": "{html_content}"
    },
    "version": {
      "number": {version+1},
      "message": "{update_message}"
    }
  }'
```

### Get Page

```bash
curl -s \
  "https://${CONFLUENCE_HOST}/wiki/api/v2/pages/{page_id}?body-format=storage" \
  -H "Authorization: Basic $(echo -n "${CONFLUENCE_EMAIL}:${CONFLUENCE_TOKEN}" | base64)"
```

### Search Pages

```bash
curl -s \
  "https://${CONFLUENCE_HOST}/wiki/rest/api/content/search?cql=space=\"{space}\" AND type=\"page\" AND title~\"{query}\"" \
  -H "Authorization: Basic $(echo -n "${CONFLUENCE_EMAIL}:${CONFLUENCE_TOKEN}" | base64)"
```

### List Pages in Space

```bash
curl -s \
  "https://${CONFLUENCE_HOST}/wiki/api/v2/spaces/{space_id}/pages?limit=50" \
  -H "Authorization: Basic $(echo -n "${CONFLUENCE_EMAIL}:${CONFLUENCE_TOKEN}" | base64)"
```

## Page Hierarchy

Confluence organizes content in a tree structure. Every page can have a parent page and child pages.

### Setting a Parent Page

Include `"parentId": "{parent_page_id}"` in the create request body to nest a page under a parent.

### Getting Child Pages

```bash
curl -s \
  "https://${CONFLUENCE_HOST}/wiki/api/v2/pages/{parent_page_id}/children?limit=50" \
  -H "Authorization: Basic $(echo -n "${CONFLUENCE_EMAIL}:${CONFLUENCE_TOKEN}" | base64)"
```

### Recommended Hierarchy

```
Project Root Page
  ├── Architecture
  │     ├── System Overview
  │     ├── Component Diagrams
  │     └── ADRs
  ├── API Documentation
  │     ├── REST Endpoints
  │     └── Data Models
  ├── Sprint Reports
  │     ├── Sprint 1
  │     └── Sprint 2
  └── Meeting Notes
        ├── 2026-03-31 Standup
        └── 2026-03-30 Retro
```

## Formatting Notes

Confluence uses **Storage Format**, an XHTML-based markup. You must convert markdown to storage format before publishing.

### Key Conversions

| Markdown | Confluence Storage Format |
|---|---|
| `# Heading 1` | `<h1>Heading 1</h1>` |
| `**bold**` | `<strong>bold</strong>` |
| `*italic*` | `<em>italic</em>` |
| `` `code` `` | `<code>code</code>` |
| Code block | `<ac:structured-macro ac:name="code"><ac:plain-text-body><![CDATA[...]]></ac:plain-text-body></ac:structured-macro>` |
| `- item` | `<ul><li>item</li></ul>` |
| `[text](url)` | `<a href="url">text</a>` |
| Table | Standard `<table><tr><th>/<td>` HTML |
| Info panel | `<ac:structured-macro ac:name="info"><ac:rich-text-body>...</ac:rich-text-body></ac:structured-macro>` |
| Warning panel | `<ac:structured-macro ac:name="warning"><ac:rich-text-body>...</ac:rich-text-body></ac:structured-macro>` |

### Status Macro

```xml
<ac:structured-macro ac:name="status">
  <ac:parameter ac:name="colour">Green</ac:parameter>
  <ac:parameter ac:name="title">DONE</ac:parameter>
</ac:structured-macro>
```

## Content Templates

### Sprint Report

```json
{
  "title": "Sprint {sprint_number} Report - {date_range}",
  "body": {
    "representation": "storage",
    "value": "<h1>Sprint {sprint_number} Report</h1><p><strong>Date:</strong> {date_range}</p><h2>Sprint Goal</h2><p>{sprint_goal}</p><h2>Completed Items</h2><table><tr><th>Ticket</th><th>Title</th><th>Points</th><th>Status</th></tr><tr><td>{ticket_id}</td><td>{ticket_title}</td><td>{points}</td><td><ac:structured-macro ac:name=\"status\"><ac:parameter ac:name=\"colour\">Green</ac:parameter><ac:parameter ac:name=\"title\">DONE</ac:parameter></ac:structured-macro></td></tr></table><h2>Carried Over</h2><table><tr><th>Ticket</th><th>Title</th><th>Reason</th></tr></table><h2>Metrics</h2><ul><li>Velocity: {velocity} points</li><li>Planned: {planned} | Completed: {completed}</li><li>Bugs found: {bugs_found} | Bugs fixed: {bugs_fixed}</li></ul><h2>Retrospective Notes</h2><p>{retro_notes}</p>"
  }
}
```

### Architecture Document

```json
{
  "title": "Architecture: {component_name}",
  "body": {
    "representation": "storage",
    "value": "<h1>Architecture: {component_name}</h1><ac:structured-macro ac:name=\"info\"><ac:rich-text-body><p><strong>Last Updated:</strong> {date} | <strong>Owner:</strong> {owner} | <strong>Status:</strong> {status}</p></ac:rich-text-body></ac:structured-macro><h2>Overview</h2><p>{overview}</p><h2>Context &amp; Problem Statement</h2><p>{problem_statement}</p><h2>Decision</h2><p>{decision}</p><h2>Components</h2><ul><li><strong>{component_1}:</strong> {description_1}</li><li><strong>{component_2}:</strong> {description_2}</li></ul><h2>Data Flow</h2><p>{data_flow_description}</p><h2>Dependencies</h2><table><tr><th>Service</th><th>Purpose</th><th>SLA</th></tr><tr><td>{service}</td><td>{purpose}</td><td>{sla}</td></tr></table><h2>Non-Functional Requirements</h2><ul><li>Latency: {latency_target}</li><li>Throughput: {throughput_target}</li><li>Availability: {availability_target}</li></ul><h2>Risks &amp; Mitigations</h2><table><tr><th>Risk</th><th>Impact</th><th>Mitigation</th></tr></table>"
  }
}
```

### API Documentation

```json
{
  "title": "API: {api_name}",
  "body": {
    "representation": "storage",
    "value": "<h1>API: {api_name}</h1><p><strong>Base URL:</strong> <code>{base_url}</code></p><p><strong>Version:</strong> {version}</p><h2>Authentication</h2><p>{auth_description}</p><h2>Endpoints</h2><h3>{method} {endpoint_path}</h3><p>{endpoint_description}</p><h4>Request</h4><ac:structured-macro ac:name=\"code\"><ac:parameter ac:name=\"language\">json</ac:parameter><ac:plain-text-body><![CDATA[{request_body_example}]]></ac:plain-text-body></ac:structured-macro><h4>Response</h4><ac:structured-macro ac:name=\"code\"><ac:parameter ac:name=\"language\">json</ac:parameter><ac:plain-text-body><![CDATA[{response_body_example}]]></ac:plain-text-body></ac:structured-macro><h4>Error Codes</h4><table><tr><th>Code</th><th>Description</th></tr><tr><td>{error_code}</td><td>{error_description}</td></tr></table>"
  }
}
```

### Meeting Notes

```json
{
  "title": "Meeting Notes: {meeting_title} - {date}",
  "body": {
    "representation": "storage",
    "value": "<h1>{meeting_title}</h1><p><strong>Date:</strong> {date} | <strong>Attendees:</strong> {attendees}</p><h2>Agenda</h2><ol><li>{agenda_item_1}</li><li>{agenda_item_2}</li></ol><h2>Discussion</h2><p>{discussion_notes}</p><h2>Decisions</h2><ul><li>{decision_1}</li><li>{decision_2}</li></ul><h2>Action Items</h2><table><tr><th>Action</th><th>Owner</th><th>Due Date</th></tr><tr><td>{action}</td><td>{owner}</td><td>{due_date}</td></tr></table><h2>Next Meeting</h2><p>{next_meeting_details}</p>"
  }
}
```

## Limitations

- **Storage format required**: All content must be converted from markdown to Confluence Storage Format (XHTML-based). There is no native markdown support in the API.
- **Rate limiting**: Confluence Cloud enforces rate limits. Batch operations should include delays between requests. Typical limit is ~100 requests per minute.
- **Version conflicts**: Every update requires the correct version number. Concurrent edits will fail if versions collide.
- **Content size**: Individual pages have a practical limit of ~1MB of storage format content.
- **API token scope**: API tokens inherit the permissions of the user who created them. Ensure the user has write access to the target space.
- **Attachment handling**: Attachments (images, files) require separate API calls and cannot be inlined in the page creation request.
- **Macro rendering**: Complex Confluence macros (Jira issues, draw.io diagrams) require specific macro syntax and may not render in API previews.
- **No markdown round-trip**: Converting storage format back to clean markdown is lossy. Prefer storing the source markdown separately if round-trip fidelity is needed.
