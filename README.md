# Reno V2 Infrastructure

Reno V2 deployment platform for DEV, STAGING, BETA and PROD.

## Repository responsibilities

- `reno-legacy` — read-only business/system reference
- `reno-frontend` — Next.js/React/TypeScript UI
- `reno-backend` — Java 21/Spring Boot REST API
- `reno-infrastructure` — Docker, Kubernetes, Kustomize and CI/CD

## Environments

```text
DEV -> STAGING -> BETA -> PROD
```

Deployments use immutable Git SHA image tags. Production should be protected by GitHub Environment reviewers.

## Current platform

- Docker multi-stage images
- GHCR image publishing
- Kubernetes Deployments/Services/Ingress/HPA
- Kustomize overlays for four environments
- Manual controlled deployment workflow
- Flyway-backed backend database migration strategy

## Required external configuration

Configure a GitHub Actions `KUBE_CONFIG` secret independently for each environment. Configure database URL/credentials through Kubernetes Secrets or an external secret manager. Replace example hostnames with real DNS names and add TLS before production.

## Business application migration

Business modules are migrated from the legacy application using this sequence:

1. Authentication / authorization
2. Leads
3. Contractors
4. Complaints
5. Documents
6. Reports
7. Administration / settings

The legacy MySQL schema and Java source remain the source of truth. No production database schema is invented during scaffolding.
