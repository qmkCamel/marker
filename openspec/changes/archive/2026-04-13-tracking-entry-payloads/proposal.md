## Why

当前 `TrackingEntry` 只表达“某个追踪项在某一天记录了一次”，但无法承载更丰富的记录内容，例如吃药状态与剂量、经期流量与症状、纯文本备注等。要让 `Marker` 真正从“完成型打卡器”演进成“通用记录器”，必须让记录本身具备结构化 payload。

## What Changes

- 在领域层为 `TrackingEntry` 引入结构化 `TrackingPayload`，用于承载完成型、用药型、经期型和备注型记录内容。
- 为本地 SQLite 存储增加 payload 持久化字段与旧记录迁移逻辑，保证现有数据自动兼容到默认完成型 payload。
- 为 iOS App 增加基于 `TrackerKind` 的记录表单与历史展示，使不同追踪类型能够记录不同内容。
- 调整 Today 与统计逻辑，使其基于 payload 语义判断“是否算完成/记录”，而不是只凭记录存在与否。

## Capabilities

### New Capabilities

- `tracking-entry-payloads`: 定义 `TrackingEntry` 的结构化 payload 能力，以及不同追踪类型记录内容的领域语义。

### Modified Capabilities

- `habit-domain-contracts`: 扩展核心追踪领域对象，使记录支持结构化 payload。
- `local-habit-storage`: 扩展本地存储层以持久化和迁移 payload 数据。
- `daily-tracking-workflow`: 扩展 Today 记录流程，使其支持按追踪类型创建不同 payload。
- `history-and-statistics`: 扩展历史与统计能力，使其展示和计算 payload 驱动的数据。

## Impact

- 影响 `shared/contracts`、`openspec/specs`、`apps/ios/Packages/MarkerDomain`、`apps/ios/Packages/MarkerData` 和 `apps/ios/MarkerApp`。
- 需要数据库 schema 迁移，以兼容已有只包含完成型记录的本地数据。
- 为后续吃药记录、经期记录和更通用的自定义记录打下领域与存储基础。
