## MODIFIED Requirements

### Requirement: iOS 本地数据层必须持久化追踪项、记录与偏好数据
iOS 本地数据层必须（MUST）在应用重启后保留 `Tracker`、`TrackingEntry` 和 `UserPreference` 数据，并将共享领域契约映射到稳定的本地存储结构。

其中 `TrackingEntry` 的 payload 必须被完整持久化，并在应用重启后按原始类型和字段恢复。

#### Scenario: 应用重启后保留带 payload 的记录
- **WHEN** 用户创建一条包含结构化 payload 的追踪记录并完全退出应用后再次打开
- **THEN** 该记录仍然存在
- **AND** 记录中的 payload 类型和字段值保持不变

### Requirement: 本地数据层必须支持统计所需的基础查询
本地数据层必须（MUST）提供读取活跃追踪项、读取某日记录、读取时间范围内记录和读取周内完成次数的能力，以支撑 Today、历史与统计功能。

#### Scenario: Today 与统计视图请求数据
- **WHEN** Today 或统计视图发起数据读取
- **THEN** 本地数据层可以返回活跃追踪项、今日记录状态和指定范围的记录
- **AND** 返回的记录包含可被界面和统计解释的 payload
- **AND** 周配额追踪项可以读取当前周已完成次数
