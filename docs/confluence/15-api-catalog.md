# Reno V2 — API Catalog

This page is the high-level API inventory. Detailed request/response schemas belong in OpenAPI and module pages.

| Area | Endpoints |
|---|---|
| Auth | `/auth/login`, `/auth/logout`, `/users/me` |
| Leads | `/leads`, `/leads/{id}` |
| Assignment | `/leads/{id}/assignments` |
| Notes | `/leads/{id}/notes` |
| Follow-ups | `/leads/{id}/follow-ups` |
| Contractors | `/contractors`, `/contractors/{id}` |
| Complaints | `/complaints`, `/complaints/{id}` |
| Estimation | `/leads/{id}/estimations`, `/estimations/{id}` |
| Invoice | `/leads/{id}/invoices`, `/invoices/{id}` |
| Work Order | `/leads/{id}/work-orders`, `/work-orders/{id}` |
| Documents | `/documents`, `/documents/{id}` |
| Subscriptions | `/subscriptions` |
| Promotions | `/promotions` |
| Services | `/services` |
| Locations | `/locations` |
| Reports | `/reports/*` |

## API governance

All endpoints are under `/api/v1`. Any breaking contract requires a new API version or an approved compatibility strategy.
