## Why

产品当前以 HabitKit 为参考实现，但真实使用场景已经明显超出“习惯”本身，例如慢性病吃药记录、月经记录和其他广义追踪项目。继续用 `Habit` 作为核心领域词，会把后续模型、文档和代码语义锁死在过窄的场景上。

## What Changes

- 将核心领域词从 `Habit` 体系泛化为 `Tracking` / `Tracker` 体系。
- 将共享契约、主规格和 iOS 代码中的核心类型与文案改为更广义的命名。
- 在领域模型中引入 `TrackerKind`，为未来扩展到习惯、吃药、经期和自定义追踪项预留分类语义。
- 保持当前本地可用产品能力不变，重点完成语义泛化而不是新增复杂业务。

## Capabilities

### New Capabilities

- `tracking-domain-generalization`: 定义从 Habit 语义迁移到通用 Tracking 语义的领域边界、命名和兼容约束。

### Modified Capabilities

- `habit-domain-contracts`: 将领域对象命名与说明从 Habit 语义改为更宽的 Tracker/Tracking 语义。
- `habit-schedule-rules`: 将频率对象从习惯语义调整为适用于追踪项的通用频率语义。
- `habit-management-ui`: 将 iOS 侧习惯管理界面与文案改为通用追踪项管理界面。
- `local-habit-storage`: 将本地存储层命名与数据映射调整为通用 Tracking 语义。
- `history-and-statistics`: 将历史与统计说明改为建立在 Tracker 与 TrackingEntry 真相源之上。

## Impact

- 影响 `shared/contracts`、`openspec/specs`、`apps/ios/Packages/MarkerDomain`、`apps/ios/Packages/MarkerData` 和 `apps/ios/MarkerApp`。
- 会带来较大范围命名重构，但不应破坏当前可运行能力。
- 为后续更广义的记录/追踪能力铺平语义基础。
