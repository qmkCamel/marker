## ADDED Requirements

### Requirement: Completion records separate logical day from event timestamp
The system SHALL store a logical-day identifier separately from the exact completion timestamp for each recorded check-in.

The shared contract SHALL define:
- `dayKey`: the canonical logical-day key used for daily history, streaks, and completion grouping
- `completedAt`: the exact timestamp when the completion was recorded
- `recordedTimeZoneIdentifier`: the time zone identifier used when deriving `dayKey`

#### Scenario: A completion is recorded near midnight
- **WHEN** a user records a habit completion shortly before or after midnight
- **THEN** the check-in stores both the exact completion timestamp and the logical `dayKey`
- **AND** later history views group the completion by the stored `dayKey` rather than by recomputing it from the timestamp alone

### Requirement: The logical-day key has a canonical format
The system SHALL represent `dayKey` in a stable calendar-date format that can be shared across storage, history, and statistics features.

#### Scenario: A developer references the stored day identifier
- **WHEN** a developer reads or writes a `dayKey`
- **THEN** the contract defines it as a calendar-date string in `YYYY-MM-DD` form
- **AND** the contract treats the value as a logical day label rather than as a timestamp

### Requirement: Historical interpretation uses the stored logical day
The system SHALL use the stored `dayKey` as the source of truth for streaks, daily completion, and history views even if the user's current time zone later changes.

#### Scenario: A user changes time zones after prior check-ins exist
- **WHEN** previously recorded check-ins are read after the device time zone changes
- **THEN** the system keeps the original historical grouping based on the stored `dayKey`
- **AND** the system does not silently reassign prior completions to different logical days
