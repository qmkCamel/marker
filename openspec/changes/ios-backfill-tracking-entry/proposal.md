## Why

`PRODUCT_TODO` 当前把 iOS 记录编辑闭环列为 P0，其中最前置的能力是选择历史 `dayKey` 进行补记。现有 iOS 应用只能在 Today 中记录当前逻辑日；如果用户漏记昨天的用药、经期或自定义备注，就无法把记录补回正确日期，历史和统计也会因此失真。

本次变更先做最小可验证补记路径，让用户从 History 进入补记，选择历史日期和 tracker，复用现有类型化记录编辑器保存到指定 `dayKey`。改记、删除确认、记录时间语义解释和 Today 信息架构重构后续再分别推进。

## What Changes

- 在 iOS History 页增加补记入口。
- 提供补记选择界面，允许用户选择不晚于今天的日期和活跃 tracker。
- 复用 `TrackingEntryEditorView` 保存指定 `dayKey` 的记录；如果同一天同 tracker 已有记录，则进入覆盖式编辑。
- 为补记路径补充单元测试和 UI smoke 覆盖。

## Capabilities

### Modified Capabilities

- `daily-tracking-workflow`: 增加 iOS 用户为历史逻辑日补记记录的行为要求。

## Impact

- 影响 `apps/ios/MarkerApp/Sources/App/MarkerAppModel.swift`。
- 影响 `apps/ios/MarkerApp/Sources/Features/History/HistoryView.swift`。
- 影响 `apps/ios/MarkerApp/Tests` 与 `apps/ios/MarkerApp/UITests`。
- 不改变共享领域契约和持久化 schema。
