# Module — Estimation, Invoicing & Work Orders

## Objective
Convert an accepted lead into a priced scope, commercial invoice and executable work order.

## Data

`lead_estimations`, `lead_estimation_items`, `invoices`, `work_orders`, `work_order_items`.

## Flow

```text
Lead
 -> Estimation draft
 -> Estimation submitted/approved
 -> Invoice
 -> Work Order
 -> Work execution
 -> Completion
```

## API baseline

```text
POST /api/v1/leads/{id}/estimations
PUT  /api/v1/estimations/{id}
POST /api/v1/estimations/{id}/submit
POST /api/v1/leads/{id}/invoices
GET  /api/v1/invoices/{id}
POST /api/v1/leads/{id}/work-orders
PUT  /api/v1/work-orders/{id}
```

## Financial rules

Use decimal arithmetic. Totals are derived server-side from line items and tax rules. Client-provided totals are never trusted as authoritative.
