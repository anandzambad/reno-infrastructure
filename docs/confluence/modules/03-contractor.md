# Module — Contractor

## Objective
Manage contractor onboarding, profile, service coverage and location coverage.

## Data

`contractors`, `contractor_locations`, `contractor_services`, `users`, `locations`, `services`.

## API baseline

```text
POST /api/v1/contractors
GET  /api/v1/contractors
GET  /api/v1/contractors/{id}
PUT  /api/v1/contractors/{id}
PUT  /api/v1/contractors/{id}/services
PUT  /api/v1/contractors/{id}/locations
```

## Rules

Contractors can manage their own profile within allowed fields. Admins can activate/deactivate accounts and manage service/location coverage.
