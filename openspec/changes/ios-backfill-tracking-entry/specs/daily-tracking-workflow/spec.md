## ADDED Requirements

### Requirement: iOS 用户必须能够为历史逻辑日补记记录

iOS 应用必须（MUST）允许用户选择不晚于当前逻辑日的历史 `dayKey`，并为该日的活跃 tracker 创建记录。

#### Scenario: 用户为过去日期补记一条记录

- **GIVEN** 用户已经创建至少一个活跃 tracker
- **WHEN** 用户在 History 中选择一个过去日期和 tracker 并保存记录
- **THEN** 系统会为所选 tracker 和所选 `dayKey` 保存一条 `TrackingEntry`
- **AND** History 中对应日期会展示该记录的 payload 摘要
- **AND** Today 的当前逻辑日状态不会被错误改动

#### Scenario: 用户补记已有记录的同一天同 tracker

- **GIVEN** 某个 tracker 在所选历史 `dayKey` 已经有记录
- **WHEN** 用户从补记入口选择同一日期和 tracker
- **THEN** 记录编辑器会展示已有 payload
- **AND** 保存后系统覆盖同一条逻辑记录，而不是创建重复记录
