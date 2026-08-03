# Reno V2 — Validation & Quality Gates

## Customer UI validation

| Area | Validation / UX rule | Expected result |
|---|---|---|
| Service | Required | Search disabled until selected |
| Service loading | Disable actions while loading | No duplicate requests |
| Location | Browser permission handled | Clear success/error message |
| Location unavailable | Fallback location remains usable | User can continue deliberately |
| Latitude | -90..90 | Backend rejects invalid values |
| Longitude | -180..180 | Backend rejects invalid values |
| Radius | 0.5..50 km | Backend bounds query |
| Result count | 1..50 | Backend bounds result set |
| No contractors | Empty-state guidance | User can change service/location |
| Contractor selection | Selected state visible | Map/list remain synchronized |
| Busy contractor race | Booking conflict shown | User can select another |
| Booking | Requires authenticated customer | No hardcoded customer identity |
| Booking failure | Error shown without leaking internals | User can retry |
| Booking success | Success state | Selection cleared and availability refreshed |
| Map failure | Friendly error | App remains usable via list |
| Mobile | Single-column layout | Map/list usable on phone |
| Accessibility | Labels, live status, pressed state | Screen-reader friendly core flow |

## Backend request validation

### Nearby contractor

- serviceId > 0
- latitude -90..90
- longitude -180..180
- radius 0.5..50 km
- limit 1..50
- Redis online heartbeat required
- persisted availability must be AVAILABLE
- contractor must actively provide requested service

### Availability

- contractorId > 0
- latitude/longitude bounds
- service radius 0.5..100 km
- availability status is enum constrained
- only AVAILABLE contractors enter Redis GEO
- BUSY/OFFLINE/PAUSED/ON_JOB are removed from discovery

### Booking

- customerId > 0 (temporary until JWT subject replaces request ID)
- contractorId > 0
- serviceId > 0
- location bounds
- address max 500 characters
- price 0..1,000,000
- scheduledAt must be in the future when supplied
- contractor must be AVAILABLE and online
- contractor must be eligible for requested service
- contractor must have a current location
- customer must be inside contractor service radius
- contractor cannot have another active booking

## Concurrency / consistency

Booking creation uses a database transaction and pessimistic lock on contractor availability.

Booking status updates use a pessimistic lock on the booking row and a validated state machine.

The contractor is changed to BUSY in the same booking transaction.

Completion/cancellation returns the contractor to AVAILABLE and restores the Redis GEO location.

## Booking state machine

```text
CONFIRMED -> EN_ROUTE -> ARRIVED -> IN_PROGRESS -> COMPLETED
     |           |           |            |
     +-----------+-----------+------------+--> CANCELLED
```

Invalid transitions return HTTP 422.

## Standard error contract

All API failures should return the common envelope:

```json
{
  "success": false,
  "data": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": ["field: reason"]
  },
  "message": "Validation failed"
}
```

Unexpected server errors deliberately return a generic message and do not expose stack traces or database details.

## Security gates before production

1. Add Spring Security + OIDC/JWT.
2. Derive customer/contractor identity from the authenticated principal rather than request IDs.
3. Add role authorization to every contractor and booking mutation.
4. Add idempotency key to POST booking.
5. Add rate limiting to location and availability endpoints.
6. Restrict CORS to deployed frontend origins.
7. Validate Google Maps browser key by HTTP referrer/API restrictions.
8. Store DB/Redis credentials only in Kubernetes Secrets or an external secret manager.
9. Add audit log for booking/status changes.
10. Do not expose exact contractor location to customers before business rules permit it.

## Automated test matrix

### Backend unit tests

- invalid coordinates
- invalid radius/limit
- invalid IDs
- service eligibility
- outside service radius
- scheduled time in past
- unavailable contractor
- duplicate booking race
- invalid status transition
- completion/cancellation availability restoration
- malformed JSON
- validation error envelope

### Integration tests

Run against real MySQL + Redis containers.

- Flyway migrations
- GEO insertion/search/removal
- transaction locking
- booking + availability consistency
- restart Redis and verify heartbeat behavior

### Frontend tests

- service loading/error/empty state
- location permission accepted/denied
- map load failure
- list/map selection synchronization
- no-result state
- booking conflict
- booking success
- mobile layout
- keyboard navigation and screen-reader labels

## Release gate

A release is not production-ready until CI passes:

```text
lint
  ↓
typecheck
  ↓
unit tests
  ↓
integration tests (MySQL + Redis)
  ↓
frontend build
  ↓
backend package
  ↓
Docker build
  ↓
container vulnerability scan
  ↓
Kubernetes deployment smoke test
  ↓
manual browser acceptance
```
