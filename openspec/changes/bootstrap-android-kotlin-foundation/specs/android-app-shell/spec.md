## ADDED Requirements

### Requirement: Android 工作区提供可运行的应用壳子
Android 工作区必须（MUST）构建并运行一个基于 Kotlin 和 Jetpack Compose 的应用壳子，在业务功能尚未实现前为后续 Android 开发提供具体起点。

#### Scenario: 应用启动进入主导航壳子
- **WHEN** Android 应用在应用此变更后启动
- **THEN** 用户会看到一个基于底部导航的应用壳子
- **AND** 壳子暴露 `Today`、`History`、`Statistics` 和 `Settings` 作为顶层入口
- **AND** 每个入口都会渲染占位页面，以确认导航链路已接通

### Requirement: Android 工作区使用可复现的工程构建方式
Android 工作区必须（MUST）使用受版本控制的 Gradle 配置和命令来描述应用工程，使协作者无需手工创建工程文件也能复现该壳子。

#### Scenario: 开发者从版本控制配置构建 Android 工程
- **WHEN** 开发者在 `apps/android` 中运行文档记录的 Gradle 构建命令
- **THEN** Android 工程可以成功解析并构建
- **AND** 构建结果包含应用模块和所需的库模块依赖

### Requirement: Android 壳子强制执行模块化边界
Android 壳子必须（MUST）将应用入口、稳定的业务抽象、数据基础设施和共享 UI 构件拆分到独立模块中，并保持明确的依赖方向。

#### Scenario: 应用模块组合基础模块依赖
- **WHEN** 开发者查看 Android 工程模块依赖
- **THEN** 应用模块依赖 `domain`、`data` 和 `designsystem`
- **AND** `data` 依赖 `domain`
- **AND** `designsystem` 不依赖业务模块或存储实现模块
- **AND** `domain` 不依赖 UI 层或存储实现层
