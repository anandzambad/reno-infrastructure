# Reno V2 deployment model

## Environments

| Environment | Kubernetes overlay | Namespace | Purpose |
|---|---|---|---|
| DEV | `kubernetes/overlays/dev` | `reno-dev` | active development integration |
| STAGING | `kubernetes/overlays/staging` | `reno-staging` | release candidate validation |
| BETA | `kubernetes/overlays/beta` | `reno-beta` | business/UAT validation |
| PROD | `kubernetes/overlays/prod` | `reno-prod` | production |

## CI/CD flow

1. Pull requests run frontend/backend tests and builds.
2. Push to `main` builds container images and publishes them to GitHub Container Registry (GHCR).
3. The infrastructure `Deploy` workflow is manually dispatched with an environment and immutable Git SHA image tag.
4. DEV, STAGING, BETA and PROD use separate GitHub Actions Environments.
5. Configure required reviewers on the `prod` GitHub Environment before production deployment.

## Required GitHub Environment secret

Each environment must define a secret named `KUBE_CONFIG` containing the kubeconfig for the target cluster/service account. Never commit kubeconfig, passwords, tokens or private keys.

## Database

The backend expects:

- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`

These must be injected as Kubernetes Secrets or through the platform's external secret manager. Production should use a managed/high-availability MySQL service rather than a MySQL pod in the application namespace.

## Domain names

The repository contains example hosts only:

- `reno-dev.example.com`
- `reno-staging.example.com`
- `reno-beta.example.com`
- `reno.example.com`

Replace these with the real DNS names before deployment.

## TLS

Add cert-manager/Ingress TLS configuration once the real domains and cluster ingress controller are available. Do not put TLS private keys in Git.
