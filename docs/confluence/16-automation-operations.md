# Reno V2 — Automation & Release Operations

## What is automated

### Pull request

- Frontend type-check, lint and production build
- Backend Maven test and package
- Reviewable code changes remain required before merge

### Main branch

- Frontend container published to GHCR using commit SHA
- Backend container published to GHCR using commit SHA
- No mutable production image is used by the deployment workflow

### Environment promotion

`reno-infrastructure/.github/workflows/deploy.yml` provides controlled promotion to:

- DEV
- STAGING
- BETA
- PROD

The workflow accepts independent frontend and backend image SHAs so releases can be promoted independently.

## Required GitHub environment secret

Each deployment environment needs:

`KUBE_CONFIG` — kubeconfig for the target cluster, stored as a GitHub Actions environment secret.

## Required Kubernetes secret

The cluster needs a secret named `reno-db` with:

- `url`
- `username`
- `password`

Do not commit this secret to Git.

## Release procedure

1. Merge validated frontend/backend changes to `main`.
2. Record the resulting frontend and backend image SHAs.
3. Run the infrastructure Deploy workflow for DEV.
4. Verify smoke tests and rollout health.
5. Promote the same image SHAs to STAGING.
6. Validate QA.
7. Promote to BETA for acceptance/UAT.
8. Promote to PROD only after the production environment approval gate.

## Rollback

Re-run the deployment workflow with the last known-good frontend/backend SHAs. Application rollback is intentionally independent from database rollback.
