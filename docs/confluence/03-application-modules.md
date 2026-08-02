# Reno V2 — Application Modules

## Module map

| Module | Primary roles | Initial status |
|---|---|---|
| Authentication & Users | All | Foundation |
| Admin | Admin | Planned |
| Customer | Customer | Planned |
| Leads | Customer, Contractor, Estimator, Admin | In progress |
| Contractor | Contractor, Admin | Planned |
| Lead Assignment | Admin, Estimator | Planned |
| Follow-ups & Notes | Contractor, Estimator, Admin | Planned |
| Complaints | Customer, Contractor, Admin | Planned |
| Estimation | Contractor, Estimator | Planned |
| Invoicing | Contractor, Admin | Planned |
| Work Orders | Contractor, Customer, Admin | Planned |
| Documents | All authorized roles | Planned |
| Services | Admin | Foundation |
| Locations | Admin | Foundation |
| Promotions | Admin | Foundation |
| Subscriptions | Contractor, Admin | Planned |
| Reports | Admin, Estimator | Planned |

## Standard module structure

Each backend module should follow:

```text
api/
application/
persistence/
```

Each frontend module should keep UI, hooks, API client and validation close to the feature boundary.

## Delivery order

1. Authentication/RBAC
2. Users and profiles
3. Leads
4. Contractor and assignment
5. Follow-ups/notes
6. Complaints
7. Estimation
8. Invoice
9. Work order
10. Documents
11. Subscription/payment records
12. Promotions
13. Reports
14. Admin configuration

## Definition of done

A module is complete only when it has API contract, validation, persistence, UI, authorization, unit tests, integration tests, audit/logging requirements, documentation and deployment configuration where applicable.
