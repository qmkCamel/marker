## Context

The repository currently contains almost no implementation, but the product direction is already clear: build a habit-tracking application with iOS as the first real client, while Android, Web, and backend remain planned platforms. The project also intends to use OpenSpec as the primary change workflow, which means the initial bootstrap must produce both code structure and process structure.

Constraints:
- iOS must use Swift with a SwiftUI-first approach.
- Android, Web, and backend must remain placeholders for now.
- The repository should remain easy to understand for future feature changes.
- The bootstrap should avoid implementing business features such as persistence, reminders, or statistics logic.

## Goals / Non-Goals

**Goals:**
- Establish a lightweight monorepo layout that matches the long-term multi-platform product boundary.
- Create a runnable SwiftUI iOS shell with stable package boundaries.
- Make the iOS project reproducible from source-controlled configuration.
- Record enough OpenSpec project context to guide later changes.
- Reserve clear placeholder entry points for Android, Web, backend, and shared cross-platform artifacts.

**Non-Goals:**
- Implement habit creation, editing, check-in, statistics, reminders, or local persistence.
- Choose Android, Web, or backend frameworks.
- Introduce cloud sync, authentication, or API contracts beyond placeholder-level guidance.
- Build a final design system or production-grade visual polish.

## Decisions

### 1. Use a lightweight monorepo rooted in product boundaries

The repository will be structured around `apps`, `services`, and `shared` rather than around language or build tool. This keeps platform work isolated while making shared product artifacts obvious.

Alternatives considered:
- Separate repositories per platform: rejected because the project is still early and would duplicate setup and cross-platform knowledge.
- A technology-first tree: rejected because it obscures platform ownership and makes future non-code shared artifacts harder to place.

### 2. Treat OpenSpec as the durable planning workflow

The bootstrap will not only initialize OpenSpec, but also write project context into `openspec/config.yaml` so later changes inherit the chosen product scope and platform constraints.

Alternatives considered:
- Keep OpenSpec generic and rely on chat context: rejected because project intent would be lost across later changes.
- Use ad hoc docs outside OpenSpec: rejected because the user explicitly wants an OpenSpec-based workflow.

### 3. Use XcodeGen for the iOS project

The iOS application project will be defined in source-controlled YAML and generated from that definition. This keeps the bootstrap reproducible and avoids manually authoring or diffing a large `.pbxproj` file in an AI-driven workflow.

Alternatives considered:
- Commit a hand-authored `.xcodeproj`: rejected because it is tedious to create from scratch and hard to maintain accurately through text-only edits.
- Use Tuist: rejected because it is not currently installed in the environment and would add a larger toolchain footprint than needed for the bootstrap.

### 4. Split iOS into one app target plus three Swift packages

The app shell will be organized as a single application target backed by `MarkerDomain`, `MarkerData`, and `MarkerDesignSystem` Swift packages. This creates stable dependency direction without exploding the bootstrap into many targets.

Alternatives considered:
- Keep all code in the app target: rejected because it would make later domain and data extraction harder.
- Create many feature packages immediately: rejected because the bootstrap would become too heavy before real business features exist.

### 5. Use placeholder documentation instead of fake implementations for undecided platforms

Android, Web, and backend workspaces will contain responsibility notes and future integration guidance rather than empty folders or speculative starter apps. This keeps intent explicit without locking the project into premature choices.

Alternatives considered:
- Leave empty directories: rejected because future contributors would not know what each workspace is for.
- Generate starter apps for every platform: rejected because the user has not committed to those stacks yet.

## Risks / Trade-offs

- [XcodeGen becomes a required bootstrap tool] -> Mitigation: use a tool already installed in the environment and document generation commands in the repository.
- [Placeholder workspaces may drift from future reality] -> Mitigation: keep them lightweight and update them through later OpenSpec changes when stacks are chosen.
- [The app shell could overreach into feature design] -> Mitigation: keep screens intentionally skeletal and limit them to navigation and dependency composition.
- [Shared workspace names may invite premature sharing] -> Mitigation: document that `shared/contracts` and `shared/product` hold source-of-truth artifacts, not forced code reuse.

## Migration Plan

This is an initial bootstrap change, so there is no production migration or rollback path. The operational migration is:
1. Initialize the repository structure and baseline docs.
2. Generate the iOS project from XcodeGen configuration.
3. Verify the iOS shell builds and package tests pass.
4. Use later OpenSpec changes to layer business capabilities on top of the new foundation.

## Open Questions

- None for the bootstrap itself. Android, Web, backend stack selection, persistence technology, and sync architecture are intentionally deferred to later changes.
