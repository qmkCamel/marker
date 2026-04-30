## ADDED Requirements

### Requirement: AI-generated code respects repository source-of-truth boundaries
The system SHALL require AI-generated code to treat approved OpenSpec specs and `shared/contracts` as the source of truth for behavior and domain semantics.

#### Scenario: AI adds or updates domain-facing code
- **WHEN** an AI assistant generates code that touches domain models, feature behavior, or cross-platform contracts
- **THEN** the generated code follows the behavior defined in `openspec/specs`
- **AND** domain fields and shared semantics align with `shared/contracts`
- **AND** the assistant does not invent new shared fields or rules outside an approved change

### Requirement: AI-generated code preserves explicit module boundaries
The system SHALL require AI-generated code to land inside the appropriate app, service, package, or shared workspace instead of creating speculative abstractions across repository boundaries.

#### Scenario: AI proposes a shared abstraction
- **WHEN** an AI assistant considers adding code to `shared` or introducing a new cross-platform abstraction
- **THEN** the abstraction is only added when an approved spec requires it
- **AND** platform-specific code remains in its owning workspace when no approved shared contract exists

### Requirement: AI-generated code follows repository coding constraints
The system SHALL require AI-generated code to follow the repository's coding constraints, including explicit typing expectations and file-size guardrails.

The current repository constraints SHALL include:
- follow SOLID-oriented decomposition
- split JavaScript and TypeScript files by responsibility before they exceed 600 lines
- provide explicit parameter types in typed languages where the codebase expects them

#### Scenario: AI generates a large TypeScript module
- **WHEN** an AI assistant generates or expands a JavaScript or TypeScript file toward the 600-line limit
- **THEN** the assistant splits the code by responsibility before the file becomes oversized
- **AND** generated function parameters remain explicitly typed where the language and codebase support it
