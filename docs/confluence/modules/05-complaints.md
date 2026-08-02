# Module — Complaints

## Objective
Track customer/contractor complaints through triage, assignment, resolution and closure.

## Data

`complaints`, optionally linked to `leads`, `contractors` and `users`.

## API baseline

```text
POST /api/v1/complaints
GET  /api/v1/complaints
GET  /api/v1/complaints/{id}
PUT  /api/v1/complaints/{id}
POST /api/v1/complaints/{id}/resolve
```

## Status

`OPEN -> IN_PROGRESS -> RESOLVED -> CLOSED`.

Priority: LOW, MEDIUM, HIGH, CRITICAL.
