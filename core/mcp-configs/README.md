# MCP Server Configurations

Pre-configured Model Context Protocol (MCP) server integrations.

## Usage

Copy the relevant config to your project's `.claude/` directory and update
credentials/URLs for your environment.

## Available Configs

| Config | Service | Purpose |
|--------|---------|---------|
| `github.json` | GitHub API | PR management, issue tracking |
| `azure-devops.json` | Azure DevOps | Work items, repos, pipelines |

## Adding to Your Pod

In `claude-pod.yml`, MCP configs are not auto-copied. Manually copy and
customize from `.claude-configurator/core/mcp-configs/` to `.claude/`.
