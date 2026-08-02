# Reno V2 — Product Vision & Scope

**Status:** Approved baseline

## Vision

Modernize Reno from the legacy JSP/Java application into a maintainable, secure, observable and independently deployable web platform without requiring a big-bang replacement.

## Primary users

- Admin
- Contractor
- Estimator
- Customer

## Core business capabilities

- Customer lead creation and management
- Contractor onboarding and profile management
- Lead assignment and follow-up
- Complaints
- Estimation and estimation line items
- Invoicing
- Work orders
- Documents
- Services, locations and budget ranges
- Promotions
- Subscriptions and transactions
- Reporting and administration

## V2 technology baseline

| Layer | Technology |
|---|---|
| UI | Next.js, React, TypeScript |
| API | Java, Spring Boot |
| Database | MySQL 8.4 |
| API style | REST/JSON |
| Containers | Docker |
| Orchestration | Kubernetes |
| CI/CD | GitHub Actions |
| Database migrations | Flyway |
| Repository model | Frontend, Backend, Infrastructure, Legacy separated |

## Non-functional goals

- Responsive UI
- Secure authentication and role-based authorization
- API validation and consistent errors
- Automated unit, integration and end-to-end testing
- Health checks and structured logging
- Horizontal scaling for stateless services
- Repeatable deployments to DEV, STAGING, BETA and PROD
- Backward-compatible migration from legacy functionality
