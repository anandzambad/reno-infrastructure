# Reno V2 Enterprise CI/CD

## Delivery model

```text
Developer PR
  -> Frontend CI + Backend CI + Infrastructure CI
  -> security/dependency checks
  -> required reviews
  -> merge to develop
  -> Dev deployment
  -> smoke/E2E tests
  -> promote immutable image to Beta
  -> acceptance tests
  -> promote to Staging
  -> approval gate
  -> Production
  -> post-deploy smoke test
  -> automatic rollback on failed health checks
```

## Environment strategy

| Environment | Trigger | Purpose |
|---|---|---|
| Dev | merge to develop | continuous integration |
| Beta | successful Dev + promotion | QA/business validation |
| Staging | successful Beta + promotion | production-like validation |
| Prod | approved Staging promotion | live customers |

## Immutable release

Build the frontend/backend containers once. Tag with the Git SHA and deploy that exact image digest to every environment. Never rebuild the same commit for production.

## Required GitHub environments

Create `dev`, `beta`, `staging`, and `production` environments. Store environment-specific configuration and secrets there. Production should require reviewers.

Recommended secrets:

- `OIDC_ISSUER_URI`
- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`
- `REDIS_HOST`
- `GOOGLE_MAPS_API_KEY` (use a browser-restricted frontend key separately)
- Kubernetes/cluster authentication credentials, preferably GitHub OIDC rather than long-lived kubeconfig secrets.

## Security gates

- Dependency Review on pull requests
- CodeQL
- Container vulnerability scanning
- Secret scanning / push protection
- SBOM generation
- Least-privilege workflow permissions
- No production secrets in repository files
- No mutable production image tags as the deployment source

## Deployment gates

A deployment is allowed only after:

1. Compilation succeeds.
2. Unit tests pass.
3. Integration tests pass against MySQL and Redis.
4. Frontend lint/typecheck/build passes.
5. Kubernetes manifests validate.
6. Images pass vulnerability policy.
7. Dev smoke tests pass.
8. Beta/Staging acceptance passes.
9. Production approval is granted.
10. Post-deployment health and API smoke tests pass.

## Rollback

Kubernetes deployment uses the previous known-good image digest when a rollout or smoke test fails. Keep at least the previous 3 releases available.

## Branch policy

- Feature branches -> PR -> `develop`
- `develop` -> Dev
- Release promotion -> Beta
- Beta -> Staging
- Staging -> Production approval
- Direct production pushes are prohibited.

## Quality target

The pipeline must fail closed: a failed required check blocks promotion. Deployment jobs should never use `continue-on-error` for security, test, manifest, or health checks.
