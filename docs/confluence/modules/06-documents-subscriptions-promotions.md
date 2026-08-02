# Module — Documents, Subscriptions & Promotions

## Documents

Store metadata in MySQL and binary content in approved object storage. Never store arbitrary user-supplied file paths.

Data: `documents`.

## Subscriptions

Manage contractor plans and transaction records.

Data: `subscriptions`, `subscription_transactions`.

## Promotions

Manage promotion codes, validity and discount configuration.

Data: `promotions`.

## API baseline

```text
POST /api/v1/documents
GET  /api/v1/documents/{id}
DELETE /api/v1/documents/{id}
GET  /api/v1/subscriptions
POST /api/v1/subscriptions
GET  /api/v1/promotions
POST /api/v1/promotions
```

All endpoints require authorization and ownership checks appropriate to the resource.
