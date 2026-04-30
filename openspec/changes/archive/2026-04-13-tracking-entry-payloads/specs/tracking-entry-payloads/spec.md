## ADDED Requirements

### Requirement: 追踪记录必须支持结构化 payload
系统必须（MUST）让 `TrackingEntry` 携带结构化 payload，而不是只记录“发生了一次”这一事实。

#### Scenario: 开发者查看追踪记录模型
- **WHEN** 开发者查看 `TrackingEntry` 领域模型
- **THEN** 该模型包含用于表达记录内容的结构化 payload
- **AND** payload 不是松散的纯字符串备注

### Requirement: Payload 必须支持多种记录类型
系统必须（MUST）至少支持完成型、用药型、经期型和备注型 payload，以覆盖当前已知的扩展方向。

#### Scenario: 不同类型追踪项创建记录
- **WHEN** 用户为习惯、用药、经期或自定义备注型追踪项创建一条记录
- **THEN** 系统会生成与该类型匹配的 payload 结构
- **AND** payload 能表达该类型所需的核心字段

### Requirement: Payload 必须提供可展示和可计算的语义
系统必须（MUST）让 payload 提供可展示摘要和是否计入完成/记录统计的语义，以支撑 Today、History 和 Statistics。

#### Scenario: 历史或统计读取 payload
- **WHEN** 历史页或统计页读取某条追踪记录
- **THEN** 系统可以从 payload 生成可展示摘要
- **AND** 系统可以判断该记录是否应计入完成或记录统计
