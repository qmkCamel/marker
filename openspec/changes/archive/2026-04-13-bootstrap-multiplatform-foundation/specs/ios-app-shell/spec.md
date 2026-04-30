## ADDED Requirements

### Requirement: iOS workspace provides a runnable application shell
The iOS workspace SHALL build and run a SwiftUI application shell that gives product development a concrete starting point before business features are implemented.

#### Scenario: App launches into the primary navigation shell
- **WHEN** the iOS application launches after this change is applied
- **THEN** the user sees a tab-based shell
- **AND** the shell exposes `Today`, `History`, `Statistics`, and `Settings` as top-level destinations
- **AND** each destination renders a placeholder screen that confirms the navigation path is wired

### Requirement: iOS workspace uses reproducible project generation
The iOS workspace SHALL describe the application project in source-controlled configuration so contributors do not need to hand-edit Xcode project files to reproduce the shell.

#### Scenario: Developer generates the iOS project from configuration
- **WHEN** a developer runs the documented project generation command
- **THEN** the iOS Xcode project is generated successfully
- **AND** the generated project includes the application target and required package dependencies

### Requirement: iOS shell enforces modular package boundaries
The iOS shell SHALL separate stable business abstractions, data infrastructure, and shared UI building blocks into dedicated Swift packages.

#### Scenario: App target composes package dependencies
- **WHEN** a developer reviews the generated iOS project
- **THEN** the application target depends on `MarkerDomain`, `MarkerData`, and `MarkerDesignSystem`
- **AND** `MarkerData` depends on `MarkerDomain`
- **AND** `MarkerDesignSystem` does not depend on business or storage packages
- **AND** `MarkerDomain` does not depend on UI or storage implementation packages
