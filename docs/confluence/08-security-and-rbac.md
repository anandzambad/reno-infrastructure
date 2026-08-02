# Reno V2 — Security & RBAC

## Roles

Initial roles:

- `ADMIN`
- `CUSTOMER`
- `CONTRACTOR`
- `ESTIMATOR`

## Authorization model

```text
Authentication -> Identity -> Role -> Permission -> Resource ownership
```

Role checks are enforced server-side. Resource ownership rules are evaluated after role checks where applicable.

## Security requirements

- Passwords must use a strong adaptive password hash when local credentials are used.
- TLS is mandatory outside local development.
- JWT/session credentials must have controlled expiry and rotation strategy.
- Secrets are injected through deployment secret management.
- CORS is allow-listed per environment.
- SQL injection is prevented through parameterized/JPA access.
- Input validation occurs at API boundaries.
- File uploads validate size, type and storage key handling.
- Audit-sensitive actions should record actor, action, resource and timestamp.

## Sensitive data

Never commit passwords, database credentials, tokens, private keys or production connection strings to GitHub.

## Security testing

CI must include dependency scanning, secret scanning, static analysis and tests for authorization boundaries before production release.
