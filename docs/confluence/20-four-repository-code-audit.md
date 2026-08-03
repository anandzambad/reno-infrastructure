# Reno V2 — Four Repository Audit

Audit date: 2026-08-03

## 1. Legacy baseline — `reno-legacy`

Purpose is correctly isolated as the migration reference. It is intentionally not used as a runtime dependency.

Risk: the repository currently documents the legacy baseline rather than containing a complete machine-readable migration inventory. Before each production migration, map legacy workflows, database tables, roles, integrations and edge cases to V2 acceptance tests.

## 2. Original `reno`

This remains the original application repository and should be treated as read-only source/reference during modernization. No V2 runtime dependency should point back to it.

Risk: avoid accidentally deploying the legacy application as the V2 frontend/backend. Keep migration notes and ownership clear.

## 3. `reno-backend`

Current target: Java 21 + Spring Boot 3.5.x + JPA + MySQL + Flyway + Redis + REST/OpenAPI.

Implemented in this phase:

- Redis dependency and connection configuration
- Redis GEO availability state with short-lived online heartbeat
- Contractor availability persistence
- Service eligibility mapping
- Nearby contractor endpoint
- Booking persistence and state machine
- Pessimistic lock on contractor availability to prevent double reservation
- Optimistic booking versioning
- Flyway migrations for availability, bookings and contractor services

Important production gaps:

1. Authentication/authorization must replace caller-supplied `customerId` and unrestricted contractor IDs.
2. Booking acceptance/status APIs must be role-checked.
3. Add WebSocket/SSE for active booking tracking.
4. Add Google Routes/Route Matrix server integration after candidate filtering.
5. Add idempotency keys to booking creation.
6. Add rate limiting and abuse controls to location APIs.
7. Add integration tests against MySQL + Redis.
8. Add service-area/postal-code eligibility in addition to service category.

## 4. `reno-frontend`

Current target: Next.js App Router + React + TypeScript.

Implemented in this phase:

- Google Maps contractor availability component
- Customer nearby contractor map/list page at `/book`
- Service-filtered nearby search
- Customer location selection
- Booking action with stale-availability conflict handling
- Google Maps TypeScript definitions
- Docker build-time public environment variables
- Explicit non-root runtime container user

Important production gaps:

1. Replace `NEXT_PUBLIC_DEMO_CUSTOMER_ID` with authenticated session/user context.
2. Do not treat frontend visibility or validation as authorization.
3. Add responsive mobile layout for the map/list experience.
4. Add loading skeletons and map failure/retry UX.
5. Use advanced marker clustering when candidate counts grow.
6. Add route/ETA display from the backend.

## 5. Infrastructure

The local Docker environment now includes:

`MySQL + Redis + Spring Boot + Next.js`

The Google Maps browser key is passed as a build argument because `NEXT_PUBLIC_*` values are embedded into the Next.js browser bundle at build time.

Production requirements:

- Kubernetes Secrets for database/Redis credentials
- Browser-referrer restrictions on Google Maps key
- Separate dev/beta/staging/prod Google Maps projects or keys
- Redis HA for production
- MySQL backups and migration rollback strategy
- HPA/resource limits
- Network policies
- TLS/Ingress
- Observability: metrics, logs, traces and alerts

## Bugs fixed during this audit

- Backend Dockerfile referenced a stale Maven artifact name (`0.1.0-SNAPSHOT`) while `pom.xml` builds `1.0.0`.
- Redis was missing from local Compose despite availability code depending on it.
- Redis configuration was missing from Spring application configuration.
- Nearby endpoint accepted `serviceId` but initially ignored it; service eligibility filtering is now explicit.
- Nearby endpoint initially did not return coordinates required by the map; coordinates are now returned.
- Google Maps TypeScript definitions were missing.
- Map effect could leave duplicate customer markers; marker cleanup was added.
- Google Maps public key was configured only at container runtime, which is too late for a Next.js client bundle; Compose now supplies it at image build time.
- Frontend container now creates and uses an explicit non-root user.
- Customer booking page had a hardcoded customer ID; this is now removed and booking is blocked until an authenticated customer identity is available.

## Release gate

Do not call live booking production-ready until authentication/RBAC, idempotency, service-area matching, integration tests and observability are implemented.
