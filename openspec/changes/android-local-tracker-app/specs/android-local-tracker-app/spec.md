## ADDED Requirements

### Requirement: Android 必须使用 Tracker 语义实现本地追踪应用
Android 工作区必须（MUST）使用 `Tracker`、`TrackingEntry`、`TrackerKind` 和相关偏好语义实现本地追踪应用，而不是继续以 `Habit` 作为核心实体名词。

#### Scenario: 开发者查看 Android 领域与数据层
- **WHEN** 开发者查看 Android 的领域模型、数据模型和应用层接口
- **THEN** 核心对象使用 `Tracker` / `TrackingEntry` 语义
- **AND** 用户可见文案使用“追踪项”和“记录”等表述
- **AND** Android 实现不会再把 `Habit` 作为主实体总名词

### Requirement: Android 本地数据层必须支持旧 habit 数据迁移
Android 本地数据层必须（MUST）在切换到 tracker schema 时保留旧版本中已经保存的追踪数据，并将旧 `habit` / `checkIn` 结构迁移到新的 tracker / trackingEntry 结构。

#### Scenario: 旧版本用户升级到 tracker 版本
- **WHEN** 设备上已有旧 Android 版本写入的 `Habit` 与 `CheckIn` 数据，用户升级到新版本
- **THEN** 系统会将旧数据迁移到 `trackers` 与 `trackingEntries`
- **AND** 原有名称、颜色、备注、频率、归档状态和历史记录保持可读
- **AND** 旧 `habitId` 与 `completedAt` 会分别映射到 `trackerId` 与 `recordedAt`

### Requirement: Android 必须提供与当前 iOS 对齐的 Today 工作流
Android 工作区必须（MUST）提供可用的 Today 视图，使用户能够查看当天应做的追踪项、切换记录状态、查看进度并创建或编辑追踪项。

#### Scenario: 用户在 Today 中完成一个追踪项
- **WHEN** 用户在 Today 视图中点击某个应做追踪项的完成按钮
- **THEN** 系统会为该追踪项写入当前逻辑日的 `TrackingEntry`
- **AND** Today 列表立即显示已完成状态
- **AND** 今日进度会同步更新

#### Scenario: 用户从 Today 创建新的追踪项
- **WHEN** 用户在 Today 视图中打开新建入口并保存一个有效追踪项
- **THEN** 新追踪项会被持久化
- **AND** 如果该追踪项在当前逻辑日应做，它会出现在 Today 列表中

### Requirement: Android 必须提供历史、统计和基础设置能力
Android 工作区必须（MUST）提供历史记录浏览、基础统计摘要和设置页中的基础偏好与归档管理入口，使本地 tracker 应用形成完整闭环。

#### Scenario: 用户查看历史和统计
- **WHEN** 用户进入 History 或 Statistics 视图
- **THEN** History 会按 `dayKey` 展示每日记录明细
- **AND** Statistics 会基于本地 `Tracker` 与 `TrackingEntry` 数据展示汇总结果

#### Scenario: 用户在设置中修改偏好和恢复归档追踪项
- **WHEN** 用户在 Settings 视图中修改周起始日或统计窗口，或恢复一个已归档追踪项
- **THEN** 新偏好会被持久化
- **AND** 周配额与统计解释会读取最新偏好
- **AND** 恢复后的追踪项会重新回到活跃数据集中
