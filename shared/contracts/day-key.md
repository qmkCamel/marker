# Day Key

## 核心概念

- `dayKey`：逻辑日键，格式固定为 `YYYY-MM-DD`
- `recordedAt`：真实记录时间戳
- `recordedTimeZoneIdentifier`：计算 `dayKey` 时使用的时区

## 设计原则

- 事件发生在某个时间点，但完成归属于某个逻辑日
- 历史、连胜、统计、月历都以存下来的 `dayKey` 为准
- 用户后来切换时区时，旧记录不得被静默挪到新的逻辑日

## 示例

- 用户在 `Asia/Shanghai` 于 `2026-04-14 00:30` 完成
  - `dayKey = 2026-04-14`
  - `recordedAt = 2026-04-13T16:30:00Z`
  - `recordedTimeZoneIdentifier = Asia/Shanghai`

- 用户之后飞到别的时区查看历史
  - 仍然按已存下来的 `dayKey = 2026-04-14` 解释这次完成

## 使用要求

- `dayKey` 是日级业务主键，不是时间戳
- 新增存储和统计能力时，不得只靠 `recordedAt` 反推逻辑日
