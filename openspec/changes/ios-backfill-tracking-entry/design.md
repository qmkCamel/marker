## Context

iOS 当前已经支持 `TrackingEntryDraft(tracker:dayKey:existingEntry:)`，记录编辑器也会展示 draft 的 `dayKey`，数据层通过 `(trackerId, dayKey)` 唯一索引保存或覆盖记录。因此补记能力不需要新增领域字段，也不需要迁移数据库；缺口主要在应用状态与 History UI。

## Decisions

### 1. 从 History 提供补记入口

补记是回看场景的一部分，入口放在 History 页比放在 Today 更符合用户心智。首轮提供顶栏 `plus` 入口，打开补记选择 sheet。

### 2. 选择日期和 tracker 后再进入现有记录编辑器

补记选择页只负责两件事：

- 选择不晚于今天的日期
- 选择一个未归档 tracker

保存具体 payload 继续交给 `TrackingEntryEditorView`，避免为每种 tracker kind 复制表单。

### 3. 同一天同 tracker 已有记录时进入覆盖式编辑

底层 store 已经以 `(trackerId, dayKey)` 作为唯一键。补记路径会先查找现有 entry，如果存在则把它传给 draft，让编辑器呈现已有 payload 并在保存时覆盖同一条记录。

### 4. 本轮不处理完整删除与撤销

删除确认、撤销反馈和记录时间语义属于 `PRODUCT_TODO` 中后续 P0 项。本轮只允许沿用现有删除能力，不扩展交互承诺。

## Risks / Trade-offs

- [补记入口过于轻量] -> Mitigation: 先保证最短闭环可用，之后再结合记录编辑闭环统一打磨。
- [未来需要日期列表或日历视图] -> Mitigation: 当前使用系统 DatePicker，避免提前自研复杂日历。
- [已归档 tracker 是否可补记] -> Mitigation: 首轮只展示活跃 tracker，避免用户给已归档事项继续新增记录。

## Verification

```bash
openspec validate ios-backfill-tracking-entry --strict
cd apps/ios
xcodegen generate
xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'
```
