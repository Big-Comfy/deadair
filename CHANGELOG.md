# Changelog

## v0.3.1 - 2026-07-04

First public cut.

- Elastic Security and OpenSearch Security Analytics backends; read-only by construction,
  least-privilege roles proven in CI including rejected writes.
- Rule-to-source dependency graph: dead detections (disconnected/starved), impaired detections
  (truncated lookback, missing fields, ingest-lag blind windows), unused telemetry, blast radius.
- Fleet scans across tenants and mixed backends with cross-tenant rollups; per-instance metrics.
- `scan` with CI exit codes, `--rule` candidate gating, `diff` between reports, `serve`
  Prometheus exporter, `tune` baseline suggestions, `setup` onboarding.
- Volume baselines with warmup/hysteresis, downtime windows, schema-drift tracking.
- TLS private-CA support, Kibana spaces, cross-cluster patterns as a distinct remote class.
- Reports/state 0600, full-name redaction (tenants included), loopback exporter, no telemetry.
