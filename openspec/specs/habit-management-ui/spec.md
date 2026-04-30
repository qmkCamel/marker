# habit-management-ui Specification

## Purpose
定义 iOS 侧通用追踪项的创建、编辑、归档与表单校验体验。
## Requirements
### Requirement: 用户必须能够创建新追踪项
系统必须（MUST）允许用户在 iOS 应用中创建新追踪项，并配置类型、名称、颜色、备注和支持的频率类型。

#### Scenario: 用户创建一个每日追踪项
- **WHEN** 用户填写有效名称并保存一个每日追踪项
- **THEN** 新追踪项会被持久化
- **AND** 该追踪项会出现在 Today 视图中

### Requirement: 用户必须能够编辑和归档已有追踪项
系统必须（MUST）允许用户修改已有追踪项，并支持将追踪项归档，使其不再出现在活跃的 Today 列表中。

#### Scenario: 用户归档一个追踪项
- **WHEN** 用户在编辑页将某个追踪项归档
- **THEN** 该追踪项不会再出现在活跃 Today 列表中
- **AND** 历史记录和统计仍然保留此前与该追踪项相关的数据

### Requirement: 追踪项表单必须阻止无效输入
系统必须（MUST）阻止用户保存无效追踪项，例如空名称、空星期集合的 `weeklyOnDays`，或小于 1 的 `weeklyQuota` 目标。

#### Scenario: 用户尝试保存无效频率设置
- **WHEN** 用户填写空名称或无效频率参数后点击保存
- **THEN** 表单不会保存
- **AND** 界面会显示可理解的校验提示

