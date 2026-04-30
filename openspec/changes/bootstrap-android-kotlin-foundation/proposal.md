## Why

仓库里的 Android 目前仍然只是占位目录，而 iOS 已经具备可运行的应用壳子、明确的模块边界，以及围绕共享契约建立的本地数据基础。为了让多端架构真正具备对照实现，并为后续 Android 功能开发提供稳定起点，需要把 Android 补到与当前 iOS 已落地部分一致的基线。

## What Changes

- 在 `apps/android` 中建立可运行的 Kotlin Android 工程，并使用 Jetpack Compose 提供四个顶层入口的应用壳子。
- 为 Android 建立与 iOS 对齐的模块边界，包括应用层、领域层、数据层和设计系统层。
- 引入 Android 本地 SQLite 数据基础，映射现有共享契约中的习惯、打卡和偏好语义，并提供与当前 iOS 一致的基础读取能力。
- 补充 Android 工作区文档、验证命令和基础测试，使该工作区从占位状态升级为可持续扩展的实现起点。

## Capabilities

### New Capabilities

- `android-app-shell`: 定义 Android 可运行应用壳子、可复现 Gradle 工程与清晰的模块边界。
- `android-local-storage-foundation`: 定义 Android 对齐共享契约的本地 SQLite 存储基础与最小查询能力。

### Modified Capabilities

- `platform-placeholders`: 将 Android 从“技术栈未定的占位工作区”调整为“已选定 Kotlin + Compose 的可运行客户端工作区”，同时保持 Web 和 backend 仍为占位。

## Impact

- 影响 `apps/android` 工作区及其 README、Gradle 工程与模块结构。
- 新增 Android 侧的 Kotlin、Compose、SQLite/Room 与单元测试依赖。
- 为后续 Android 端真实产品能力提供与 iOS 当前实现对齐的技术基线。
