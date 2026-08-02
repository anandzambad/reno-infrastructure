# Reno database mapping plan

We will proceed without requiring the full schema export up front.

## Phase A — application scaffolding

Build API boundaries, DTOs, validation, authentication boundaries, frontend feature modules, containers, Kubernetes, CI/CD and observability contracts without assuming legacy column names.

## Phase B — progressive legacy mapping

For each business module, inspect the legacy Java/JSP implementation and map only the tables needed by that module. Record:

- table
- primary key
- foreign keys
- required columns
- nullable columns
- enum/status values
- indexes
- legacy business rules
- stored procedures/triggers, if any

## Phase C — compatibility adapters

Where legacy schema is difficult to change, the V2 backend can initially read/write the existing tables through dedicated persistence adapters. This allows UI/API modernization without an immediate database rewrite.

## Phase D — controlled schema modernization

After behavior is validated in BETA, introduce normalized V2 tables and Flyway migrations where there is a measurable benefit. Migrate data with explicit scripts and reconciliation checks.

## Rule

Never delete/rename legacy columns or tables until the corresponding V2 module has passed regression and data reconciliation testing.
