## Context

Marker iOS 当前已经支持 payload，因此 Today 可以从 `TrackingEntry.countsAsCompletion` 与 `TrackingEntry.summary` 推导更细的记录状态。这个 change 不需要新增领域字段，只需要把现有 Today 派生模型和 UI 从单列表升级为分区视图。

## Decisions

### 1. 派生模型先行

新增 `TodayOverview`，由 `TrackingEngine` 统一生成：

- `pendingItems`: 今天应出现但还没有记录的 tracker。
- `recordedItems`: 今天已有记录的 tracker。
- `summaryText`: Today 顶部低压力摘要。

SwiftUI 只消费这些派生状态，不在 View 内重复判断业务语义。

### 2. 记录存在与完成语义分离

`hasRecord` 表示这一天保存过记录；`isCompleted` 表示 payload 是否计入完成。用药 `.skipped` 会出现在已记录分区，但 `isCompleted == false`，并使用温和提示说明不计入服用。

### 3. Today 主操作按类型命名

不再统一显示 `记录`：

- habit: 图标按钮，快速保存 completion。
- medication: `确认`。
- cycle: `记录状态`。
- custom: `写记录`。

### 4. 本轮保留现有创建入口

创建模板化是后续 change。本轮加号仍打开现有 `TrackerEditorView`，避免把 Today 重构和创建流程混在一起。

## Verification

```bash
openspec validate ios-today-care-confirmation --strict
cd apps/ios
xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'
```
