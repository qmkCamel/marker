## 1. Tracker 语义与数据迁移

- [x] 1.1 在 `apps/android/domain/src/main/kotlin` 与 `apps/android/domain/src/test/kotlin` 中将 `Habit` / `CheckIn` / `Reminder` 等类型切换为 `Tracker` / `TrackingEntry` / `TrackerReminder`，补齐 `TrackerKind` 与相关规则测试；验证命令：`cd apps/android && ./gradlew :domain:test`。
- [x] 1.2 在 `apps/android/data/src/main/kotlin` 与 `apps/android/data/src/test/kotlin` 中将 Room schema、实体、DAO 和 `MarkerLocalStore` 升级为 tracker 语义，并补充旧 habit 数据迁移测试；验证命令：`cd apps/android && ./gradlew :data:testDebugUnitTest`。

## 2. 应用级状态与纯逻辑

- [x] 2.1 在 `apps/android/app/src/main/kotlin` 与 `apps/android/app/src/test/kotlin` 中实现 Android 版 `TrackingEngine`、`TrackerDraft`、`MarkerPresentation` 和相关测试，确保 Today、History、Statistics 的计算与表单校验对齐 iOS；验证命令：`cd apps/android && ./gradlew :app:testDebugUnitTest --tests \"*TrackingEngine*\" --tests \"*TrackerDraft*\"`。
- [x] 2.2 在 `apps/android/app/src/main/kotlin` 中实现 Android 版 `MarkerAppModel` / 状态装配，使 tracker、entry、preferences、错误状态与归档恢复逻辑通过单一模型协调；验证命令：`cd apps/android && ./gradlew :app:testDebugUnitTest --tests \"*AppDestination*\"`。

## 3. 真实页面对齐

- [x] 3.1 在 `apps/android/app/src/main/kotlin` 中将 `Today` 页面从占位实现升级为真实 tracker 列表、进度卡片、记录切换和新建/编辑入口，并通过针对性测试与构建验证其可编译；验证命令：`cd apps/android && ./gradlew :app:testDebugUnitTest :app:assembleDebug`。
- [x] 3.2 在 `apps/android/app/src/main/kotlin` 中实现 `History`、`Statistics`、`Settings`、归档列表和 tracker 编辑页面，完成基础本地 tracker 工作流闭环；验证命令：`cd apps/android && ./gradlew :app:testDebugUnitTest :app:assembleDebug`。

## 4. 文档与完整验证

- [x] 4.1 更新 `apps/android/README.md`，将工作区说明改为 tracker 语义，并记录真实功能范围和验证命令；验证命令：`cd apps/android && ./gradlew help`。
- [x] 4.2 运行完整 Android 验证：`cd apps/android && ./gradlew :domain:test :data:testDebugUnitTest :app:testDebugUnitTest :app:assembleDebug`，确认 Android 已对齐当前 iOS 的本地 tracker 应用基线。
- [x] 4.3 将 `apps/android` 中残留的历史 `Habit` 文件名清理为 tracker 命名风格，并通过 `cd apps/android && ./gradlew :domain:test :data:testDebugUnitTest :app:testDebugUnitTest` 验证重命名未破坏构建与测试。
- [x] 4.4 新增 `apps/android/ARCHITECTURE.md` 作为独立技术架构说明，并在 `apps/android/README.md` 提供入口链接；验证方式：人工检查文档内容与当前实现一致。
