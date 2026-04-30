## Why

The repository foundation now exists, but there is still no canonical definition of a habit, its schedule, or a completion record. If persistence, history, statistics, or future platform work begins without shared contracts, each implementation will invent its own model and the product semantics will drift.

## What Changes

- Define the shared domain contracts for `Habit`, `HabitSchedule`, `CheckIn`, `Reminder`, and `UserPreference`.
- Define the MVP schedule kinds and the rules for determining whether a habit is due on a logical day.
- Define the `dayKey` concept and how it relates to completion timestamps and time zone capture.
- Prepare implementation tasks so later domain, storage, history, and statistics changes build on the same contract source of truth.

## Capabilities

### New Capabilities

- `habit-domain-contracts`: Define the core shared entities, field semantics, and lifecycle rules for habit tracking.
- `habit-schedule-rules`: Define the supported schedule types and due-on-day evaluation behavior for MVP habits.
- `day-key-semantics`: Define logical-day storage and interpretation rules so local-first tracking remains stable across midnight and time zone changes.

### Modified Capabilities

## Impact

- Affects `shared/contracts`, future `MarkerDomain` types, and all later persistence and feature changes.
- Constrains how history, streaks, reminders, and statistics are computed.
- Reduces the risk of iOS-first implementation choices becoming accidental long-term product contracts.
