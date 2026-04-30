## ADDED Requirements

### Requirement: Android 本地数据层必须持久化习惯、打卡与偏好数据
Android 本地数据层必须（MUST）在应用重启后保留 `Habit`、`CheckIn` 和 `UserPreference` 数据，并将共享领域契约映射到稳定的本地 SQLite 结构。

#### Scenario: 应用重启后保留已创建习惯
- **WHEN** Android 本地数据层保存一个习惯并重新创建 store
- **THEN** 该习惯仍然可以被读取
- **AND** 其名称、颜色、备注、频率和归档状态保持不变

### Requirement: Android 本地数据层必须使用 `dayKey` 作为日级业务真相源
Android 本地数据层必须（MUST）把 `dayKey` 作为历史、每日完成情况和统计查询的日级真相源，而不是仅依赖 `completedAt` 反推逻辑日。

#### Scenario: 查询某一天的完成记录
- **WHEN** 系统读取某个逻辑日的打卡记录
- **THEN** 查询结果按已存储的 `dayKey` 过滤
- **AND** 不会因为当前设备时区变化而重新解释已存储记录

### Requirement: Android 本地数据层必须支持基础查询能力
Android 本地数据层必须（MUST）提供读取活跃习惯、读取某日打卡、读取时间范围内打卡记录、读取偏好和读取周内完成次数的能力，以支撑后续 Today、历史与统计功能。

#### Scenario: Android 壳层请求基础数据
- **WHEN** 应用层请求活跃习惯、打卡记录或用户偏好
- **THEN** 本地数据层可以返回活跃习惯列表、按 `dayKey` 或范围过滤后的打卡记录以及当前偏好
- **AND** 周配额习惯可以读取当前周已完成次数
