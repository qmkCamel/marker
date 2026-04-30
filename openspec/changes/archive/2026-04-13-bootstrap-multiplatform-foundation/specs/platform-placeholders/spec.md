## ADDED Requirements

### Requirement: Undecided platforms expose explicit placeholder boundaries
The repository SHALL provide placeholder workspaces for Android, Web, and backend development that describe future responsibilities without committing to a technology stack before that decision is made.

#### Scenario: Developer inspects a placeholder platform workspace
- **WHEN** a developer opens `apps/android`, `apps/web`, or `services/backend`
- **THEN** the workspace contains a short description of its intended role
- **AND** the workspace explains that the implementation stack is intentionally undecided or deferred
- **AND** the workspace identifies the expected relationship to shared contracts and product specifications

### Requirement: Shared cross-platform spaces are reserved for reusable product knowledge
The repository SHALL provide dedicated shared directories for product knowledge, cross-platform contracts, and common assets so future implementations across platforms can reference a common source of truth.

#### Scenario: Developer reviews the shared workspace
- **WHEN** a developer inspects the `shared` directory
- **THEN** the directory contains `product`, `contracts`, and `assets`
- **AND** each shared subdirectory includes a short description of the kind of artifacts it will hold
