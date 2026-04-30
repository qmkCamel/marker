# Scripts

这里放仓库级辅助脚本，例如：
- 工程初始化
- 校验命名
- 自动生成辅助命令

当前阶段不把 iOS 自动化能力从头写成大量 shell 脚本。iOS 自动化优先使用：
- `XcodeBuildMCP`：构建、测试、模拟器、安装、启动、截图、录屏
- `Maestro`：可读、可重复的 UI flow
- `XCUITest`：官方 smoke test 与 UI 自动化基线

如果后续确实需要 `scripts/ios`，脚本只能作为薄 wrapper：
- 集中 Marker 默认 project / scheme / simulator / bundle id
- 委托给 XcodeBuildMCP、Maestro 或 Apple 原生命令
- 不重新实现工具已经提供的通用能力

本地自动化产物统一输出到 `artifacts/ios`，该目录应保持 Git ignored。
