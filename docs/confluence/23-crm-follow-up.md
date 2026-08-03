# Reno CRM & 30/60/90-Day Customer Follow-up

## Business objective

Reno should retain customers after a completed job instead of treating each booking as a one-time transaction. CRM automatically schedules configurable 30, 60 and 90-day follow-ups for qualifying work.

## Lifecycle

```text
Lead
 -> Customer
 -> Project
 -> Estimate
 -> Quotation
 -> Booking
 -> Work Order
 -> Completion
 -> CRM Follow-up Plan
    -> 30 days
    -> 60 days
    -> 90 days
 -> Repeat Job / Referral / Retention
```

## Recommended use cases

**30 days:** satisfaction check, unresolved issue, support/warranty check.  
**60 days:** maintenance reminder or related service.  
**90 days:** repeat service, seasonal reminder, referral/review request.

The actual cadence is configurable by service category and contractor.

## Omnichannel communication

CRM integrates with Reno's document/communication layer:

- WhatsApp Business Platform/API
- Email
- SMS where configured and appropriate
- manual call/task records

Automated marketing communications must respect customer consent, channel opt-out and applicable messaging rules. Transactional messages and marketing messages should be classified separately.

## Architecture

```text
Completed Work Event
        |
        v
CRM Follow-up Planner
        |
        +--> 30-day task
        +--> 60-day task
        +--> 90-day task
        |
        v
Transactional Outbox / Queue
        |
        v
Notification Worker
        |
   +----+----+
   v         v
WhatsApp   Email
   |         |
   +----+----+
        v
Delivery Status
        |
        v
CRM Timeline / Analytics
```

## Reliability and concurrency

The scheduler must be safe when multiple backend replicas are running. Use atomic claiming/locking or a distributed scheduler strategy. Sending must be idempotent, retried with backoff and routed to a dead-letter queue after repeated failure.

## CRM KPIs

Track:

- follow-ups due
- follow-ups completed
- delivery success rate
- response rate
- repeat booking rate
- repeat GMV
- customer retention
- referral rate
- opt-out rate
- average time to next booking

## Product roadmap

### Phase 1

- Contacts
- Project history
- 30/60/90-day schedules
- Email/WhatsApp delivery
- Timeline
- manual reschedule/skip

### Phase 2

- configurable service templates
- automated reminders
- repeat-job campaigns
- referral campaigns
- CRM analytics

### Phase 3

- next-best-action recommendations
- customer segmentation based on non-sensitive behavioral data
- contractor CRM automation rules
- retention forecasting

## Implementation status

CRM feature contract and UX specification have been added to the backend/frontend repositories. Runtime implementation, provider configuration, migrations and automated tests remain implementation work and must be verified by CI before being marked production-ready.
