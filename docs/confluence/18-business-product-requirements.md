# Reno V2 — Business Product Requirements

## Product position

Reno is a local-services marketplace and service-delivery platform, not only a lead-generation portal.

### Customer promise

Find trusted professionals, compare quotes, track work and receive post-job support.

### Contractor promise

Receive qualified local opportunities and manage leads, quotes, jobs, invoices and customers.

## Core transaction lifecycle

Customer request → qualification → matching → contractor response → quote → customer approval → work order → milestones → payment → completion → review → warranty/complaint.

## Lead lifecycle

`NEW → CONTACTED → QUALIFIED → QUOTED → ASSIGNED → IN_PROGRESS → COMPLETED`

Cancellation is allowed from active stages where operationally appropriate. Completed and cancelled leads are terminal states.

The backend must enforce transitions; the frontend must not be the source of truth for business rules.

## Customer requirements

- Service selection
- Location/postal code
- Requirement description
- Photos/documents where applicable
- Budget range
- Preferred schedule
- Quote comparison
- Contractor profile and verification status
- Job progress
- Payment/invoice history
- Rating/review
- Complaint/warranty workflow

## Contractor requirements

- Registration and KYC workflow
- Service categories
- Serviceable areas
- Availability
- Lead inbox
- Accept/reject lead
- Quote and estimate creation
- Job management
- Customer communication
- Invoice/payment tracking
- Performance dashboard
- Quality score

## Matching requirements

Candidate matching should consider:

1. Service/category skill
2. Serviceable postal code/radius
3. Availability
4. Contractor quality score
5. Response history
6. Price/estimate fit

Matching weights must be configurable and measurable rather than hard-coded into UI logic.

## Monetization candidates

- Transaction commission
- Contractor subscription tiers
- Optional promoted placement
- Lead credits where appropriate
- Premium operational/warranty services

Validate unit economics in one launch market before geographic expansion.

## North-star metric

Completed verified jobs per active service area per month.

## Critical business KPIs

- Lead qualification rate
- Lead-to-quote rate
- Quote-to-job rate
- Job completion rate
- Cancellation rate
- Average order value
- Repeat customer rate
- Contractor response time
- On-time completion rate
- Complaint rate
- Customer rating
- Customer acquisition cost
- Contractor acquisition cost
- GMV
- Reno revenue
- Contribution margin

## Product guardrails

- Do not expose customer contact information unnecessarily.
- Do not allow completed transactions to silently disappear from the platform.
- Keep customer, contractor and admin permissions separate.
- Store auditable status changes for operationally important actions.
- Never trust frontend validation alone for money, status, permissions or ownership rules.
