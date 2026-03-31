---
description: Validate OTel collector config, Prometheus rules, Grafana dashboards, and alert completeness
---

# Validate Observability

Run the following validation checks:

## OTel Collector Config Syntax
- Parse the collector YAML config and check for valid receivers, processors, exporters, and service pipelines.
- Verify that referenced components exist in the configuration.
- Run `otelcol validate --config=<path>` if the collector binary is available.

## Prometheus Rule Syntax
- Run `promtool check rules <file>` on all Prometheus rule files.
- Validate that recording rules follow naming conventions (`namespace:metric:aggregation`).
- Check alerting rules for required labels and annotations.

## Grafana Dashboard JSON Validity
- Parse all dashboard JSON files and validate structure.
- Check that datasource references are valid.
- Verify panel queries are syntactically correct.

## Alert Rule Completeness
- Every alert must have: `runbook_url` annotation, `severity` label, `team` label.
- Alerts with `severity: critical` must route to a paging system.
- Alerts must have a meaningful `description` annotation with template variables.

Report all findings with file paths and line numbers.
