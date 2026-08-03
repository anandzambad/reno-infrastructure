# Reno V2 — Live Contractor Availability & Booking

## Objective

Provide an Uber-style local-service discovery flow while keeping Reno responsible for availability, matching, booking and job state.

Google Maps Platform is the map/routing provider. Reno remains the system of record for contractors and bookings.

## Customer flow

1. Customer selects a service.
2. Customer shares location or chooses an address.
3. Reno filters eligible contractors by service, service area, availability and recent heartbeat.
4. Reno optionally calls Google Routes/Route Matrix for ETA on the small candidate set.
5. Customer sees verified contractors with approximate distance/ETA, rating, quality score and starting price.
6. Customer selects a contractor and books now or schedules a job.
7. Contractor accepts/rejects.
8. Booking progresses through the state machine.
9. During an active booking, live tracking can be enabled according to privacy and safety policy.

## Booking state machine

`REQUESTED → MATCHING → OFFERED → ACCEPTED → CONFIRMED → EN_ROUTE → ARRIVED → IN_PROGRESS → COMPLETED`

Terminal/exception states include `CANCELLED`, `EXPIRED`, and `NO_SHOW` where applicable.

The backend must enforce transitions.

## Contractor availability

`OFFLINE`, `AVAILABLE`, `BUSY`, `ON_JOB`, `PAUSED`.

A contractor is considered discoverable only when:

- status is `AVAILABLE`;
- contractor is verified/eligible for the requested service;
- location is sufficiently recent;
- service area matches the request;
- contractor has not exceeded operational capacity.

## Location architecture

```text
Contractor client
      ↓
Location/availability API
      ↓
Redis GEO / short-lived live state
      ↓
Matching service
      ↓
MySQL transactional data
```

Do not write every GPS heartbeat to MySQL. Persist only business-required location history/events.

## Matching performance

Do not call Google routing for every contractor.

```text
Customer coordinates
 → spatial candidate filter
 → service + availability filter
 → top candidate set
 → Google ETA calculation
 → quality/rating/ETA/price ranking
 → customer response
```

Recommended initial candidate set: 10–20 contractors. Tune using production metrics and Google Maps usage costs.

## Privacy

Before booking, show approximate distance/ETA rather than a contractor's exact live location.

During an accepted active booking, expose only the minimum location information needed for the service experience. Define retention and access rules before production launch.

## API contract

```http
GET  /api/v1/contractors/nearby?serviceId={id}&latitude={lat}&longitude={lng}&radiusKm={km}
POST /api/v1/contractors/me/availability
POST /api/v1/contractors/me/location
POST /api/v1/bookings
POST /api/v1/bookings/{id}/accept
POST /api/v1/bookings/{id}/reject
POST /api/v1/bookings/{id}/cancel
POST /api/v1/bookings/{id}/start
POST /api/v1/bookings/{id}/complete
GET  /api/v1/bookings/{id}/tracking
```

## Suggested nearby contractor response

```json
{
  "data": [
    {
      "contractorId": 101,
      "name": "Verified Electrical Services",
      "rating": 4.8,
      "distanceKm": 1.4,
      "etaMinutes": 7,
      "startingPrice": 350,
      "qualityScore": 92,
      "available": true
    }
  ]
}
```

Never return sensitive contractor location or KYC information through this public response.

## Frontend

The frontend now contains a reusable `ContractorAvailabilityMap` component. Configure:

`NEXT_PUBLIC_GOOGLE_MAPS_API_KEY`

Use a browser-restricted Google Maps key with only the APIs required by the application. Never put a server secret in `NEXT_PUBLIC_*` variables.

## Production hardening before enabling live tracking

- Authentication and role-based authorization
- Rate limiting on location/availability APIs
- Location heartbeat expiry
- Redis GEO or equivalent spatial cache
- WebSocket/SSE for active booking updates
- Idempotent booking acceptance
- Booking concurrency protection so two customers cannot reserve the same contractor
- Audit history for booking state transitions
- API observability and alerting
- Google Maps quota/budget alerts
- Privacy policy and location consent
- Automated tests for booking races, cancellation and stale locations
