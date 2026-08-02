# Reno V2 Architecture

## Repositories

- `reno-legacy`: immutable reference and migration inventory
- `reno-frontend`: Next.js / React / TypeScript application
- `reno-backend`: Java 21 / Spring Boot REST API
- `reno-infrastructure`: Docker, Kubernetes, Helm and CI/CD

## Runtime flow

Browser -> Ingress/API gateway -> Next.js frontend -> Spring Boot REST API -> MySQL

The frontend must never connect directly to MySQL. Secrets are supplied at deployment time and are not committed to Git.

## Migration approach

Use a strangler-style migration. Introduce V2 modules alongside the legacy system, validate each module against existing business behavior, then retire the corresponding JSP/servlet workflow.

## Initial modules

- Authentication and authorization
- Leads
- Contractors
- Complaints
- Documents
- Reports
- Administration / settings

The module list is preliminary and must be refined from the legacy Java classes, `web.xml`, database schema and integrations.
