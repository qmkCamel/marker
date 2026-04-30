# ai-change-workflow Specification

## Purpose
定义 AI 大规模生成代码时的 change 工作流，确保非 trivial 改动先经过 OpenSpec，再进入实现。

## Requirements
### Requirement: 非 trivial 的 AI 生成改动先经过 OpenSpec
系统必须（MUST）要求所有非 trivial 的 AI 生成改动在开始多文件实现或行为变更前，先从一个 OpenSpec change 开始。

非 trivial 改动包括：
- 多文件代码改动
- 行为变更
- 新能力开发
- 跨模块边界的重构

#### Scenario: AI 被要求实现一个跨多文件功能
- **WHEN** AI 助手被要求实现一个非 trivial 的功能或行为变更
- **THEN** 工作会先通过创建或更新一个 OpenSpec change 开始
- **AND** 后续实现会遵循已经批准的 proposal、specs、design 和 tasks，而不是直接即兴生成代码

### Requirement: AI 生成的工作必须拆分为可独立验证的 change
系统必须（MUST）要求 AI 生成的改动聚焦在一个可独立验证的能力上，而不是把不相关的子系统混进同一个 change。

#### Scenario: 一个请求同时横跨不相关关注点
- **WHEN** AI 助手收到一个会同时触及不相关领域或平台的请求
- **THEN** 助手会把工作拆分为多个 OpenSpec change 或清晰分离的任务
- **AND** 每个结果 change 都只包含一个主要能力，并拥有独立的验证路径

### Requirement: AI 任务拆分必须标明精确变更面
系统必须（MUST）要求面向 AI 的任务计划在实现前指出将要修改的文件、目录或包。

#### Scenario: AI 准备实现任务清单
- **WHEN** 为 AI 驱动的工作创建 OpenSpec `tasks.md`
- **THEN** 每个任务都会标明它将触及的精确仓库范围
- **AND** 任务拆分足够小，可以在不进行大范围猜测性编辑的前提下执行和验证

