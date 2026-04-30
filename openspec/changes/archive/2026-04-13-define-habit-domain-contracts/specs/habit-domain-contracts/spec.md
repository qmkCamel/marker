## ADDED Requirements

### Requirement: The system defines canonical shared habit-tracking entities
The system SHALL define shared contract objects for `Habit`, `HabitSchedule`, `CheckIn`, `Reminder`, and `UserPreference` before any persistence or feature implementation treats them as stable production models.

The shared contracts SHALL include, at minimum:
- `Habit`: `id`, `name`, `colorToken`, `notes`, `schedule`, `isArchived`, `createdAt`, `updatedAt`
- `CheckIn`: `id`, `habitId`, `dayKey`, `completedAt`, `recordedTimeZoneIdentifier`
- `Reminder`: `id`, `habitId`, `localTime`, `weekdays`, `isEnabled`
- `UserPreference`: `weekStartsOn`, `defaultHomeTab`, `preferredStatisticsWindow`

#### Scenario: Shared contracts are reviewed before implementation
- **WHEN** a developer reviews the approved habit domain contracts
- **THEN** the core objects and required fields are explicitly documented
- **AND** relationships between habits, schedules, reminders, and check-ins are described without relying on storage-specific schema details

### Requirement: Derived statistics remain separate from source-of-truth contracts
The system SHALL treat `Streak`, `CompletionRate`, and other summary metrics as derived read models rather than as primary source-of-truth entities.

#### Scenario: A developer plans history or statistics implementation
- **WHEN** a developer reads the shared habit domain contracts
- **THEN** the contracts identify `Habit`, `CheckIn`, `Reminder`, and `UserPreference` as source-of-truth records
- **AND** the contracts identify streaks and summary metrics as derived from those source-of-truth records

### Requirement: Shared contracts use stable lifecycle identifiers
The system SHALL use stable identifiers and lifecycle timestamps in the shared contracts so future local persistence and sync changes can evolve without redefining record identity.

#### Scenario: A developer implements storage from the contracts
- **WHEN** a developer maps the contracts into storage models
- **THEN** each primary entity exposes a stable identifier
- **AND** mutable primary entities expose creation and update timestamps
- **AND** archive semantics are preferred over destructive removal for habits
