---
paths:
  - "**/*"
---

# JIRA Tracking Conventions

- Branch names should include the JIRA ticket: `feature/PR-557-description`
- Commit messages must start with the ticket ID: `PR-557: Add schema guard`
- Link sessions to tickets with `/jira-link` if the branch doesn't contain a ticket ID
- Review `/jira-time` weekly to ensure all sessions are attributed
- Push time to JIRA with `/jira-log-time` before sprint reviews
- Unlinked sessions are wasted tracking data — aim for 0% unlinked time
