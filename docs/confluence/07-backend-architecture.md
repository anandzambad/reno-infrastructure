# Reno V2 — Backend Architecture

## Technology

- Java 21
- Spring Boot
- Spring Web
- Spring Data JPA
- Bean Validation
- Flyway
- MySQL 8.4

## Layering

```text
api/
  Controllers + DTOs
application/
  Use cases and business orchestration
persistence/
  JPA entities and repositories
common/
  API envelopes, exceptions and shared infrastructure
```

## Rules

- Controllers are thin.
- Business decisions live in application/domain services.
- Repositories encapsulate persistence access.
- DTOs isolate public API contracts from database entities.
- Transactions are applied at service/use-case boundaries.
- Domain errors are mapped to stable HTTP error codes.
- External calls must have timeouts and failure handling.
- No credentials or secrets in code.

## Observability

Every API request should have a correlation/request ID. Logs should be structured and include operation, outcome, duration and safe business identifiers. Sensitive payloads must not be logged.

## Health

Expose liveness/readiness health endpoints suitable for Kubernetes probes. Readiness must reflect whether required dependencies are available for serving traffic.
