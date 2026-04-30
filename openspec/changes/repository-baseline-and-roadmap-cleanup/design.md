## Context

当前主工作区 `/Users/edge/side/marker` 中已经存在完整的多端基线：iOS 使用 SwiftUI + GRDB，Android 使用 Kotlin + Jetpack Compose + Room，OpenSpec 与共享契约也已经落地。但顶层 README 仍把 Android 描述为占位，产品 TODO 也没有反映 Android 与 iOS 的实际能力差异。

同时，`apps/android/domain/bin` 下的 Kotlin 文件属于生成输出或 IDE 输出，不应作为源码提交。继续开发前需要先让 Git 状态和文档状态更接近真实项目状态。

## Decisions

### 1. 本轮只做基线整理，不改变产品行为

本轮不会修改 iOS、Android 或共享契约的运行时代码。删除生成物、调整 README 和重排 TODO 都属于仓库维护与规划整理。

### 2. 顶层 README 以当前已落地平台为准

README 应说明 iOS 和 Android 都已有本地 tracker 基线，Web 与 backend 仍是占位。这样后续 agent 不会再把 Android 误判为未选型占位目录。

### 3. 产品 TODO 按依赖关系重排

下一阶段的真实瓶颈不是“模板是否存在”，而是跨端记录模型是否一致、记录能否补改删、Today 是否能表达照料状态。因此优先级应先围绕基线、payload、记录编辑和回看能力组织。

### 4. 生成目录用忽略规则兜底

在已有 build、`.gradle` 等规则基础上增加 `**/bin/`，避免 IDE 或编译器输出再次被加入 Git。

## Risks / Trade-offs

- [文档整理不能替代真实功能实现] -> Mitigation: TODO 重排只定义下一步顺序，不宣称相关能力已经完成。
- [忽略 `**/bin/` 可能覆盖未来某些手写目录] -> Mitigation: 当前仓库没有把 `bin` 作为源码目录的约定；如果未来需要发布脚本，可放在 `scripts` 或明确改规则。

## Verification

- 检查 `git status --short --untracked-files=all` 中不再出现 `apps/android/domain/bin`。
- 检查 README 与 Android/iOS README 的平台状态描述一致。
- 检查产品 TODO 的 P0/P1/P2 顺序能反映当前代码能力差异。
