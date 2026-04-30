## Why

The repository is starting from a nearly empty state while the product roadmap already spans iOS, Android, Web, and backend concerns. We need a stable multi-platform foundation and a runnable iOS shell now so that later feature changes can land on clear boundaries instead of inventing structure ad hoc.

## What Changes

- Initialize the repository as a lightweight multi-platform monorepo with stable top-level directories for apps, services, shared assets, docs, and scripts.
- Establish OpenSpec as the project change-management workflow and capture project context for future changes.
- Create a runnable SwiftUI iOS application shell managed by XcodeGen.
- Define three iOS Swift packages for stable boundaries: `MarkerDomain`, `MarkerData`, and `MarkerDesignSystem`.
- Add explicit placeholder workspaces and onboarding notes for Android, Web, and backend so future implementations have known entry points without locking in an unchosen stack.

## Capabilities

### New Capabilities

- `repository-foundation`: Define the repository layout, baseline tooling, and OpenSpec project conventions for future changes.
- `ios-app-shell`: Provide a runnable SwiftUI iOS shell with top-level navigation and modular package boundaries.
- `platform-placeholders`: Reserve Android, Web, backend, and shared cross-platform spaces with clear responsibilities and handoff guidance.

### Modified Capabilities

## Impact

- Affects repository structure, developer onboarding, and future change management.
- Introduces an iOS build-generation workflow based on XcodeGen and Swift Package Manager.
- Creates the baseline app shell that all future iOS product changes will extend.
