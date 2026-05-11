## Why

`IOS_V1_INTERACTION_DRAFT` 把 Today 定义为 Marker 的第一体验：用户打开应用后应立刻知道今天需要确认什么、哪些已经记录、哪些记录虽存在但不计入完成。当前 iOS Today 仍以“今日进度 / 今天要做”呈现，容易把用药跳过、备注记录等场景误读成普通习惯完成。

本次变更优先实现 Today 信息架构与记录确认，把首屏从任务进度调整为照料确认。它是后续记录改删、创建模板、History 和类型化 Statistics 的基础。

## What Changes

- 在 iOS Today 派生模型中区分 `待确认` 与 `今日已记录`。
- Today 摘要文案改为低压力的照料确认表达。
- Today 行内状态按 tracker 类型呈现主操作：
  - 习惯：快速完成按钮。
  - 用药：进入确认表单。
  - 经期：进入状态记录。
  - 自定义：进入备注记录。
- 已记录分区展示 payload 摘要，并突出 `已跳过` 是记录但不计入完成。
- Today 增加轻量本地保存说明。

## Capabilities

### Modified Capabilities

- `daily-tracking-workflow`: Today 视图需要区分待确认与已记录，并展示记录存在与计入完成的差异。

## Impact

- 影响 `apps/ios/MarkerApp/Sources/App/TrackingEngine.swift`。
- 影响 `apps/ios/MarkerApp/Sources/App/MarkerAppModel.swift`。
- 影响 `apps/ios/MarkerApp/Sources/Features/Today/TodayView.swift`。
- 影响 `apps/ios/MarkerApp/Tests/App/TrackingEngineTests.swift`。
- 不修改 `shared/contracts` 或 SQLite schema。

## Non-goals

- 不实现删除确认与撤销。
- 不重构创建模板。
- 不重构 History 或 Statistics。
- 不调整 Android。
