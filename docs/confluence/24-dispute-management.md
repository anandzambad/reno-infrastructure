# Reno Dispute Management & Worst-Case Handling

## Purpose

Reno needs a neutral, evidence-based dispute process that protects customers and contractors while minimizing financial, safety, fraud and reputational risk.

## Lifecycle

```text
Issue
 -> Dispute Case
 -> Triage
 -> Evidence
 -> Customer/Contractor Response
 -> Support Review
 -> Resolution Proposal
 -> Accept / Reject
 -> Appeal / Escalation
 -> Final Resolution
 -> Close + Audit
```

## Severity

- **P1 Critical:** immediate safety concern, serious damage, suspected fraud or other urgent risk.
- **P2 High:** major financial loss or severe service failure.
- **P3 Normal:** ordinary quality, delay, pricing or invoice disagreement.
- **P4 Low:** minor issue or information request.

Exact SLAs are configurable and should be reviewed against applicable laws and contractual commitments.

## Worst-case playbook

1. Preserve evidence and audit logs.
2. Restrict only affected workflow/financial actions where appropriate.
3. Escalate P1/P2 cases to trained human support.
4. Avoid unsafe direct contact between parties where necessary.
5. Safety/criminal matters are not adjudicated by Reno; direct users to appropriate emergency/law-enforcement channels where applicable.
6. Reconcile payment/refund activity with the payment provider.
7. Apply an authorized resolution such as rework, adjustment, partial/full refund or closure.
8. Notify both parties and provide an appeal path for eligible cases.
9. Preserve a complete immutable case history.

## Evidence

Support quotations, estimates, work orders, invoices, receipts, messages and customer/contractor photos/videos. Evidence objects should use private storage, authorization checks and integrity checksums.

## Financial safeguards

Never automatically issue a full refund merely because a dispute was opened. If Reno controls or routes funds, financial holds/refunds must be policy-driven, role-authorized, idempotent and auditable. Payment-provider reconciliation is mandatory.

## Privacy and abuse controls

- Customer sees their cases and permitted evidence only.
- Contractor sees only their associated cases and permitted evidence.
- Support access is role-limited and audited.
- Rate-limit and deduplicate dispute creation.
- Protect PII and evidence from public URLs.
- Do not permanently label a party fraudulent from an automated score alone.

## Product metrics

Track:

- dispute rate per completed booking
- dispute categories
- P1/P2 rate
- first response time
- resolution time
- refund/adjustment rate
- rework rate
- appeal rate
- repeat dispute rate
- customer/contractor satisfaction after resolution

## Implementation status

Dispute-management architecture and UX specifications have been added to the Reno backend/frontend documentation. Runtime integration, secure evidence storage, authorization, payment reconciliation, notification workflows and automated tests remain implementation work and must be validated by CI before production release.
