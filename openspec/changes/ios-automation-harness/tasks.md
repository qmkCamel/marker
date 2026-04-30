## 1. 工具基座与项目配置

- [x] 1.1 记录 XcodeBuildMCP 安装与使用方式，并明确 MCP tool / CLI 是 iOS 自动化首选入口；验证方式：人工检查文档包含 build、test、simulator、screenshot、recording 的工具边界。
- [x] 1.2 增加项目级自动化配置或说明，集中记录 Marker 的 iOS project、scheme、bundle id、默认模拟器和 artifacts 路径；验证方式：人工检查配置或文档可被 AI agent 直接读取。
- [x] 1.3 更新 `.gitignore`，忽略 `artifacts/`；验证命令：`git check-ignore artifacts/ios/screenshots/example.png`。
- [x] 1.4 本轮判定不新增 `scripts/ios` wrapper，仅保留文档边界；后续如确有必要，wrapper 只负责项目默认参数，不重新实现工具能力。

## 2. iOS UI test 基线

- [x] 2.1 更新 `apps/ios/project.yml`，新增 `MarkerAppUITests` target 并接入 `MarkerApp` scheme；验证命令：`cd apps/ios && xcodegen generate && xcodebuild -list -project MarkerApp.xcodeproj`。
- [x] 2.2 新增 `apps/ios/MarkerApp/UITests`，覆盖 App 启动与 Today / History / Statistics / Settings 顶层入口 smoke test；验证命令：通过 XcodeBuildMCP 或 fallback `xcodebuild test` 运行 UI tests。

## 3. 稳定 UI testing 状态

- [x] 3.1 在 iOS app 中处理 `--uitesting`、`--reset-data`、`--seed-demo-data` launch arguments；验证方式：重复运行 smoke 验证时 UI 初始状态一致。
- [x] 3.2 为 UI testing 模式提供稳定 demo trackers 与 entries，不影响正常 live 数据；验证方式：人工检查模拟器截图与测试断言。

## 4. 自动化标识

- [x] 4.1 为主要 screen 添加 accessibility identifiers，并为 SwiftUI tab 保留 identifier 与可见文案 fallback；验证命令：运行 UI smoke test。
- [x] 4.2 为 tracker editor 的 name、save、cancel 等关键控件添加 accessibility identifiers；验证命令：新增或更新 UI test 覆盖创建 tracker 的最短路径。

## 5. Maestro flow

- [x] 5.1 新增 `.maestro/ios-smoke.yaml`，覆盖四个顶层入口；验证命令：`maestro test .maestro/ios-smoke.yaml`（本机尚未安装 Maestro，待工具安装后执行）。
- [x] 5.2 新增 `.maestro/ios-create-tracker.yaml`，覆盖创建 tracker 的最低路径；验证命令：`maestro test .maestro/ios-create-tracker.yaml`（本机尚未安装 Maestro，待工具安装后执行）。
- [x] 5.3 记录如何结合 XcodeBuildMCP 或 Apple 原生命令产出录屏；验证方式：运行后在 `artifacts/ios/videos` 看到视频文件。

## 6. 文档与可选工具边界

- [x] 6.1 更新 `apps/ios/README.md`，记录 XcodeBuildMCP、Maestro、UI tests、模拟器要求和截图/录屏产物位置；验证方式：人工检查文档命令与工具边界一致。
- [x] 6.2 更新 `scripts/README.md` 或新增自动化说明，明确仓库优先使用开源工具/MCP，scripts 只作为薄 wrapper 或 fallback；验证方式：人工检查文档内容。
- [x] 6.3 可选补充 Midscene 使用说明，明确其用于探索式视觉调试，不作为首轮必需验证链路；验证方式：人工检查文档边界清晰。
- [x] 6.4 可选补充 StoreScreens 使用说明，明确其用于后期截图矩阵或发布素材，不作为首轮必需验证链路；验证方式：人工检查文档边界清晰。
