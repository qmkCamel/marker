## Context

Marker 的产品路线已经调整为 iOS-first。接下来 iOS UI 会频繁迭代，AI 需要能够在同一轮工作中完成代码修改、构建验证、启动模拟器、操作关键流程、截图/录屏，并把产物交给用户确认。

当前已确认的本地条件：

- `xcodegen` 可用
- `xcodebuild` 可用
- iOS 26 / 26.1 模拟器可用
- `MarkerApp.xcodeproj` 存在，`MarkerApp` scheme 可解析

当前缺口：

- 没有项目级 XcodeBuildMCP / Maestro 配置
- 没有 UI test target
- 没有稳定的 UI testing launch mode
- 没有 demo seed/reset 机制
- 没有截图/录屏产物目录约定
- 没有对 Midscene / StoreScreens 等后续工具的边界说明

## Goals / Non-Goals

**Goals:**

- 优先使用开源工具和 MCP 完成 iOS build、test、simulator、install、launch、screenshot、record。
- 让 UI 验证基于稳定模拟器、稳定 demo 数据和稳定 accessibility identifiers。
- 让截图和录屏产物固定输出到仓库内被忽略的 artifacts 目录。
- 用 XCUITest 承接稳定 smoke test，用 Maestro 承接可读、可维护的 UI flow。
- 为后续 Midscene AI 视觉调试、StoreScreens 截图矩阵预留入口，但不把它们放进首轮必需链路。

**Non-Goals:**

- 不从头编写完整 iOS 自动化框架。
- 不把大量 `xcodebuild` / `simctl` 细节复制成项目自维护脚本。
- 不在本轮引入 App Store 截图生产线。
- 不在本轮引入 fastlane。
- 不要求 Midscene 进入 CI 或每次验证必跑。
- 不重构 iOS 产品功能。

## Decisions

### 1. XcodeBuildMCP 是首选自动化基座

首层自动化优先使用 XcodeBuildMCP 承接：

- 构建
- 单元测试与 UI 测试
- 模拟器发现、启动和管理
- 安装与启动 App
- 截图
- 录屏
- UI 调试与日志采集

理由：

- 它同时提供 MCP tool 和 CLI，适合 AI agent 与本地手动命令共用。
- 它已经封装大量 Xcode / simulator 细节，能减少仓库自维护脚本。
- 它比纯自然语言视觉自动化更确定，也比从头写 shell wrapper 更省维护成本。

Apple 原生命令仍作为 fallback，尤其是在 XcodeBuildMCP 未安装或 CI 环境尚未配置时使用。

### 2. 仓库只保留项目级薄配置和必要 wrapper

仓库不维护一整套厚重 `scripts/ios` 实现。首轮只允许新增：

- XcodeBuildMCP 项目配置或说明
- Maestro flow
- artifacts 目录约定
- 少量可选 wrapper，例如 `scripts/ios/smoke.sh`，用于把项目默认 scheme、destination、bundle id、artifacts 路径集中起来

wrapper 不应重新实现 XcodeBuildMCP 已经提供的能力。

### 3. artifacts 只作为本地输出，不进入 Git

所有截图、录屏、result bundle、构建日志输出到：

- `artifacts/ios/screenshots`
- `artifacts/ios/videos`
- `artifacts/ios/logs`
- `artifacts/ios/results`

`artifacts/` 必须被 `.gitignore` 忽略。最终回复中可以引用绝对路径，让用户在 Codex app 里查看截图或视频。

### 4. UI test target 负责稳定 smoke test

新增 `MarkerAppUITests`，首轮覆盖：

- App 可以启动
- Today tab 可见
- History / Statistics / Settings tab 可切换
- 关键页面标题或主要内容存在

UI tests 使用 launch arguments：

- `--uitesting`
- `--reset-data`
- `--seed-demo-data`

这样每次截图或测试前都能回到确定状态。

### 5. 为关键 UI 添加自动化锚点

首轮需要为这些控件和区域加标识：

- `tab.today`
- `tab.history`
- `tab.statistics`
- `tab.settings`
- `screen.today`
- `screen.history`
- `screen.statistics`
- `screen.settings`
- `today.addTracker`
- `trackerEditor.name`
- `trackerEditor.save`
- `trackerEditor.cancel`

命名采用点分层级，保持平台内稳定。

实际验证中，SwiftUI `TabView` 的 tab item accessibility identifier 可能不会稳定透出到底层 tab bar button。实现仍在 tab label 上保留 `tab.*` 标识，UI test 和 Maestro flow 需要同时支持可见文案 fallback；screen 与 editor 控件继续使用 accessibility identifier 断言。

### 6. Maestro 作为首选开源 UI flow 工具

Maestro 用于描述可重复、可读的 UI 流程。首轮 flow 建议：

- `ios-smoke.yaml`
- `ios-create-tracker.yaml`
- `ios-record-today.yaml`

Maestro 适合作为 AI 交付截图/录屏前的操作脚本，因为它比纯自然语言视觉自动化更稳定，也比直接写大量 XCUITest 更轻。录屏本身优先由 XcodeBuildMCP 或 `xcrun simctl io recordVideo` 负责，Maestro 负责把 UI 操作到需要记录的状态。

### 7. Midscene 作为后续 AI 视觉调试增强

Midscene 不进入首轮必需实现。它适合后续处理：

- 让 AI 对当前 UI 做探索式审查
- 基于截图判断布局问题
- 用自然语言尝试临时操作流程

但它依赖视觉模型和 WebDriverAgent，稳定性、成本和环境变量复杂度都高于 Maestro，所以本轮只预留文档入口，不作为必跑验证。

### 8. StoreScreens 与 fastlane 后置

StoreScreens 适合后续生成截图矩阵，并且可结合 MCP / skill 工作流。fastlane snapshot 更适合 App Store 截图生产线。当前产品 UI 尚未稳定，二者暂不进入首轮必需实现。

## Risks / Trade-offs

- [XcodeBuildMCP 尚未安装导致流程不可跑] -> Mitigation: 文档记录安装方式，并保留 Apple 原生命令 fallback。
- [过度依赖 wrapper 导致重复造轮子] -> Mitigation: wrapper 只集中项目默认参数，不重写工具能力。
- [模拟器状态污染导致截图不稳定] -> Mitigation: 使用 `--reset-data` 和 `--seed-demo-data`。
- [Accessibility identifiers 增加 UI 代码噪音] -> Mitigation: 只给测试和自动化需要的关键节点加标识。
- [Maestro 与 XCUITest 重叠] -> Mitigation: XCUITest 管 CI 和官方 smoke test，Maestro 管可读 flow、人工/AI 调试和录屏操作。
- [Midscene 能力诱人但引入模型变量] -> Mitigation: 首轮不作为必需链路，等基础自动化稳定后再单独评估。

## Verification

首轮实现完成后应能通过 XcodeBuildMCP 或 fallback 命令完成：

```text
generate project
build MarkerApp
test MarkerAppTests
test MarkerAppUITests
boot simulator
install MarkerApp
launch MarkerApp with --uitesting --reset-data --seed-demo-data
capture screenshot to artifacts/ios/screenshots
record video to artifacts/ios/videos
run Maestro smoke flow
```

并在 `artifacts/ios` 下看到对应日志、截图、录屏或 result bundle。
