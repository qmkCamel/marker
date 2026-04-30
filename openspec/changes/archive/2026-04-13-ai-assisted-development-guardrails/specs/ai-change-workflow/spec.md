## ADDED Requirements

### Requirement: Non-trivial AI-generated changes use OpenSpec before implementation
The system SHALL require non-trivial AI-generated changes to start from an OpenSpec change before multi-file implementation or behavior changes begin.

Non-trivial changes include:
- multi-file code changes
- behavior changes
- new capabilities
- refactors that cross module boundaries

#### Scenario: AI is asked to implement a feature across multiple files
- **WHEN** an AI assistant is asked to implement a non-trivial feature or behavior change
- **THEN** the work begins by creating or updating an OpenSpec change
- **AND** implementation follows approved proposal, specs, design, and tasks artifacts instead of ad hoc code generation

### Requirement: AI-generated work is decomposed into independently verifiable changes
The system SHALL keep AI-generated changes focused on one independently verifiable capability rather than combining unrelated subsystems into a single change.

#### Scenario: A request spans unrelated concerns
- **WHEN** an AI assistant receives a request that would touch unrelated domains or platforms
- **THEN** the assistant splits the work into separate OpenSpec changes or clearly separated tasks
- **AND** each resulting change has a single primary capability and its own verification path

### Requirement: AI task breakdown identifies exact change surfaces
The system SHALL require AI-oriented task plans to identify the files, directories, or packages they intend to modify before implementation starts.

#### Scenario: AI prepares implementation tasks
- **WHEN** an OpenSpec `tasks.md` file is created for AI-driven work
- **THEN** each task names the exact repository surfaces it will touch
- **AND** the task breakdown is small enough to execute and verify without broad speculative edits
