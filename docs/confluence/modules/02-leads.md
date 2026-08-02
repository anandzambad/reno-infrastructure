# Module — Leads

## Objective
Manage the full customer lead lifecycle from creation through assignment and completion.

## Main capabilities

- Create lead
- Search/filter/paginate
- View detail
- Update status
- Assign contractors
- Notes
- Follow-ups
- Attachments/documents
- Estimation/invoice/work-order relationships

## Data

`leads`, `lead_assignments`, `lead_notes`, `lead_follow_ups`, `lead_estimations`, `invoices`, `work_orders`, `documents`.

## API baseline

```text
POST /api/v1/leads
GET  /api/v1/leads
GET  /api/v1/leads/{id}
PUT  /api/v1/leads/{id}
POST /api/v1/leads/{id}/assignments
POST /api/v1/leads/{id}/notes
POST /api/v1/leads/{id}/follow-ups
```

## Workflow

`NEW -> REVIEWED -> ASSIGNED -> IN_PROGRESS -> COMPLETED`

Additional terminal state may be `CANCELLED`.

## Acceptance criteria

- Customer can create a lead.
- Authorized staff can search and update it.
- Assignment respects contractor/service/location rules.
- Status transitions are validated server-side.
