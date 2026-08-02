# Reno V2 — System Architecture

## High-level architecture

```text
Browser
  |
  v
Next.js / React
  |
  | HTTPS REST/JSON
  v
Spring Boot API
  |
  +--> MySQL 8.4
  +--> Object Storage (documents)
  +--> External integrations (future)

GitHub -> GitHub Actions -> Container Registry -> Kubernetes
                                      |
                           DEV / STAGING / BETA / PROD
```

## Repository boundaries

- `reno-legacy`: existing JSP/legacy application; reference and migration source.
- `reno-frontend`: Next.js application.
- `reno-backend`: Spring Boot API and domain logic.
- `reno-infrastructure`: Docker, Kubernetes, CI/CD and documentation.

## Architectural principles

1. Frontend never connects directly to MySQL.
2. Business rules belong in backend services, not UI components.
3. REST API contracts are explicit and versioned.
4. Database changes are delivered through Flyway migrations.
5. Containers are immutable; configuration is injected at runtime.
6. Secrets are managed outside source control.
7. Production deployment is automated and auditable.
8. New V2 modules can coexist with legacy modules during migration.

## Request flow

```text
User -> Ingress -> Next.js -> API -> Controller -> Service -> Repository -> MySQL
```

## Availability and scaling

Frontend and API pods are stateless. Kubernetes can scale replicas horizontally. MySQL is treated as a stateful dependency and is not deployed as an application pod for production unless a dedicated database HA strategy is explicitly approved.
