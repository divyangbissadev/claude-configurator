# Observability Style Conventions

## Metric Naming
- Use snake_case for all metric names.
- Include unit suffix: `_seconds`, `_bytes`, `_total`, `_ratio`, `_info`.
- Prefix with application or subsystem name: `myapp_http_request_duration_seconds`.
- Counters must end with `_total` (e.g., `http_requests_total`).
- Use base units (seconds not milliseconds, bytes not kilobytes).

## Span Naming
- Use `<method> <route>` format for HTTP spans (e.g., `GET /api/users`).
- Use `<service>/<method>` for gRPC spans (e.g., `UserService/GetUser`).
- Use `<db.system> <db.operation> <db.name>.<table>` for database spans.
- Keep span names low-cardinality — no dynamic IDs in span names.

## Span Attributes
- Always set `service.name`, `service.version`, and `deployment.environment` as resource attributes.
- Use semantic conventions from the OTel specification for attribute keys.
- Add business-relevant attributes (order ID, customer tier) as span attributes, not span names.

## Logging
- Use structured JSON logging with consistent field names.
- Always include `trace_id` and `span_id` fields for log-trace correlation.
- Use log levels consistently: DEBUG for development, INFO for normal operations, WARN for recoverable issues, ERROR for failures.
- Never log sensitive data (passwords, tokens, PII).

## Labels
- Keep label cardinality bounded — never use user IDs, request IDs, or UUIDs as label values.
- Use consistent label names across services: `method`, `status_code`, `service`, `endpoint`.
