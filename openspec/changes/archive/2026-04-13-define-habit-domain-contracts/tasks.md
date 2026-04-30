## 1. Shared contract publication

- [x] 1.1 Write `shared/contracts/habit-domain.md` to document `Habit`, `CheckIn`, `Reminder`, `UserPreference`, and the distinction between source-of-truth entities and derived metrics
- [x] 1.2 Write `shared/contracts/habit-schedule.md` to document supported schedule kinds and due-on-day rules
- [x] 1.3 Write `shared/contracts/day-key.md` to document `dayKey`, `completedAt`, and `recordedTimeZoneIdentifier`

## 2. Domain code alignment

- [x] 2.1 Add `MarkerDomain` value types and enums that mirror the approved shared contracts
- [x] 2.2 Add unit tests for supported schedule kinds and weekly quota due-on-day semantics
- [x] 2.3 Add unit tests or helpers that lock down `dayKey` formatting and historical interpretation rules

## 3. Contract consistency and verification

- [x] 3.1 Ensure shared contract docs and `MarkerDomain` type names describe the same source-of-truth objects
- [x] 3.2 Ensure schedule and `dayKey` rules are both documented and covered by tests
- [x] 3.3 Validate and archive the change once docs, domain types, and tests agree
