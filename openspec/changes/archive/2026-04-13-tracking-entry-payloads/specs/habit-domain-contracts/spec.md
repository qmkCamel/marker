## MODIFIED Requirements

### Requirement: 系统定义规范化的共享追踪领域对象
系统必须（MUST）在任何持久化或功能实现将其视为稳定生产模型之前，先定义 `Tracker`、`TrackerKind`、`TrackerSchedule`、`TrackingEntry`、`TrackingPayload`、`TrackerReminder` 和 `UserPreference` 这些共享契约对象。

共享契约至少应包含：
- `Tracker`：`id`、`kind`、`name`、`colorToken`、`notes`、`schedule`、`isArchived`、`createdAt`、`updatedAt`
- `TrackingEntry`：`id`、`trackerId`、`dayKey`、`recordedAt`、`recordedTimeZoneIdentifier`、`payload`
- `TrackingPayload`：可表达完成型、用药型、经期型和备注型记录内容
- `TrackerReminder`：`id`、`trackerId`、`localTime`、`weekdays`、`isEnabled`
- `UserPreference`：`weekStartsOn`、`defaultHomeTab`、`preferredStatisticsWindow`

#### Scenario: 在实现前审阅共享契约
- **WHEN** 开发者查看已经批准的追踪领域契约
- **THEN** 核心对象及其必需字段会被明确记录
- **AND** 追踪项、频率、提醒和带 payload 的记录之间的关系会在不依赖具体存储 schema 的前提下得到说明

### Requirement: 派生统计必须与真相源契约分离
系统必须（MUST）将 `Streak`、`CompletionRate` 等汇总指标视为派生读取模型，而不是主真相源对象。

#### Scenario: 开发者规划历史或统计实现
- **WHEN** 开发者阅读共享追踪领域契约
- **THEN** 契约会将 `Tracker`、`TrackingEntry`、`TrackerReminder` 和 `UserPreference` 标识为真相源记录
- **AND** 契约会将连胜和汇总统计标识为由这些真相源记录与 payload 语义共同推导出来的结果
