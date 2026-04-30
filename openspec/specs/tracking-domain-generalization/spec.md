# tracking-domain-generalization Specification

## Purpose
TBD - created by archiving change generalize-tracking-domain. Update Purpose after archive.
## Requirements
### Requirement: 核心领域词必须从 Habit 泛化到 Tracking 语义
系统必须（MUST）将核心领域词从仅适用于习惯场景的 `Habit` 语义，调整为可覆盖更广义记录/追踪场景的 `Tracker` / `Tracking` 语义。

#### Scenario: 开发者阅读领域层与共享契约
- **WHEN** 开发者查看共享契约、主规格或 iOS 领域层代码
- **THEN** 核心对象不再以 `Habit` 作为总名词
- **AND** 文档与代码会使用更广义的 Tracking 语义描述核心对象

### Requirement: 通用追踪模型必须保留现有本地能力
系统必须（MUST）在完成语义泛化后，仍然保留当前本地可用应用所需的创建、编辑、打卡、历史和统计能力。

#### Scenario: 领域重构后应用继续工作
- **WHEN** 通用 Tracking 语义替换原有 Habit 语义
- **THEN** 当前 iOS 应用仍可创建追踪项、记录完成、浏览历史和查看统计
- **AND** 不会因命名泛化导致现有本地能力中断

### Requirement: 领域模型必须为更广使用场景预留分类语义
系统必须（MUST）在核心追踪对象中提供分类语义，使未来可以表达习惯、吃药、经期和自定义追踪项等不同场景。

#### Scenario: 开发者定义新的追踪项类型
- **WHEN** 开发者为未来业务扩展查看核心追踪对象
- **THEN** 模型中存在可表达不同追踪场景的分类字段或等价结构
- **AND** 当前实现不会再把“习惯”默认视为唯一业务类型

