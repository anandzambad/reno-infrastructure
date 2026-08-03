# Reno V2 — Enterprise CI/CD, Release & Deployment Standard

**Status:** Active architecture standard  
**Updated:** 2026-08-03

## 1. Purpose

This document is the source of truth for Reno V2 delivery from pull request through Dev, Beta, Staging and Production.

Reno is split into four repositories:

- `reno-legacy` — frozen/reference implementation and migration source.
- `reno-frontend` — Next.js/React application.
- `reno-backend` — Spring Boot/Java REST API.
- `reno-infrastructure` — Kubernetes, platform configuration and infrastructure documentation.

## 2. Delivery flow

```text
Feature branch
    |
    v
Pull Request
    |
    +--> Frontend CI: install -> lint -> typecheck -> test -> build -> CodeQL
    |
    +--> Backend CI: validate -> compile -> MySQL/Redis tests -> package -> CodeQL
    |
    +--> Infrastructure CI: YAML/schema validation -> Helm lint
    |
    +--> Dependency/security checks
    |
    v
Required PR reviews + branch protection
    |
    v
Merge to develop
    |
    v
Build immutable images/artifacts
    |
    v
DEV deployment
    |
    v
Health + API smoke + E2E
    |
    v
BETA promotion
    |
    v
QA / business acceptance
    |
    v
STAGING promotion
    |
    v
Production approval
    |
    v
PRODUCTION deployment
    |
    v
Post-deployment health/smoke
    |
    +--> failure => rollback to previous known-good release
```

## 3. CI currently implemented

### Frontend

Workflow: `.github/workflows/ci.yml`

Checks include:

- Node.js 22
- `npm ci`
- lint
- TypeScript/typecheck when configured
- unit tests when configured
- Next.js production build
- build artifact retention
- GitHub Dependency Review on PRs
- CodeQL JavaScript/TypeScript analysis
- concurrency cancellation for obsolete runs

### Backend

Workflow: `.github/workflows/ci.yml`

Checks include:

- Java 21 / Maven
- Maven validation
- compilation
- MySQL 8.4 service container
- Redis 7.4 service container
- unit/integration tests
- packaged JAR artifact
- Dependency Review on PRs
- CodeQL Java analysis
- Docker Buildx image build
- GHCR publication on `main`
- SHA-tagged immutable image plus convenience `latest` tag

Scheduled security workflow:

- `.github/workflows/security.yml`
- weekly CodeQL scan

### Infrastructure

Workflow: `.github/workflows/platform-ci.yml`

Checks include:

- Helm lint when Helm charts exist
- Kubernetes YAML/schema validation using kubeconform
- CI on PRs and protected environment branches

## 4. Branch strategy

```text
feature/*
    |
    v
PR -> develop -> DEV
                |
                v
               BETA
                |
                v
             STAGING
                |
                v
          PROD approval
                |
                v
              PROD
```

Direct production pushes are prohibited.

## 5. Environment strategy

| Environment | Purpose | Expected trigger | Approval |
|---|---|---|---|
| DEV | integration and developer validation | merge to `develop` | none/automated |
| BETA | QA and business validation | successful DEV promotion | optional QA gate |
| STAGING | production-like validation | successful BETA promotion | release owner |
| PROD | live customer traffic | successful STAGING | mandatory production reviewers |

Each GitHub Environment should have its own configuration and deployment protection rules.

## 6. Immutable release principle

The same application build must move through environments.

Do **not** rebuild source separately for Beta, Staging and Production.

Preferred identity:

```text
Git SHA
  -> container image
  -> immutable digest
  -> DEV
  -> BETA
  -> STAGING
  -> PROD
```

The deployment source of truth is the immutable digest, not `latest`.

## 7. Security gates

Required enterprise controls:

- GitHub secret scanning and push protection
- Dependency Review
- CodeQL
- Container vulnerability scanning
- SBOM generation
- least-privilege workflow permissions
- environment-specific secrets
- no credentials committed to Git
- production approval
- Kubernetes workload security policies

Use GitHub OIDC/workload identity for cloud/Kubernetes authentication where supported instead of long-lived credentials.

## 8. Required secrets/configuration

Configure values in GitHub Environments or an external secret manager, not in repository source.

Backend examples:

