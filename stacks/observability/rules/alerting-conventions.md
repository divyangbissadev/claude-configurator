# Alerting Conventions

## Alert Naming
- Use PascalCase for alert names (e.g., `HighErrorRate`, `PodCrashLooping`).
- Prefix with service or component name: `PaymentServiceHighLatency`.
- Be specific and descriptive — the name should convey what is wrong.

## Severity Levels
- **critical**: Immediate customer impact requiring page. Response time: 5 minutes.
- **warning**: Degraded service or approaching thresholds. Response time: 30 minutes.
- **info**: Notable events for awareness. No immediate action required.

## Required Labels
- `severity`: One of `critical`, `warning`, `info`.
- `team`: Owning team for routing (e.g., `platform`, `payments`, `infra`).
- `service`: The affected service name.

## Required Annotations
- `summary`: One-line human-readable description with template variables.
- `description`: Detailed explanation including current value and threshold.
- `runbook_url`: Link to the runbook with investigation and remediation steps.

## Routing Rules
- `critical` alerts route to PagerDuty with 5-minute repeat interval.
- `warning` alerts route to team Slack channel with 30-minute repeat interval.
- `info` alerts route to observability Slack channel, no repeat.

## Thresholds
- Base thresholds on historical data (p95, p99), not arbitrary values.
- Use `for` duration of at least 5 minutes for warning, 2 minutes for critical.
- Implement multi-window burn rate alerting for SLO-based alerts.

## Anti-patterns
- No alerts that fire more than once per day on average (alert fatigue).
- No alerts without a clear remediation action.
- No alerts on symptoms only — always include cause-oriented alerts.
