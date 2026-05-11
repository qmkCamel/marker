## ADDED Requirements

### Requirement: iOS V1 产品交互稿必须覆盖核心页面

系统必须（MUST）提供一份 iOS V1 产品交互稿，覆盖首轮试点体验所需的核心页面与跨页面流程，包括 Today、创建追踪项、记录编辑器、History、Statistics、Settings 和归档管理。

#### Scenario: 开发者查看 iOS V1 交互稿

- **WHEN** 开发者打开产品交互稿
- **THEN** 文档说明 iOS V1 的顶层导航、核心页面职责和页面间跳转关系
- **AND** 文档覆盖习惯、用药、经期和自定义备注四类 tracker 的最低可用交互

### Requirement: iOS V1 产品交互稿必须明确记录状态语义

系统必须（MUST）在 iOS V1 产品交互稿中区分有记录、计入完成、已跳过和未记录等状态，避免把所有 tracker 都解释成习惯打卡完成。

#### Scenario: 设计师或开发者查看记录状态说明

- **WHEN** 设计师或开发者查看 Today、记录编辑器、History 或 Statistics 的交互说明
- **THEN** 文档说明记录是否存在和是否计入完成是两个不同语义
- **AND** 文档说明用药已跳过会保存为记录但不计入服用完成

### Requirement: iOS V1 产品交互稿必须保留后续实现拆分边界

系统必须（MUST）在 iOS V1 产品交互稿中提供后续可拆分的 OpenSpec change 顺序，使实现任务能按独立可验证能力推进。

#### Scenario: 开发者准备从交互稿进入实现

- **WHEN** 开发者查看交互稿的实现拆分建议
- **THEN** 文档列出 Today 信息架构、记录改删、创建模板、History 重构、Statistics 类型化和 Settings 信任感等独立改动方向
- **AND** 每个方向都能被后续 OpenSpec change 单独验证
