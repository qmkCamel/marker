## ADDED Requirements

### Requirement: The MVP supports an explicit set of schedule kinds
The system SHALL support the following MVP schedule kinds:
- `daily`
- `weeklyOnDays`, with one or more explicit weekdays
- `weeklyQuota`, with a target completion count and a week anchor driven by user preference

The system SHALL treat monthly, interval-based, or natural-language schedules as out of scope for this change.

#### Scenario: A product or engineering decision references supported schedules
- **WHEN** a developer reviews the schedule rules for MVP
- **THEN** the supported schedule kinds are explicitly listed
- **AND** unsupported schedule families are clearly identified as deferred

### Requirement: Schedule evaluation defines whether a habit is due on a logical day
The system SHALL define a due-on-day evaluation rule for each supported schedule kind.

The due rules SHALL behave as follows:
- `daily`: due on every logical day while the habit is active
- `weeklyOnDays`: due only when the logical day falls on one of the selected weekdays
- `weeklyQuota`: due on each logical day in the active week until the number of check-ins in that week reaches the target quota

#### Scenario: Selected weekdays only appear on matching days
- **WHEN** a habit uses `weeklyOnDays` with Monday, Wednesday, and Friday
- **THEN** the habit is due on logical Mondays, Wednesdays, and Fridays
- **AND** the habit is not due on other logical weekdays

#### Scenario: Weekly quota remains due until the quota is satisfied
- **WHEN** a habit uses `weeklyQuota` with a target of three completions per week
- **AND** the active week has only two matching check-ins so far
- **THEN** the habit remains due on the current logical day
- **AND** once the third check-in is recorded in that active week, the habit is no longer due for the remainder of that week

### Requirement: Reminder timing does not redefine due logic
The system SHALL treat reminder configuration as a notification concern rather than as a rule that changes whether a habit is due on a logical day.

#### Scenario: Reminder configuration is reviewed with a schedule
- **WHEN** a developer compares a habit's schedule and reminder settings
- **THEN** the schedule remains the source of truth for due-on-day evaluation
- **AND** reminder settings only influence notification delivery
