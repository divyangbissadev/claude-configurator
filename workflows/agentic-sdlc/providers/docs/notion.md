---
name: notion
description: Notion documentation platform provider — publishes and manages pages and databases via the Notion API.
---

# Notion Documentation Provider

## Provider Overview

This provider integrates with Notion to create, update, search, and organize documentation pages. Notion uses a block-based content model where every piece of content is a typed JSON block. Pages can live inside databases (structured collections) or as standalone pages in the workspace.

All API requests require the `Notion-Version` header and use Bearer token authentication.

## Required Configuration

| Environment Variable | Description |
|---|---|
| `NOTION_TOKEN` | Notion internal integration token (create at https://www.notion.so/my-integrations) |

Optional configuration:

| Variable | Description |
|---|---|
| `NOTION_DATABASE_ID` | Default database ID for creating documentation pages |
| `NOTION_ROOT_PAGE_ID` | Root page ID for creating standalone child pages |

**Important**: The integration must be explicitly shared with each page or database it needs to access. In Notion, open the page/database, click "..." > "Connections" > add your integration.

### Authentication Header

```
Authorization: Bearer ${NOTION_TOKEN}
Notion-Version: 2022-06-28
Content-Type: application/json
```

## Page Operations

### Create Page (in Database)

```bash
curl -s -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer ${NOTION_TOKEN}" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "parent": {
      "database_id": "{db_id}"
    },
    "properties": {
      "Name": {
        "title": [
          {
            "text": {
              "content": "{title}"
            }
          }
        ]
      }
    },
    "children": [{blocks}]
  }'
```

### Create Page (under Parent Page)

```bash
curl -s -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer ${NOTION_TOKEN}" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "parent": {
      "page_id": "{parent_page_id}"
    },
    "properties": {
      "title": {
        "title": [
          {
            "text": {
              "content": "{title}"
            }
          }
        ]
      }
    },
    "children": [{blocks}]
  }'
```

### Get Page

```bash
curl -s "https://api.notion.com/v1/pages/{page_id}" \
  -H "Authorization: Bearer ${NOTION_TOKEN}" \
  -H "Notion-Version: 2022-06-28"
```

### Get Page Content (Blocks)

```bash
curl -s "https://api.notion.com/v1/blocks/{page_id}/children?page_size=100" \
  -H "Authorization: Bearer ${NOTION_TOKEN}" \
  -H "Notion-Version: 2022-06-28"
```

### Update Block

```bash
curl -s -X PATCH "https://api.notion.com/v1/blocks/{block_id}" \
  -H "Authorization: Bearer ${NOTION_TOKEN}" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{block_content}'
```

### Append Blocks to Page

```bash
curl -s -X PATCH "https://api.notion.com/v1/blocks/{page_id}/children" \
  -H "Authorization: Bearer ${NOTION_TOKEN}" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "children": [{blocks}]
  }'
```

### Search Pages

```bash
curl -s -X POST "https://api.notion.com/v1/search" \
  -H "Authorization: Bearer ${NOTION_TOKEN}" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{query}",
    "filter": {
      "value": "page",
      "property": "object"
    },
    "sort": {
      "direction": "descending",
      "timestamp": "last_edited_time"
    }
  }'
```

### List Database Entries

```bash
curl -s -X POST "https://api.notion.com/v1/databases/{db_id}/query" \
  -H "Authorization: Bearer ${NOTION_TOKEN}" \
  -H "Notion-Version: 2022-06-28" \
  -H "Content-Type: application/json" \
  -d '{
    "sorts": [
      {
        "timestamp": "created_time",
        "direction": "descending"
      }
    ],
    "page_size": 50
  }'
```

## Formatting Notes

Notion uses a **block-based JSON format**. There is no raw HTML or markdown in the API -- every piece of content is a typed block object.

### Block Type Reference

#### Paragraph

```json
{
  "object": "block",
  "type": "paragraph",
  "paragraph": {
    "rich_text": [
      {
        "type": "text",
        "text": { "content": "Your paragraph text here." },
        "annotations": { "bold": false, "italic": false, "code": false }
      }
    ]
  }
}
```

#### Headings

```json
{
  "object": "block",
  "type": "heading_1",
  "heading_1": {
    "rich_text": [{ "type": "text", "text": { "content": "Heading 1" } }]
  }
}
```

Also available: `heading_2`, `heading_3` (same structure, different type key).

#### Code Block

```json
{
  "object": "block",
  "type": "code",
  "code": {
    "rich_text": [{ "type": "text", "text": { "content": "const x = 1;" } }],
    "language": "javascript"
  }
}
```

#### Bulleted List Item

```json
{
  "object": "block",
  "type": "bulleted_list_item",
  "bulleted_list_item": {
    "rich_text": [{ "type": "text", "text": { "content": "List item" } }]
  }
}
```

#### Numbered List Item

```json
{
  "object": "block",
  "type": "numbered_list_item",
  "numbered_list_item": {
    "rich_text": [{ "type": "text", "text": { "content": "Step one" } }]
  }
}
```

#### To-Do Item

```json
{
  "object": "block",
  "type": "to_do",
  "to_do": {
    "rich_text": [{ "type": "text", "text": { "content": "Task description" } }],
    "checked": false
  }
}
```

#### Toggle Block

```json
{
  "object": "block",
  "type": "toggle",
  "toggle": {
    "rich_text": [{ "type": "text", "text": { "content": "Click to expand" } }],
    "children": [
      {
        "object": "block",
        "type": "paragraph",
        "paragraph": {
          "rich_text": [{ "type": "text", "text": { "content": "Hidden content" } }]
        }
      }
    ]
  }
}
```

#### Callout

```json
{
  "object": "block",
  "type": "callout",
  "callout": {
    "rich_text": [{ "type": "text", "text": { "content": "Important note" } }],
    "icon": { "type": "emoji", "emoji": "!" },
    "color": "yellow_background"
  }
}
```

#### Divider

```json
{
  "object": "block",
  "type": "divider",
  "divider": {}
}
```

#### Table

```json
{
  "object": "block",
  "type": "table",
  "table": {
    "table_width": 3,
    "has_column_header": true,
    "has_row_header": false,
    "children": [
      {
        "type": "table_row",
        "table_row": {
          "cells": [
            [{ "type": "text", "text": { "content": "Header 1" } }],
            [{ "type": "text", "text": { "content": "Header 2" } }],
            [{ "type": "text", "text": { "content": "Header 3" } }]
          ]
        }
      }
    ]
  }
}
```

### Rich Text Annotations

Any `rich_text` entry can include annotations for styling:

```json
{
  "type": "text",
  "text": { "content": "bold and italic" },
  "annotations": {
    "bold": true,
    "italic": true,
    "strikethrough": false,
    "underline": false,
    "code": false,
    "color": "default"
  }
}
```

## Content Templates

### Sprint Report

```json
{
  "parent": { "database_id": "{db_id}" },
  "properties": {
    "Name": { "title": [{ "text": { "content": "Sprint {sprint_number} Report - {date_range}" } }] },
    "Status": { "select": { "name": "Published" } },
    "Type": { "select": { "name": "Sprint Report" } }
  },
  "children": [
    { "object": "block", "type": "heading_1", "heading_1": { "rich_text": [{ "type": "text", "text": { "content": "Sprint {sprint_number} Report" } }] } },
    { "object": "block", "type": "callout", "callout": { "rich_text": [{ "type": "text", "text": { "content": "Sprint Goal: {sprint_goal}" } }], "icon": { "type": "emoji", "emoji": "target" }, "color": "blue_background" } },
    { "object": "block", "type": "heading_2", "heading_2": { "rich_text": [{ "type": "text", "text": { "content": "Completed Items" } }] } },
    { "object": "block", "type": "to_do", "to_do": { "rich_text": [{ "type": "text", "text": { "content": "{ticket_id}: {ticket_title}" } }], "checked": true } },
    { "object": "block", "type": "heading_2", "heading_2": { "rich_text": [{ "type": "text", "text": { "content": "Carried Over" } }] } },
    { "object": "block", "type": "to_do", "to_do": { "rich_text": [{ "type": "text", "text": { "content": "{ticket_id}: {ticket_title} - {reason}" } }], "checked": false } },
    { "object": "block", "type": "heading_2", "heading_2": { "rich_text": [{ "type": "text", "text": { "content": "Metrics" } }] } },
    { "object": "block", "type": "bulleted_list_item", "bulleted_list_item": { "rich_text": [{ "type": "text", "text": { "content": "Velocity: {velocity} points" } }] } },
    { "object": "block", "type": "bulleted_list_item", "bulleted_list_item": { "rich_text": [{ "type": "text", "text": { "content": "Planned: {planned} | Completed: {completed}" } }] } },
    { "object": "block", "type": "heading_2", "heading_2": { "rich_text": [{ "type": "text", "text": { "content": "Retrospective" } }] } },
    { "object": "block", "type": "paragraph", "paragraph": { "rich_text": [{ "type": "text", "text": { "content": "{retro_notes}" } }] } }
  ]
}
```

### Architecture Document

```json
{
  "parent": { "database_id": "{db_id}" },
  "properties": {
    "Name": { "title": [{ "text": { "content": "Architecture: {component_name}" } }] },
    "Type": { "select": { "name": "Architecture" } }
  },
  "children": [
    { "object": "block", "type": "callout", "callout": { "rich_text": [{ "type": "text", "text": { "content": "Owner: {owner} | Status: {status} | Last Updated: {date}" } }], "icon": { "type": "emoji", "emoji": "building_construction" }, "color": "gray_background" } },
    { "object": "block", "type": "heading_2", "heading_2": { "rich_text": [{ "type": "text", "text": { "content": "Overview" } }] } },
    { "object": "block", "type": "paragraph", "paragraph": { "rich_text": [{ "type": "text", "text": { "content": "{overview}" } }] } },
    { "object": "block", "type": "heading_2", "heading_2": { "rich_text": [{ "type": "text", "text": { "content": "Context & Problem Statement" } }] } },
    { "object": "block", "type": "paragraph", "paragraph": { "rich_text": [{ "type": "text", "text": { "content": "{problem_statement}" } }] } },
    { "object": "block", "type": "heading_2", "heading_2": { "rich_text": [{ "type": "text", "text": { "content": "Decision" } }] } },
    { "object": "block", "type": "paragraph", "paragraph": { "rich_text": [{ "type": "text", "text": { "content": "{decision}" } }] } },
    { "object": "block", "type": "heading_2", "heading_2": { "rich_text": [{ "type": "text", "text": { "content": "Components" } }] } },
    { "object": "block", "type": "bulleted_list_item", "bulleted_list_item": { "rich_text": [{ "type": "text", "text": { "content": "{component_1}: {description_1}" }, "annotations": { "bold": true } }] } },
    { "object": "block", "type": "heading_2", "heading_2": { "rich_text": [{ "type": "text", "text": { "content": "Dependencies" } }] } },
    { "object": "block", "type": "paragraph", "paragraph": { "rich_text": [{ "type": "text", "text": { "content": "{dependencies_description}" } }] } },
    { "object": "block", "type": "heading_2", "heading_2": { "rich_text": [{ "type": "text", "text": { "content": "Risks & Mitigations" } }] } },
    { "object": "block", "type": "paragraph", "paragraph": { "rich_text": [{ "type": "text", "text": { "content": "{risks_description}" } }] } }
  ]
}
```

### API Documentation

```json
{
  "parent": { "database_id": "{db_id}" },
  "properties": {
    "Name": { "title": [{ "text": { "content": "API: {api_name}" } }] },
    "Type": { "select": { "name": "API Doc" } }
  },
  "children": [
    { "object": "block", "type": "callout", "callout": { "rich_text": [{ "type": "text", "text": { "content": "Base URL: {base_url} | Version: {version}" } }], "icon": { "type": "emoji", "emoji": "electric_plug" }, "color": "purple_background" } },
    { "object": "block", "type": "heading_2", "heading_2": { "rich_text": [{ "type": "text", "text": { "content": "Authentication" } }] } },
    { "object": "block", "type": "paragraph", "paragraph": { "rich_text": [{ "type": "text", "text": { "content": "{auth_description}" } }] } },
    { "object": "block", "type": "heading_2", "heading_2": { "rich_text": [{ "type": "text", "text": { "content": "{method} {endpoint_path}" } }] } },
    { "object": "block", "type": "paragraph", "paragraph": { "rich_text": [{ "type": "text", "text": { "content": "{endpoint_description}" } }] } },
    { "object": "block", "type": "heading_3", "heading_3": { "rich_text": [{ "type": "text", "text": { "content": "Request" } }] } },
    { "object": "block", "type": "code", "code": { "rich_text": [{ "type": "text", "text": { "content": "{request_body_example}" } }], "language": "json" } },
    { "object": "block", "type": "heading_3", "heading_3": { "rich_text": [{ "type": "text", "text": { "content": "Response" } }] } },
    { "object": "block", "type": "code", "code": { "rich_text": [{ "type": "text", "text": { "content": "{response_body_example}" } }], "language": "json" } }
  ]
}
```

## Limitations

- **Block nesting depth**: Notion API supports a maximum of 2 levels of nested blocks (e.g., a toggle containing a list). Deeper nesting requires multiple append calls.
- **Rich text length**: Each rich text object has a maximum of 2000 characters. Longer text must be split across multiple rich text entries.
- **Rate limiting**: Notion API enforces a rate limit of 3 requests per second per integration. Implement exponential backoff on 429 responses.
- **Block limit per request**: A single API call can include a maximum of 100 blocks in the `children` array.
- **No markdown input**: The API does not accept raw markdown. All content must be converted to Notion block format.
- **Search limitations**: The search endpoint performs a basic text search and does not support advanced filtering by content within blocks. It only matches page titles and database properties.
- **Integration sharing**: The integration must be manually shared with each top-level page or database. Child pages inherit access from their parent.
- **No bulk update**: There is no batch update endpoint. Each block must be updated individually, which can be slow for large documents.
- **Image blocks**: Images must be externally hosted URLs or uploaded via a separate file upload flow. The API does not accept base64-encoded images inline.
- **Page property types**: Database page properties must match the schema defined in the database. Creating pages with undefined properties will fail.
