# Reno V2 — Confluence Documentation Index

**Document owner:** Reno Engineering
**Status:** Living document
**Version:** 1.0

## Purpose

This directory is the source-controlled Confluence-style documentation set for Reno V2. Each file is intended to map to a separate Confluence page.

## Page hierarchy

1. [Product Vision & Scope](01-product-vision-and-scope.md)
2. [System Architecture](02-system-architecture.md)
3. [Application Modules](03-application-modules.md)
4. [Database Architecture](04-database-architecture.md)
5. [REST API Standards](05-rest-api-standards.md)
6. [Frontend Architecture](06-frontend-architecture.md)
7. [Backend Architecture](07-backend-architecture.md)
8. [Security & RBAC](08-security-and-rbac.md)
9. [Environment Strategy](09-environment-strategy.md)
10. [CI/CD](10-ci-cd.md)
11. [Docker & Kubernetes](11-docker-and-kubernetes.md)
12. [Testing Strategy](12-testing-strategy.md)
13. [Migration Plan](13-migration-plan.md)
14. [Operations Runbook](14-operations-runbook.md)
15. [ADR — V2 Database](adr-001-v2-database.md)

## Documentation rules

- Update the relevant page in the same pull request as architectural or API changes.
- Record irreversible architectural decisions as ADRs.
- API contracts are versioned under `/api/v1` and must remain backward compatible within a major version.
- Environment-specific values must never be committed as secrets.
