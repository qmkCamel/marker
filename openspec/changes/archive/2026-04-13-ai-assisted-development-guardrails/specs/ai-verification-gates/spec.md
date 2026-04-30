## ADDED Requirements

### Requirement: AI-generated implementation tasks define exact verification commands
The system SHALL require AI-generated implementation tasks to include explicit verification commands before code work is considered ready for completion.

#### Scenario: AI writes task plans for code changes
- **WHEN** an AI assistant creates or updates `tasks.md` for an implementation change
- **THEN** each code-oriented task includes exact verification commands
- **AND** the commands are specific enough to prove the task outcome instead of relying on vague manual confidence

### Requirement: AI-generated behavior changes include meaningful automated verification
The system SHALL require AI-generated behavior changes to add or update automated tests when those tests materially reduce regression risk.

#### Scenario: AI changes a behavior with clear regression risk
- **WHEN** an AI assistant changes domain logic, feature behavior, or persistence semantics
- **THEN** the implementation includes or updates focused automated tests unless the change is configuration-only
- **AND** the final verification runs those tests successfully

### Requirement: AI-generated work is not considered complete without fresh verification evidence
The system SHALL require fresh verification output before AI-generated work is reported as complete.

#### Scenario: AI reports a change as done
- **WHEN** an AI assistant is ready to report that implementation is complete
- **THEN** the assistant has run the documented verification commands during the current work session
- **AND** the reported status reflects the actual output of those commands rather than assumption or prior runs
