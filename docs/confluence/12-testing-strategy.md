# Reno V2 — Testing Strategy

## Test pyramid

```text
             E2E
          /       \
       API/Integration
      /             \
     Unit / Component
```

## Backend

- Unit tests for services and domain rules.
- Controller/API tests for validation and HTTP contracts.
- Repository/integration tests against a real MySQL-compatible test environment.
- Security tests for role boundaries.

## Frontend

- Component tests for reusable UI.
- Feature tests for forms, tables, filters and state transitions.
- API mocking for deterministic component tests.
- Browser E2E tests for critical customer/contractor/admin journeys.

## Critical journeys

1. Login and authorization
2. Customer creates lead
3. Admin/estimator reviews lead
4. Lead assigned to contractor
5. Contractor updates lead/follow-up
6. Estimation created
7. Invoice/work order generated
8. Complaint raised/resolved
9. Document uploaded/downloaded
10. Subscription lifecycle

## Release gate

No production deployment if required tests, security checks or migration validation fail.
