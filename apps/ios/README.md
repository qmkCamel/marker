# iOS

iOS 是当前阶段唯一实际落地的客户端。

目录约定：
- `MarkerApp`：SwiftUI 应用壳子与测试
- `Packages/MarkerDomain`：领域边界
- `Packages/MarkerData`：数据层边界
- `Packages/MarkerDesignSystem`：设计系统边界

生成工程：
- 在当前目录运行 `xcodegen generate`
- 打开 `MarkerApp.xcodeproj`

## 自动化

iOS 自动化优先复用开源工具和 MCP，而不是在仓库里维护大量 shell 脚本。

首选工具：
- `XcodeBuildMCP`：构建、测试、模拟器管理、安装、启动、截图、录屏和基础 UI 调试
- `Maestro`：可重复的 UI flow，用于 smoke、创建追踪项等交互流程
- `XCUITest`：官方 UI smoke test，验证 App 可以启动并访问四个顶层入口

默认项目参数：
- project：`apps/ios/MarkerApp.xcodeproj`
- scheme：`MarkerApp`
- bundle id：`com.edge.marker`
- simulator：`iPhone 17`
- artifacts：`artifacts/ios`

UI testing launch arguments：
- `--uitesting`
- `--reset-data`
- `--seed-demo-data`

这些参数会让 App 使用稳定 demo 数据，避免自动化截图和 UI 测试被本地真实数据影响。

常用 fallback 命令：

```bash
cd apps/ios
xcodegen generate
xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'
```

Maestro flow：

```bash
maestro test .maestro/ios-smoke.yaml
maestro test .maestro/ios-create-tracker.yaml
```

截图和录屏：

```bash
mkdir -p artifacts/ios/screenshots artifacts/ios/videos
xcrun simctl io booted screenshot artifacts/ios/screenshots/today.png
xcrun simctl io booted recordVideo artifacts/ios/videos/smoke.mp4
```

录屏命令会持续运行，结束时手动中断即可写入视频文件。截图、录屏、日志和 result bundle 应输出到 `artifacts/ios`，该目录不会进入 Git。

可选工具边界：
- `Midscene` 适合后续探索式视觉调试，不作为首轮必需验证链路
- `StoreScreens` 适合后续截图矩阵或发布素材生成，不作为当前 iOS smoke 基建依赖
