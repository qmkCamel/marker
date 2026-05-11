## Why

Today 和记录编辑器已经更接近 Marker 的“照料确认”体验，但创建追踪项仍然暴露为工程化表单：用户先看到 `TrackerKind` picker，再自己理解每种类型。根据 `IOS_V1_INTERACTION_DRAFT`，创建体验应该从“我想记录什么”开始，让用户先选择习惯、用药、经期或自定义模板，再进入基础信息配置。

本次变更把 iOS 新建入口改成模板优先流程，同时复用现有 `TrackerEditorView` 保存能力，避免过早扩大表单复杂度。

## What Changes

- 新增 iOS 追踪项模板选择页。
- Today 加号入口先打开模板选择，而不是直接打开编辑表单。
- 选择模板后进入现有编辑表单，并带入默认 kind、颜色和基础频率。
- 新建表单隐藏类型 picker，避免用户在模板后再次看到底层类型选择。
- 编辑已有追踪项时保留类型展示和原有编辑能力。

## Capabilities

### Modified Capabilities

- `habit-management-ui`: iOS 创建追踪项必须支持模板优先选择。

## Impact

- 影响 `apps/ios/MarkerApp/Sources/App/TrackerDraft.swift`。
- 影响 `apps/ios/MarkerApp/Sources/Features/Today/TodayView.swift`。
- 影响 `apps/ios/MarkerApp/Sources/Features/Today/TrackerEditorView.swift`。
- 影响 `apps/ios/MarkerApp/Tests/App/TrackerDraftTests.swift`。
- 影响 `apps/ios/MarkerApp/UITests/MarkerAppSmokeUITests.swift`。
- 不修改共享领域契约和数据库 schema。

## Non-goals

- 不新增剂量默认字段到 `Tracker`。
- 不实现事件型 schedule。
- 不重构归档管理或 Settings。
