## MODIFIED Requirements

### Requirement: Today 视图必须提供清晰的空状态与进度反馈

系统必须（MUST）在没有活跃追踪项或当日无待办时，显示明确空状态，并在存在数据时提供当日照料确认反馈。

当存在当日追踪项时，Today 视图必须（MUST）区分尚未记录的 `待确认` 项与已经保存记录的 `今日已记录` 项。已保存记录必须（MUST）展示由 payload 派生出的摘要，并且不能只用完成率解释所有 tracker。

#### Scenario: 当前没有任何活跃追踪项

- **WHEN** 用户第一次进入应用且尚未创建任何追踪项
- **THEN** Today 视图显示引导性空状态
- **AND** 空状态提供创建追踪项入口

#### Scenario: Today 展示待确认和已记录分区

- **WHEN** 用户进入 Today 视图
- **AND** 当前逻辑日同时存在未记录 tracker 与已有记录 tracker
- **THEN** Today 视图展示 `待确认` 分区
- **AND** Today 视图展示 `今日已记录` 分区
- **AND** 已记录项展示 payload 摘要

#### Scenario: 用药跳过显示为已记录但不计入服用

- **WHEN** 用户今天保存了一条用药 `已跳过` 记录
- **THEN** 该 tracker 出现在 `今日已记录` 分区
- **AND** 该记录展示 `已跳过` 摘要
- **AND** Today 不会把该记录显示为服用完成
