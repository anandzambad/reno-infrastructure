# ADR-001 — Create a Dedicated Reno V2 Database

**Status:** Accepted

## Context

The legacy Reno application has a mature MySQL schema coupled to legacy JSP/Java implementation details. Reusing it directly would force V2 to preserve historical naming, relationships and technical constraints before those are fully understood.

## Decision

Reno V2 will use a new MySQL schema designed around the modern domain model. The legacy schema remains a reference and migration source.

## Consequences

### Positive

- Clean domain model
- V2 can evolve independently
- Lower coupling to legacy implementation
- Safer incremental modernization
- Easier automated schema migrations

### Trade-offs

- Data migration work is required.
- Some business behavior must be rediscovered from legacy code.
- During transition, two application/data models may coexist.

## Migration approach

Migrate module-by-module. Validate each mapping against actual legacy queries and production behavior before moving historical data.
