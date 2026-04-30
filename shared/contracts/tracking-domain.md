# Tracking Domain

## 源数据对象

### Tracker

- `id`：稳定唯一标识
- `kind`：追踪项类型，例如习惯、用药、经期或自定义
- `name`：追踪项名称
- `colorToken`：展示用颜色 token
- `notes`：备注
- `schedule`：追踪项频率规则
- `isArchived`：是否归档
- `createdAt`：创建时间
- `updatedAt`：更新时间

### TrackingEntry

- `id`：稳定唯一标识
- `trackerId`：所属追踪项标识
- `dayKey`：逻辑日键，格式为 `YYYY-MM-DD`
- `recordedAt`：实际记录时间戳
- `recordedTimeZoneIdentifier`：生成 `dayKey` 时使用的时区标识
- `payload`：结构化记录内容

### TrackingPayload

- `completion`：完成型记录，可选备注
- `medication`：用药记录，包含状态、可选剂量、单位和备注
- `cycle`：经期记录，包含流量、症状和备注
- `note`：纯备注型记录

### TrackerReminder

- `id`：稳定唯一标识
- `trackerId`：所属追踪项标识
- `localTime`：本地提醒时间
- `weekdays`：提醒生效的星期集合
- `isEnabled`：是否启用

### UserPreference

- `weekStartsOn`：周起始日
- `defaultHomeTab`：默认首页 tab
- `preferredStatisticsWindow`：默认统计窗口

## 派生对象

下面这些对象不是主存储真相，而是由源数据计算出来的只读结果：

- `Streak`
- `CompletionRate`
- `StatisticsSummary`

## 约束

- 追踪项优先使用归档，不直接破坏性删除
- 历史、连胜、统计一律基于 `dayKey` 解释每日记录情况
- 平台实现不得私自增加与共享语义冲突的主字段
