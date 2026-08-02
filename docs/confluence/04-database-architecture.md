# Reno V2 — Database Architecture

## Database strategy

Reno V2 uses a clean MySQL 8.4 schema owned by the V2 application. The legacy `renoreferral` schema is treated as a reference/migration source and is not required at runtime by V2.

## Migration tool

Flyway owns schema evolution. Every schema change is a new ordered migration. Existing migration files are immutable after merge.

## Core relationships

```text
users -> roles
users -> contractors
contractors <-> services
contractors <-> locations
leads -> users/customer
leads -> services
leads -> locations
leads -> budget_ranges
leads -> lead_assignments -> contractors
leads -> lead_notes
leads -> lead_follow_ups
leads -> lead_estimations -> lead_estimation_items
leads -> invoices
leads -> work_orders -> work_order_items
leads -> documents
contractors -> subscriptions -> subscription_transactions
```

## Data rules

- Use surrogate BIGINT identifiers.
- Store monetary values as `DECIMAL`, never floating point.
- Store timestamps in UTC at the application/database boundary.
- Use indexes for common search fields such as lead status, postal code and created date.
- Foreign keys protect domain integrity.
- Soft deletion should be introduced only where business retention requires it.

## Data migration

Legacy data migration will be incremental. A mapping document must be produced for each legacy table before production migration. Never assume legacy column names or relationships without verification.

## Backup and recovery

Production MySQL backup frequency, retention, point-in-time recovery and restore testing must be defined with the infrastructure owner before go-live.
