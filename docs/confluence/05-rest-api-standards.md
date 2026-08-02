# Reno V2 — REST API Standards

## Base path

`/api/v1`

## Resource examples

```text
POST   /api/v1/leads
GET    /api/v1/leads/{id}
GET    /api/v1/leads
PUT    /api/v1/leads/{id}
DELETE /api/v1/leads/{id}
```

## Response envelope

```json
{
  "success": true,
  "data": {},
  "message": "Operation completed successfully"
}
```

## Error envelope

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": []
  }
}
```

## HTTP conventions

- `200` successful read/update
- `201` successful creation
- `204` successful deletion with no body
- `400` malformed or invalid request
- `401` unauthenticated
- `403` unauthorized
- `404` resource not found
- `409` business conflict
- `422` semantically invalid input where appropriate
- `500` unexpected server failure

## API rules

- Validate all externally supplied data.
- Do not expose persistence entities directly as public contracts.
- Use DTOs for request and response payloads.
- Use pagination for collection endpoints.
- Do not return passwords, password hashes, internal secrets or infrastructure details.
- Document new endpoints with OpenAPI.
- Preserve compatibility within `/v1`.
