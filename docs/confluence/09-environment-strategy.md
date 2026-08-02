# Reno V2 — Environment Strategy

| Environment | Purpose | Deployment |
|---|---|---|
| DEV | Developer integration | Automatic on approved development branch flow |
| STAGING | QA/integration validation | Controlled pipeline promotion |
| BETA | Production-like acceptance | Controlled release candidate promotion |
| PROD | Customer traffic | Manual approval + protected deployment |

## Configuration

Environment differences are configuration, not code forks.

Examples:

- API base URL
- database endpoint
- OAuth/client configuration
- log level
- replica counts
- resource limits
- feature flags

## Promotion model

```text
Commit -> CI -> Image -> DEV -> STAGING -> BETA -> PROD
                         tests     QA       UAT    approval
```

The same immutable image should be promoted between environments wherever practical.

## Production protections

- Protected branch
- Required pull request review
- Required CI checks
- Environment approval
- Secrets scoped to environment
- Rollback procedure tested
