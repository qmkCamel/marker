## 1. OpenSpec and repository foundation

- [x] 1.1 Finalize the bootstrap OpenSpec artifacts for repository foundation, iOS app shell, and platform placeholders
- [x] 1.2 Create the repository directory layout and baseline root files (`README.md`, `.gitignore`, docs, scripts, and shared workspace placeholders)
- [x] 1.3 Add project context to `openspec/config.yaml` so future changes inherit the selected platform direction

## 2. iOS project and package boundaries

- [x] 2.1 Create the XcodeGen-based iOS project definition and target layout under `apps/ios`
- [x] 2.2 Create `MarkerDomain`, `MarkerData`, and `MarkerDesignSystem` Swift packages with boundary tests
- [x] 2.3 Generate the Xcode project and wire the packages into the application target

## 3. App shell and placeholder platforms

- [x] 3.1 Build the SwiftUI application shell with `Today`, `History`, `Statistics`, and `Settings` placeholder tabs
- [x] 3.2 Add Android, Web, backend, and shared workspace placeholder documentation with clear responsibility notes
- [x] 3.3 Verify generation, build, and test commands, then mark the change ready for implementation follow-up changes
