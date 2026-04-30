# ios-automation-harness

## ADDED Requirements

### Requirement: iOS automation prioritizes open-source tools and MCP

仓库必须（MUST）优先通过现成开源工具和 MCP 建立 iOS 自动化闭环，避免从头维护完整的构建、模拟器、截图和录屏脚本。

#### Scenario: Build and test through XcodeBuildMCP or fallback commands

- **GIVEN** 开发者或 AI agent 位于仓库根目录
- **WHEN** 需要构建或测试 iOS app
- **THEN** 首选使用 XcodeBuildMCP 的 MCP tool 或 CLI
- **AND** 在 XcodeBuildMCP 不可用时，可以退回 `xcodegen`、`xcodebuild` 和 `xcrun simctl` 命令
- **AND** 仓库文档说明首选工具与 fallback 路径

#### Scenario: Capture screenshot and video through tool-backed workflow

- **GIVEN** iOS 模拟器已经启动且 `MarkerApp` 已安装
- **WHEN** 需要产出截图或录屏
- **THEN** 首选使用 XcodeBuildMCP 或 Maestro 支撑操作与捕获
- **AND** 在首选工具不可用时，可以退回 `xcrun simctl io screenshot` 或 `xcrun simctl io recordVideo`
- **AND** 输出最终产物路径

### Requirement: Custom scripts remain thin wrappers

仓库可以（MAY）提供少量 `scripts/ios` wrapper，但这些 wrapper 不得（MUST NOT）重新实现 XcodeBuildMCP、Maestro 或 Apple 原生命令已经提供的通用能力。

#### Scenario: Run thin project wrapper

- **GIVEN** 仓库提供 `scripts/ios/smoke.sh`
- **WHEN** 开发者运行该脚本
- **THEN** 脚本只负责设置 Marker 默认 scheme、destination、bundle id、artifacts 路径等项目参数
- **AND** 具体构建、安装、启动、测试或截图能力委托给 XcodeBuildMCP、Maestro 或 Apple 原生命令

### Requirement: iOS automation artifacts are local outputs

仓库必须（MUST）定义本地自动化产物目录，并确保截图、录屏、日志和测试结果不会默认进入 Git。

#### Scenario: Automation writes artifacts under ignored directory

- **GIVEN** 任意 iOS 自动化工具产生截图、录屏、日志或 result bundle
- **WHEN** 产物写入文件系统
- **THEN** 产物位于 `artifacts/ios`
- **AND** `artifacts/` 被 `.gitignore` 忽略

### Requirement: iOS app supports deterministic UI testing mode

iOS 应用必须（MUST）支持 UI testing launch mode，使自动化流程可以重置数据并填充稳定 demo 数据。

#### Scenario: Launch app in seeded UI testing mode

- **GIVEN** `MarkerApp` 通过 UI test、Maestro 或工具脚本启动
- **WHEN** launch arguments 包含 `--uitesting`、`--reset-data` 和 `--seed-demo-data`
- **THEN** 应用清理本地测试数据
- **AND** 写入稳定 demo tracker 和 tracking entry 数据
- **AND** UI 首屏状态在重复运行之间保持一致

### Requirement: iOS UI tests cover top-level smoke flow

iOS 工程必须（MUST）包含 UI test target，用于验证应用可以启动并访问四个顶层入口。

#### Scenario: Run iOS UI smoke test

- **GIVEN** 开发者位于仓库根目录
- **WHEN** 运行 iOS smoke 验证
- **THEN** 验证运行 `MarkerAppUITests`
- **AND** 测试验证 `Today`、`History`、`Statistics`、`Settings` 四个入口可访问
- **AND** result bundle 或日志输出到 `artifacts/ios`

### Requirement: iOS UI exposes stable automation anchors

iOS UI 必须（MUST）为关键自动化节点提供稳定 accessibility identifiers 或可执行的稳定文案锚点。

#### Scenario: Automation locates top-level screens and tabs

- **GIVEN** `MarkerApp` 已启动
- **WHEN** UI test、Maestro flow 或 AI 自动化工具查找顶层 tab
- **THEN** 可以通过 `screen.today`、`screen.history`、`screen.statistics`、`screen.settings` 断言对应页面已展示
- **AND** 可以通过 SwiftUI tab bar 暴露的稳定入口切换 tab
- **AND** 当 tab item 的 accessibility identifier 未被系统透出时，可以使用 `Today`、`History`、`Statistics`、`Settings` 作为可执行 fallback

#### Scenario: Automation locates tracker editor controls

- **GIVEN** 追踪项编辑界面已展示
- **WHEN** UI test、Maestro flow 或 AI 自动化工具填写并保存追踪项
- **THEN** 可以通过 `trackerEditor.name`、`trackerEditor.save`、`trackerEditor.cancel` 定位关键控件

### Requirement: Maestro flows describe repeatable iOS UI interactions

仓库必须（MUST）提供 Maestro flow，用于描述可重复的 iOS UI 操作路径，并支撑 AI 生成截图或录屏前的稳定操作。

#### Scenario: Run Maestro smoke flow

- **GIVEN** Maestro 已安装
- **AND** iOS 模拟器已启动
- **WHEN** 运行 smoke flow
- **THEN** flow 启动 `MarkerApp`
- **AND** 访问 Today、History、Statistics、Settings
- **AND** 在失败时保留可用于调试的日志或报告

### Requirement: Midscene and StoreScreens remain optional extensions

仓库可以（MAY）在文档中说明 Midscene 与 StoreScreens 的使用边界，但首轮自动化基建不得（MUST NOT）依赖它们才完成构建、测试、截图或录屏。

#### Scenario: Run core automation without optional AI visual tools

- **GIVEN** 本地没有配置视觉模型 API key
- **AND** 本地没有安装 StoreScreens
- **WHEN** 开发者运行 iOS build、test、smoke、screenshot 或 record 工作流
- **THEN** 核心自动化仍然可以在不依赖 Midscene 或 StoreScreens 的情况下运行
