## Context

The repository now has a stable multi-platform foundation and a runnable iOS shell, but there is still no shared contract for what a habit actually is. The next implementation changes will need to touch `shared/contracts`, `MarkerDomain`, persistence, reminders, history, and statistics. Without an explicit contract change first, those areas would hard-code conflicting assumptions.

Constraints:
- The product is local-first for its first milestone.
- iOS is the only active implementation platform, but the contracts must be future-friendly for Android, Web, and backend work.
- The domain model must support history and statistics without prematurely encoding persistence details.
- The model must avoid logic that breaks when users cross midnight or later change time zones.

## Goals / Non-Goals

**Goals:**
- Define shared source-of-truth entities and their required fields.
- Define the MVP schedule kinds and the rules for due-on-day evaluation.
- Define stable logical-day semantics for check-ins and historical interpretation.
- Give future persistence and feature work a contract source of truth.

**Non-Goals:**
- Choose the concrete local database schema or repository implementation details.
- Implement schedule evaluation code in this change.
- Support monthly, custom interval, or natural-language scheduling.
- Design sync conflict resolution or cloud-specific metadata beyond what the shared contracts need now.

## Decisions

### 1. Publish contracts before persistence

This change defines the contract vocabulary before any storage or UI change is allowed to fossilize its own model. That keeps iOS implementation detail from becoming accidental cross-platform truth.

Alternatives considered:
- Let the iOS storage layer define the initial model: rejected because it would make future cross-platform alignment harder.
- Define contracts only in code: rejected because the shared source of truth also needs to be visible to non-iOS future work.

### 2. Separate source-of-truth entities from derived metrics

`Habit`, `CheckIn`, `Reminder`, and `UserPreference` are source-of-truth records. `Streak`, completion summaries, and monthly aggregates are derived read models. This keeps later statistics changes flexible and avoids stale summary data becoming canonical.

Alternatives considered:
- Persist streaks as primary entities immediately: rejected because streak rules are derived from check-ins and likely to evolve.

### 3. Support only three MVP schedule families

The change explicitly supports `daily`, `weeklyOnDays`, and `weeklyQuota`. This keeps the MVP expressive enough for HabitKit-like usage while avoiding a premature explosion in schedule complexity.

Alternatives considered:
- Daily-only MVP: rejected because it undercuts the product goal and would require near-immediate schedule redesign.
- Monthly or free-form interval support now: rejected because it adds complexity before the first storage implementation exists.

### 4. Store both `dayKey` and completion timestamp

Each check-in contract carries the logical `dayKey`, the exact `completedAt` timestamp, and the `recordedTimeZoneIdentifier` used to derive that day key. This preserves historical grouping even when the user's current time zone changes later.

Alternatives considered:
- Timestamp-only storage: rejected because history, streaks, and summaries would become vulnerable to reinterpretation after time zone changes.
- Day key only: rejected because it loses the exact event timestamp needed for auditability and future sync behavior.

### 5. Treat weekly quota habits as due until the quota is met

For MVP, a weekly quota habit remains due on each logical day of the active week until its check-in count reaches the configured quota. This gives the Today surface a deterministic rule without inventing hidden scheduling heuristics.

Alternatives considered:
- Force users to pick exact days for quota habits: rejected because it collapses weekly quotas back into weekday schedules.
- Let the app guess recommended quota days: rejected because it adds product heuristics before the basics are stable.

## Risks / Trade-offs

- [Weekly quota due-today behavior may feel broad] -> Mitigation: document it explicitly now and revisit later through a focused product change if needed.
- [The contract may still need extra metadata for sync] -> Mitigation: keep identifiers and lifecycle timestamps stable so sync metadata can be added later without redefining core entities.
- [Too much flexibility in shared contracts could leak into scope] -> Mitigation: explicitly defer unsupported schedule families and implementation details.

## Migration Plan

There is no runtime migration yet. The practical rollout is:
1. Publish the contract docs and OpenSpec specs.
2. Mirror the approved contracts into `MarkerDomain` types and tests.
3. Make the storage and feature changes depend on those approved contracts instead of defining their own models.

## Open Questions

- Whether future sync requires additional per-record metadata such as origin device identifiers or change versions.
- Whether weekly quota habits eventually need richer Today-surface prioritization beyond the deterministic due-until-complete rule.
