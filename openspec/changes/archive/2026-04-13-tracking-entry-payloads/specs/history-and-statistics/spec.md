## MODIFIED Requirements

### Requirement: 用户必须能够浏览历史完成记录
系统必须（MUST）提供历史视图，使用户可以查看过去逻辑日的记录情况，并进入某一天的记录明细。

历史明细必须展示由 payload 派生出的摘要，而不是只展示“记录了一次”。

#### Scenario: 用户查看过去某一天的记录
- **WHEN** 用户在历史视图中选择某个过去日期
- **THEN** 系统显示该逻辑日已记录的追踪项明细
- **AND** 每条明细会展示由 payload 生成的可读摘要

### Requirement: 统计计算必须建立在本地真相源数据之上
系统必须（MUST）由 `Tracker` 与 `TrackingEntry` 真相源数据及其 payload 语义推导统计结果，而不是依赖手工维护的冗余统计存储。

#### Scenario: payload 影响统计解释
- **WHEN** 统计视图读取一组带 payload 的记录
- **THEN** 系统会按 payload 的统计语义判断它们是否计入完成或记录摘要
- **AND** 不会仅凭记录存在与否就一律视为相同类型的完成
