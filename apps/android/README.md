# Android

Android 端当前已确定技术栈为 `Kotlin + Jetpack Compose`，并提供一个可构建运行的本地 tracker 应用。

补充文档：
- 技术架构说明见 `ARCHITECTURE.md`

当前模块：
- `app`：应用入口、底部导航、Today / History / Statistics / Settings 和应用级状态装配
- `domain`：对齐 `shared/contracts` 的 `Tracker` / `TrackingEntry` 领域对象、`dayKey` 语义和频率规则
- `data`：基于 Room/SQLite 的本地 tracker 存储、查询与旧 habit 数据迁移
- `designsystem`：基础 spacing、corner radius 等 UI token

当前职责：
- 承接本地追踪项记录的 Android 客户端实现
- 消费 `shared/contracts` 中约定的共享数据语义
- 对齐 `shared/product` 中定义的信息架构与交互流程

当前不做：
- 不引入提醒调度、账号、同步或复杂图表
- 不引入 KMP 或跨端共享代码生成

常用命令：
- 构建 Debug App：`./gradlew :app:assembleDebug`
- 运行 App 单元测试：`./gradlew :app:testDebugUnitTest`
- 运行数据层测试：`./gradlew :data:testDebugUnitTest`
- 运行领域层测试：`./gradlew :domain:test`
- 查看工程帮助：`./gradlew help`
