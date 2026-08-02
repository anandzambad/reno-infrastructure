# Module — Authentication & Users

## Objective
Provide secure identity, session/token management, user profile management and role-based access.

## Roles
ADMIN, CUSTOMER, CONTRACTOR, ESTIMATOR.

## Main capabilities

- Login/logout
- Credential lifecycle
- User profile
- Role assignment by authorized admin
- Account status
- Password reset/change

## Data

`roles`, `users`, `contractors`.

## API baseline

```text
POST /api/v1/auth/login
POST /api/v1/auth/logout
GET  /api/v1/users/me
PUT  /api/v1/users/me
GET  /api/v1/users/{id}
```

## Security acceptance criteria

- Password hashes never returned.
- Unauthorized roles cannot access protected resources.
- Expired credentials are rejected.
- Authentication events are auditable.
