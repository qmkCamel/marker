## 1. Android 工程基线

- [x] 1.1 在 `apps/android` 初始化 Gradle Wrapper、`settings.gradle.kts`、根 `build.gradle.kts`、`gradle.properties` 和 `gradle/libs.versions.toml`，并通过 `cd apps/android && ./gradlew tasks` 验证工程可解析。
- [x] 1.2 创建 `apps/android/app`、`apps/android/domain`、`apps/android/data` 和 `apps/android/designsystem` 模块及其 `build.gradle.kts`、`src/main`、`src/test` 目录，并通过 `cd apps/android && ./gradlew projects` 验证模块关系。

## 2. 领域与本地数据基础

- [x] 2.1 在 `apps/android/domain/src/main/kotlin` 实现与 `shared/contracts` 对齐的 `DayKey`、`Habit`、`HabitSchedule`、`CheckIn`、`UserPreference` 和边界协议，并在 `apps/android/domain/src/test/kotlin` 添加规则测试；验证命令：`cd apps/android && ./gradlew :domain:test`。
- [x] 2.2 在 `apps/android/data/src/main/kotlin` 实现 Room 数据库、实体、DAO、映射和 `MarkerLocalStore`，覆盖习惯、打卡、偏好及周完成次数查询，并在 `apps/android/data/src/test/kotlin` 添加持久化测试；验证命令：`cd apps/android && ./gradlew :data:testDebugUnitTest`。

## 3. 应用壳层与设计系统

- [x] 3.1 在 `apps/android/designsystem/src/main/kotlin` 实现基础 spacing、corner radius 和占位页可复用 UI token，并通过 `cd apps/android && ./gradlew :designsystem:testDebugUnitTest` 验证模块可编译。
- [x] 3.2 在 `apps/android/app/src/main/kotlin` 实现应用入口、依赖装配、顶层目标定义、底部导航和四个 Compose 占位页面，使 App 启动即可进入 `Today / History / Statistics / Settings` 壳层，并在 `apps/android/app/src/test/kotlin` 添加壳层相关测试；验证命令：`cd apps/android && ./gradlew :app:testDebugUnitTest :app:assembleDebug`。

## 4. 文档与收尾验证

- [x] 4.1 更新 `apps/android/README.md`，记录 Android 已采用 `Kotlin + Jetpack Compose`、模块结构和构建/测试命令，并通过 `cd apps/android && ./gradlew help` 验证文档中的入口命令有效。
- [x] 4.2 运行完整验证：`cd apps/android && ./gradlew :domain:test :data:testDebugUnitTest :designsystem:testDebugUnitTest :app:testDebugUnitTest :app:assembleDebug`，确认 Android App 可构建且基础测试通过。
