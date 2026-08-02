# Reno V2 — Frontend Architecture

## Technology

- Next.js
- React
- TypeScript
- Responsive component system
- Server/client rendering selected per feature

## Layering

```text
app/
  routes/pages
features/
  domain features
components/
  reusable UI
lib/
  API client, auth, utilities
hooks/
  reusable client behavior
schemas/
  validation contracts
```

## Principles

- Feature-oriented organization over large global component folders.
- TypeScript strictness enabled.
- API calls isolated from presentation components.
- Loading, empty, error and permission states are first-class UI states.
- Forms use shared validation contracts.
- Accessibility and responsive behavior are part of definition of done.
- Environment configuration is supplied using public runtime/build-safe variables only.

## Authentication

The UI consumes backend authentication/session contracts and uses route guards for protected areas. Authorization must also be enforced by the backend; frontend checks are not security boundaries.

## UX direction

The V2 UI should replace the legacy JSP screens with a consistent dashboard shell, navigation, tables, filters, forms, detail pages, notifications and role-specific workflows.
