# Observability Stack — Anti-patterns and Guidelines

## Anti-patterns

- No high-cardinality labels in metrics (user IDs, request IDs). Use exemplars instead.
- No unbounded trace spans — always set timeouts on spans to prevent resource leaks.
- No missing `service.name` in OTel resource attributes. Every service must be identifiable.
- No alert without a runbook link. Every alert must reference a runbook for on-call engineers.
- No dashboard without SLO/SLI reference. Dashboards must tie back to service level objectives.

## Required Practices

- Always propagate trace context across service boundaries (W3C TraceContext or B3 headers).
- Use exemplars to link metrics to traces, enabling drill-down from dashboards to individual requests.
- Follow metric naming conventions: snake_case with unit suffix (e.g., `http_request_duration_seconds`).
- Use structured logging with trace ID and span ID correlation fields.
- Set appropriate sampling rates — 100% sampling is rarely appropriate in production.