- `OIDC_ISSUER_URI`
- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`
- `REDIS_HOST`
- `REDIS_PORT`

Frontend examples:

- API base URL
- browser-safe Google Maps configuration

Never expose backend database passwords, Redis credentials or private API credentials through `NEXT_PUBLIC_*` variables.

## 9. Deployment gate contract

Promotion is allowed only when:

1. Frontend CI passes.
2. Backend CI passes.
3. Infrastructure validation passes.
4. Unit tests pass.
5. Integration tests pass against MySQL and Redis.
6. Security gates pass.
7. Container image is available in GHCR.
8. Kubernetes manifests validate.
9. DEV rollout is healthy.
10. DEV smoke/E2E tests pass.
11. BETA acceptance passes.
12. STAGING acceptance passes.
13. Required production approval is granted.
14. Production rollout completes successfully.
15. Post-deployment health/smoke tests pass.

A required failure blocks promotion.

## 10. Kubernetes deployment standard

Production workloads should include:

- Deployment
- Service
- Ingress/Gateway
- ConfigMap
- Secret references
- readiness probe
- liveness probe
- startup probe where required
- resource requests/limits
- HPA
- PodDisruptionBudget where appropriate
- rolling update strategy
- topology/anti-affinity rules where appropriate
- network policies

Application configuration must be injected through environment-specific configuration rather than hardcoded in images.

## 11. Rollout and rollback

Use rolling deployments with health checks.

Deployment failure conditions include:

- image pull failure
- readiness failure
- crash loop
- failed migration
- smoke test failure
- unacceptable error rate

On failure, stop promotion and restore the previous known-good image digest.

Keep at least three known-good release versions available where operationally practical.

## 12. Database migration policy

Reno backend uses Flyway.

Rules:

- schema changes are version-controlled
- migrations run before application code depends on them
- destructive changes use expand/contract migration strategy
- production migrations must be backward compatible during rolling deployment
- never manually modify production schema without an emergency procedure and audit trail

## 13. Observability gate

Each environment should expose:

- `/actuator/health`
- application metrics
- structured application logs
- deployment/rollout events
- API latency/error metrics
- database connection pool metrics
- Redis health/latency

Production should have alerting for availability, error rate, latency and resource saturation.

## 14. Booking-specific smoke tests

The contractor marketplace flow must be validated after deployment:

```text
Customer login
 -> service selection
 -> customer location
 -> nearby contractor query
 -> Redis availability check
 -> map/list rendering
 -> contractor selection
 -> booking request
 -> database transaction
 -> contractor becomes BUSY
 -> Redis availability is removed
 -> booking status transition
 -> completion/cancellation
 -> contractor becomes AVAILABLE again
```

Concurrency tests must verify that two customers cannot successfully reserve the same contractor at the same time.

## 15. API security standard

The backend is stateless and protected by Spring Security OAuth2/JWT.

Important rule:

```text
Browser supplied customerId = untrusted
JWT customer_id claim = authenticated identity
```

Booking APIs must never trust an arbitrary customer identifier from the request body.

Role-based access is applied to protected operations such as contractor/admin booking status transitions.

## 16. Definition of Done for a release

A release is complete only when:

- source merged through PR
- all required CI checks green
- security checks green
- immutable image created
- DEV deployed and tested
- Beta acceptance completed
- Staging validated
- production approval recorded
- production rollout healthy
- post-deployment smoke tests passed
- release/version recorded
- rollback point retained
- Confluence documentation updated when architecture/process changes

## 17. Current implementation status

### Implemented now

- Backend enterprise CI workflow
- Backend MySQL/Redis CI services
- Backend CodeQL
- Backend Dependency Review
- Backend Docker build
- Backend GHCR publication on main
- Scheduled backend CodeQL
- Frontend CI workflow
- Frontend lint/typecheck/test/build stages
- Frontend CodeQL
- Frontend Dependency Review
- Infrastructure CI
- Kubernetes manifest validation
- Helm lint support
- Enterprise CI/CD documentation

### Next implementation stage

The remaining delivery layer is the actual Kubernetes promotion automation:

```text
GHCR
 -> DEV Kubernetes
 -> smoke/E2E
 -> BETA
 -> acceptance
 -> STAGING
 -> approval
 -> PROD
 -> post-deploy verification
 -> automatic rollback
```

That stage should use immutable image digests, GitHub Environment approvals, Kubernetes rollout status checks and a tested rollback path.

## 18. Operational rule

Do not describe a deployment as production-ready merely because CI passed. Production readiness requires successful deployment, health checks, smoke/E2E tests, observability and rollback verification in the target environment.
