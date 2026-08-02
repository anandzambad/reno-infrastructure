# Reno V2 — Legacy Migration Plan

## Strategy

Use the Strangler Fig pattern. V2 modules are implemented independently while the legacy application continues to operate.

## Phases

### Phase 0 — Foundation

- Repository separation
- Next.js/Spring Boot baseline
- New MySQL schema
- Docker local stack
- CI foundation
- Documentation

### Phase 1 — Identity and Leads

- Authentication/RBAC
- Users/profiles
- Customer lead creation
- Admin/estimator lead management
- Contractor assignment

### Phase 2 — Lead lifecycle

- Follow-ups
- Notes
- Complaints
- Contractor workflows

### Phase 3 — Commercial workflow

- Estimation
- Invoices
- Work orders
- Documents

### Phase 4 — Platform

- Subscriptions
- Promotions
- Reports
- Admin configuration

### Phase 5 — Cutover

- Historical data migration where required
- Parallel validation
- Traffic migration
- Legacy read-only period
- Legacy retirement after agreed retention period

## Module migration rule

For every module:

```text
Legacy screen -> business rules -> data mapping -> V2 API -> V2 UI -> tests -> UAT -> production -> legacy retirement
```

## Data mapping

The V2 schema is intentionally independent. Legacy-to-V2 mappings will be captured only after verifying actual legacy queries, Java models and database columns. This avoids introducing incorrect assumptions into the new design.
