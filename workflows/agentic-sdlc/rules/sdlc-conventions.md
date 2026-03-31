# SDLC Workflow Conventions

## Provider-Agnostic Integration

- Every piece of work MUST be tracked as a ticket in the configured ticket provider
- Every PR/MR MUST reference a ticket (Closes #N, Fixes PROJ-123, Closes AB#N)
- Sprint/milestone/iteration is the single source of truth for sprint scope
- Use labels consistently: `feature`, `bug`, `chore`, `infra`, `epic`, `docs`
- Use `in-progress` and `blocked` labels/states to track ticket status
- All provider-specific operations go through provider adapters in `providers/`

## Configuration

- Provider config stored in `.claude/sdlc-config.yml`
- Run `/sdlc-setup` to configure providers interactively
- Auto-detection falls back to git remote URL parsing
- Support: GitHub, GitLab, Azure DevOps, Bitbucket (code)
- Support: GitHub Issues, Jira, Azure Boards, GitLab Issues (tickets)
- Support: Confluence, Notion, GitHub Wiki, Local Markdown (docs)

## Branch Naming

- Features: `feat/<ticket-ref>-<short-slug>`
- Bug fixes: `fix/<ticket-ref>-<short-slug>`
- Chores: `chore/<ticket-ref>-<short-slug>`
- Documentation: `docs/<ticket-ref>-<short-slug>`

Ticket ref format adapts to provider:
- GitHub/GitLab: issue number (e.g., `42`)
- Jira: project key (e.g., `PROJ-123`)
- Azure Boards: work item ID (e.g., `42`)

## PR/MR Conventions

- Title: `<type>: <short description>` (e.g., `feat: add OAuth2 login flow`)
- Body must include: Summary, ticket reference, Test Plan
- One PR/MR per ticket — no mega-PRs covering multiple tickets
- Squash merge to keep history clean

## Sprint Rules

- Default sprint duration: 2 weeks (configurable in sdlc-config.yml)
- Sprint scope is locked after setup — new work goes to next sprint
- Carryover tickets move to next sprint, never deleted
- Sprint retrospective captures learnings after close
- Sprint reports published to configured docs provider

## Quality Gates

- All PRs must pass: tests, lint, build, security review
- No merge without fresh test evidence (run and read output)
- Code review required before merge
- TDD mandatory — tests written before implementation
- Documentation changes reviewed by doc-reviewer agent

## Documentation Rules

- Documentation prompts get a dedicated flow (doc-writer → doc-reviewer → publish)
- All docs are published to the configured docs platform
- doc-reviewer verifies accuracy against the actual codebase
- Sprint reports auto-published on sprint close
- CLAUDE.md managed by claude-md-manager agent

## Agent Dispatch Rules

- Independent tickets execute in parallel (isolated worktrees)
- Dependent tickets execute sequentially with handoff documents
- Each agent receives: ticket description, plan section, tech context
- Agent output: files changed, tests status, blockers, PR/MR link
- Doc tickets dispatched to doc-writer + doc-reviewer agents
