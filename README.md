# Reno V2 Infrastructure

Infrastructure and deployment configuration for Reno V2.

## Target platform

- Docker
- Kubernetes
- Helm
- GitHub Actions CI/CD
- DEV / QA / PROD environments

## Principles

- Configuration is environment-specific and secrets are never committed.
- Kubernetes manifests are deployment-oriented and reusable.
- CI builds, tests and packages applications; CD promotes immutable images between environments.
