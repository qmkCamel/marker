# ai-code-generation-boundaries Specification

## Purpose
定义 AI 生成代码时必须遵守的真相源边界、模块边界和仓库级代码约束，防止生成结果破坏架构一致性，并避免平台代码擅自演化出新的共享语义。

## Requirements
### Requirement: AI 生成代码必须尊重仓库真相源边界
系统必须（MUST）要求 AI 生成代码把已经批准的 OpenSpec specs 和 `shared/contracts` 视为行为与领域语义的真相源。

#### Scenario: AI 新增或修改面向领域的代码
- **WHEN** AI 助手生成会触及领域模型、功能行为或跨端契约的代码
- **THEN** 生成结果必须遵循 `openspec/specs` 中定义的行为
- **AND** 领域字段与共享语义必须与 `shared/contracts` 保持一致
- **AND** 助手不得在未经批准的 change 之外发明新的共享字段或规则

### Requirement: AI 生成代码必须保持明确的模块边界
系统必须（MUST）要求 AI 生成代码落在合适的 app、service、package 或 shared 工作区内，而不是为了“复用”随意创建跨仓库边界的抽象。

#### Scenario: AI 提议新增一个共享抽象
- **WHEN** AI 助手考虑往 `shared` 中新增代码，或引入新的跨端抽象
- **THEN** 只有在已批准的 spec 明确要求时才允许这样做
- **AND** 在没有共享契约支撑时，平台专属代码应保留在其所属工作区内

### Requirement: AI 生成代码必须遵守仓库编码约束
系统必须（MUST）要求 AI 生成代码遵守仓库既定的编码约束，包括显式类型要求和文件规模上限。

当前仓库约束至少包括：
- 遵守面向 SOLID 的拆分方式
- `JavaScript` 和 `TypeScript` 文件在超过 600 行前必须按职责拆分
- 在类型化语言与当前代码风格允许的前提下，函数参数保持显式类型

#### Scenario: AI 生成一个逐渐变大的 TypeScript 模块
- **WHEN** AI 助手生成或扩展某个 `JavaScript` 或 `TypeScript` 文件，并接近 600 行上限
- **THEN** 助手必须在文件变得过大前按职责进行拆分
- **AND** 生成的函数参数在语言和代码风格支持时必须保持显式类型

