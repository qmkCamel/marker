## Why

当前 iOS 已经演进为基于 `Tracker` / `TrackingEntry` 的本地追踪应用，而 Android 仍停留在 `Habit` 命名和占位 UI 阶段。为了让 Android 与当前产品真相和 iOS 已落地能力保持一致，需要把 Android 一次性升级为真实可用的本地 tracker 应用。

## What Changes

- 将 Android 领域模型、数据模型和应用层语义从 `Habit` / `CheckIn` 全量切换到 `Tracker` / `TrackingEntry`。
- 在 Android 本地存储中引入与 iOS 对齐的 tracker 表结构、追踪记录结构和旧 habit 数据迁移逻辑。
- 将 Android 端 Today、History、Statistics、Settings 从占位页面升级为与当前 iOS 对齐的真实本地工作流。
- 为 Android 补充追踪项创建/编辑/归档、Today 记录切换、历史浏览、统计摘要和基础偏好能力。
- 更新 Android 侧测试与文档，确保语义迁移后仍可稳定构建和验证。

## Capabilities

### New Capabilities

- `android-local-tracker-app`: 定义 Android 端基于 Tracker 语义的本地追踪应用能力，包括领域命名、存储迁移、Today、History、Statistics、Settings 和相关验证。

### Modified Capabilities

## Impact

- 影响 `apps/android/app`、`apps/android/domain`、`apps/android/data`、`apps/android/designsystem` 和 `apps/android/README.md`。
- 影响 Android 本地 SQLite/Room schema、API 命名和测试用例。
- 使 Android 从基础壳层升级为与当前 iOS 对齐的本地 tracker 应用实现。
