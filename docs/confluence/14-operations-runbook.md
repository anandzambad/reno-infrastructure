# Reno V2 — Operations Runbook

## Pre-deployment checklist

- CI green
- Image identified by immutable SHA
- Database migration reviewed
- Environment configuration verified
- Required approvals completed
- Rollback image known

## Post-deployment checks

1. Kubernetes rollout successful.
2. Readiness probes healthy.
3. API health endpoint healthy.
4. Frontend reachable.
5. Database connectivity healthy.
6. Critical smoke tests pass.
7. Error rate and latency within expected range.

## Incident response

```text
Detect -> Triage -> Stabilize -> Diagnose -> Recover -> Verify -> Document
```

## Rollback

Application rollback:

1. Identify last known-good image.
2. Redeploy that image.
3. Verify health and critical workflows.
4. Monitor.

Database rollback:

Do not blindly downgrade migrations. Prefer a forward-fix migration or restore strategy after assessing data impact.

## Logging

Capture timestamp, environment, service, request/correlation ID, operation, severity and safe error context. Never log secrets, passwords or full sensitive payloads.

## Operational documentation

Every production incident resulting in a code/configuration change should create a follow-up ticket and update this runbook when a reusable operational lesson is identified.
