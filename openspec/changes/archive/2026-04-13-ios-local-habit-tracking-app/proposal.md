## Why

仓库目前只有可运行的 iOS 壳子和领域契约，还没有真正可用的产品能力。要让应用进入“能正常使用”的状态，必须把本地持久化、习惯管理、今日打卡、历史查看和基础统计连成完整闭环。

## What Changes

- 为 iOS 引入基于 SQLite 的本地持久化能力，并将领域契约映射到可用的数据仓储实现。
- 实现习惯创建、编辑、归档和基础偏好设置。
- 实现 Today 视图中的应做习惯列表、打卡和取消打卡能力。
- 实现基础历史视图和基础统计视图，使用户可以回看和复盘自己的习惯记录。
- 将现有 iOS 占位页面替换为真实可交互的本地产品流。

## Capabilities

### New Capabilities

- `local-habit-storage`: 定义并实现 iOS 本地习惯、打卡和偏好数据的持久化能力。
- `habit-management-ui`: 提供习惯创建、编辑、归档和表单校验体验。
- `daily-tracking-workflow`: 提供 Today 视图中的应做列表、完成切换和进度反馈。
- `history-and-statistics`: 提供本地历史浏览、基础连胜和完成率统计能力。
- `basic-preferences`: 提供周起始日、默认统计窗口等本地偏好能力。

### Modified Capabilities

## Impact

- 影响 `apps/ios/Packages/MarkerData`、`apps/ios/Packages/MarkerDomain` 和 `apps/ios/MarkerApp`。
- 引入 `GRDB` 作为本地 SQLite 持久化依赖。
- 让 iOS 应用从占位壳子演进为真实可运行的本地习惯追踪产品。
