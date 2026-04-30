## Why

Marker 接下来会先在 iOS 上做产品试点。用户期望 AI 不只是改代码，还能完成构建、运行、UI 调试、截图和录屏反馈，形成半自动或逐步全自动的开发闭环。

当前 iOS 工程已经具备 `XcodeGen`、`xcodebuild`、Swift 包和单元测试基础，本机也有可用模拟器。但仓库还缺少对现成自动化工具的项目级配置、UI test target、稳定 demo 数据、截图/录屏产物目录和可重复 UI flow。没有这些基建，AI 每次验证 UI 都需要临时拼命令，结果不稳定，也不方便把截图或录屏交付给用户检查。

## What Changes

- 为 iOS 增加自动化基建规格，优先复用开源工具和 MCP，而不是从头编写命令封装。
- 将 `XcodeBuildMCP` 作为首选 build / test / simulator / screenshot / recording 基座，并保留 Apple 原生命令作为 fallback。
- 将 Maestro 作为首选开源 UI flow 工具，用于可重复的交互流程和录屏前操作。
- 增加 iOS UI test 基线，支持 smoke test、关键页面截图和稳定 launch arguments。
- 为 SwiftUI 关键控件补充 accessibility identifiers，支撑 UI test、Maestro 和后续 AI 视觉调试。
- 仅在必要时新增轻量 `scripts/ios` wrapper，用于统一项目默认参数和 artifacts 输出。
- 后续可把 Midscene 作为 AI 探索/视觉调试增强，StoreScreens 作为发布截图矩阵工具。

## Capabilities

### New Capabilities

- `ios-automation-harness`: 定义 iOS 自动化开发闭环，包括 XcodeBuildMCP、Maestro、XCUITest、可选脚本入口、截图/录屏、demo 数据和开源工具集成边界。

### Modified Capabilities

无。

## Impact

- 影响 `apps/ios/project.yml`，增加 UI test target 和 scheme 配置。
- 影响 `apps/ios/MarkerApp`，增加 UI testing launch mode、demo seed/reset 入口和 accessibility identifiers。
- 新增 `apps/ios/MarkerApp/UITests`。
- 新增项目级自动化配置、`.maestro` flow 和 `artifacts/ios` 输出目录约定。
- 可选新增少量 `scripts/ios` 薄 wrapper，避免重复项目路径、scheme、destination 等参数。
