# platform-placeholders Specification

## Purpose
定义 Android、Web、backend 与共享工作区的占位边界，使未来扩展时有清晰落点，但不提前锁定技术栈。

## Requirements
### Requirement: 未定平台暴露明确的占位边界
仓库必须（MUST）为 Android、Web 和 backend 提供占位工作区，用于说明未来职责，而不是在技术选型确定前就承诺具体实现栈。

#### Scenario: 开发者检查某个占位平台工作区
- **WHEN** 开发者打开 `apps/android`、`apps/web` 或 `services/backend`
- **THEN** 工作区包含其预期职责的简短说明
- **AND** 工作区会说明实现栈当前仍有意保持未定或延期
- **AND** 工作区会标明它与共享契约和产品规格之间的预期关系

### Requirement: 共享跨端空间为可复用产品知识预留位置
仓库必须（MUST）提供专门的共享目录，用于承载产品知识、跨端契约和公共资源，使未来各端实现可以引用同一份真相源。

#### Scenario: 开发者查看共享工作区
- **WHEN** 开发者检查 `shared` 目录
- **THEN** 目录包含 `product`、`contracts` 和 `assets`
- **AND** 每个共享子目录都包含一段简短说明，描述其将承载的内容类型

