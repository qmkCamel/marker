## MODIFIED Requirements

### Requirement: 未定平台暴露明确的占位边界
仓库必须（MUST）为已确认技术栈的 Android 提供清晰的可运行工作区边界，并继续为尚未确认技术栈的 Web 和 backend 提供占位工作区，使不同平台在当前阶段的职责和成熟度都明确可见。

#### Scenario: 开发者检查各平台工作区
- **WHEN** 开发者打开 `apps/android`、`apps/web` 或 `services/backend`
- **THEN** `apps/android` 会说明其已采用 `Kotlin + Jetpack Compose` 并提供可运行工程的构建入口
- **AND** `apps/web` 与 `services/backend` 仍然说明其实现栈当前有意保持未定或延期
- **AND** 每个工作区都会标明它与共享契约和产品规格之间的预期关系
