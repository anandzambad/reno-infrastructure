# Reno V2 — CI/CD

## Pipeline stages

```text
Checkout
  -> Dependency install/cache
  -> Lint/static analysis
  -> Unit tests
  -> Integration tests
  -> Build
  -> Container image
  -> Security scan
  -> Push registry
  -> Deploy DEV
  -> Smoke tests
  -> Promote STAGING
  -> Promote BETA
  -> Manual PROD approval
  -> Deploy PROD
  -> Post-deploy verification
```

## Repository pipelines

### Frontend

Validate, test, build Next.js application, build container and publish immutable image.

### Backend

Validate, test, package Spring Boot application, build container and publish immutable image.

### Infrastructure

Validate Kubernetes manifests/configuration, build deployment artifacts and run deployment workflows.

## Image tagging

Use immutable tags such as commit SHA. Environment promotion should reference the exact image version that passed CI.

## Rollback

Rollback means redeploying the previously known-good image/configuration. Database rollback must be handled carefully because destructive schema downgrades are not assumed safe.

## Branch strategy

Recommended:

- `main`: protected production-ready line
- short-lived feature branches
- pull requests required for merge
- release tags for production releases
