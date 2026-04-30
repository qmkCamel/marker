## Context

当前仓库中的 Android 仍然只是占位目录，而 iOS 已经具备了可运行的应用壳子、清晰的模块分层，以及围绕共享契约建立的本地 SQLite 基础。用户这次明确要求 Android 参考“当前已经实现的 iOS”，因此本轮要补齐的是 Android 的工程、导航壳子、模块边界、设计系统 token、领域类型和本地数据基础，而不是继续跟进 iOS 正在推进的真实产品闭环。

本轮变更的真相源边界如下：
- 行为规格来自 `openspec/specs` 与本次 change 下新增/修改的 specs。
- 领域语义来自 `shared/contracts`，Android 只能映射这些对象和规则，不能自行扩展跨端字段语义。
- 平台实现只允许落在 `apps/android` 与必要的 OpenSpec 文档中；不改动 iOS 现有实现与共享契约定义。

约束：
- Android 栈在本轮正式确定为 `Kotlin + Jetpack Compose`。
- 目标是让 Android App 可以构建并运行，同时保持与 iOS 相近的依赖方向：`App -> Domain / Data / DesignSystem`，`Data -> Domain`，`DesignSystem` 与 `Domain` 均不依赖业务实现层。
- 本轮不实现习惯创建、编辑、打卡、历史浏览和统计闭环，只提供与当前 iOS 一致的占位页面和基础本地数据能力。

## Goals / Non-Goals

**Goals:**
- 在 `apps/android` 中建立独立、可复现的 Android Gradle 工程与运行入口。
- 提供基于 Compose 的四个顶层入口：`Today`、`History`、`Statistics`、`Settings`。
- 建立 `app`、`domain`、`data`、`designsystem` 四个模块，并保持与当前 iOS 对齐的依赖方向。
- 在 `domain` 中定义与共享契约一致的 Android 领域类型，在 `data` 中建立基于 SQLite 的本地存储基础与最小查询能力。
- 提供有价值的自动化测试与明确的验证命令，确保 Android 工作区从占位状态升级为可运行起点。

**Non-Goals:**
- 不实现真实的习惯管理、Today 打卡、历史浏览、统计摘要与偏好设置交互。
- 不修改 `shared/contracts`、`shared/product` 或 iOS 现有代码来迎合 Android 实现。
- 不引入账号、同步、提醒调度、复杂图表或任何后端能力。
- 不尝试在本轮引入 KMP 或跨端共享代码生成。

## Decisions

### 1. 将 Android 工程局部收敛在 `apps/android` 内

Android 将在 `apps/android` 下拥有自己的 `settings.gradle.kts`、`build.gradle.kts`、Gradle Wrapper 与模块目录，而不是把 Android 构建配置提升到仓库根目录。这样可以保持多端单仓的边界清晰，也避免让 iOS 与未来 Web/backend 被 Android 工具链耦合。

备选方案：
- 在仓库根目录建立统一 Gradle 工程：会把无关平台拖进 Android 构建上下文，放弃。
- 继续只保留 README 占位：无法满足“可运行 App”的目标，放弃。

### 2. 采用 Kotlin DSL + Compose + Material 3 作为 Android 壳层基线

Android 壳层将使用 Kotlin DSL 描述 Gradle 配置，并以 Jetpack Compose 构建根导航与占位页。这样既与 iOS 的 SwiftUI 壳层心智模型接近，也能在最少样板代码下完成 Tab 壳和后续页面替换。

备选方案：
- 传统 View/XML：可以实现同样能力，但样板较重，与当前仓库“先建立清晰壳层”的目标不匹配，放弃。
- 在本轮继续保持 UI 技术未定：与用户已明确指定 Kotlin 且要求 App 可运行相冲突，放弃。

### 3. 模块边界直接镜像当前 iOS 的四层结构

Android 将创建以下模块：
- `app`：应用入口、根导航、依赖装配、占位页面。
- `domain`：纯 Kotlin 领域对象、`DayKey` 语义、频率规则和边界协议。
- `data`：SQLite/Room 数据库、实体映射、本地 store 与查询实现。
- `designsystem`：通用 spacing、corner radius、基础 Compose token。

依赖方向固定为：
- `app -> domain`
- `app -> data`
- `app -> designsystem`
- `data -> domain`
- `designsystem` 不依赖业务与数据模块
- `domain` 不依赖 UI 与存储模块

备选方案：
- 所有代码先塞进 `app`：短期更快，但会破坏与 iOS 对齐的模块边界，放弃。
- 进一步拆成更多 feature 模块：超出当前壳层阶段需要，放弃。

### 4. Android 本地数据基础使用 Room 映射 SQLite

虽然 iOS 侧使用的是 GRDB，但 Android 本轮的目标是“对齐语义和数据边界”，不是强行复制同一种 ORM/查询接口。因此 `data` 模块将基于 Room 落一个 `MarkerDatabase` 与 `MarkerLocalStore`，让底层仍然是 SQLite，同时把样板和查询复杂度保持在可控范围内。

数据模型与查询能力将对齐当前 iOS 已实现部分：
- `Habit`、`CheckIn`、`UserPreference` 的本地持久化结构
- 读取全部习惯、活跃习惯、归档习惯
- 读取全部打卡、按 `dayKey` 读取、按范围读取、按 `habitId + dayKey` 读取
- 保存与删除打卡
- 读取与保存偏好
- 按周读取完成次数

备选方案：
- 直接使用原生 `SQLiteOpenHelper`：SQL 控制力高，但首轮样板过多，放弃。
- 选择 SQLDelight：跨平台一致性更强，但会引入额外工具链和生成流程，超出当前基线目标，放弃。

### 5. 只把共享契约“翻译”为 Android 领域模型，不在共享层新增代码

由于仓库当前的跨端真相源是 `shared/contracts` 文档和 `openspec/specs`，不是共享 Kotlin/Swift 代码，本轮 Android 会在 `domain` 中实现与这些语义一致的本地 Kotlin 类型，而不是去 `shared/` 下新增未批准的跨端抽象。

备选方案：
- 直接新建共享 Kotlin 模块：会提前引入未批准的共享代码边界，放弃。
- 在平台代码里随意裁剪字段：会破坏跨端语义一致性，放弃。

### 6. 测试以“规则 + 本地存储 + 壳层可构建”为主

本轮验证分三层：
- `domain`：针对 `DayKey`、频率规则和边界导出的 JVM 单元测试。
- `data`：针对 Room store 的本地单元测试，验证主要读写与 `dayKey` / 周范围查询。
- `app`：至少验证顶层目标定义和壳层装配可通过构建；再通过 `assembleDebug` 确认 App 可以打包。

备选方案：
- 首轮就强依赖设备端 UI instrumentation：环境成本高，不利于当前仓库快速建立基线，放弃。

## Risks / Trade-offs

- [Android 使用 Room 而不是更底层 SQL 方案] -> Mitigation: 保持表结构和查询语义与 iOS 当前实现对齐，把“语义一致”放在首位而不是实现细节一致。
- [当前 iOS 代码里已有部分超出 `ios-app-shell` 主规格的实现] -> Mitigation: 在本轮 change 中显式把 Android 的壳层与本地数据基础拆成独立 capability，避免混淆为完整业务闭环。
- [Android 工作区从占位升级为真实工程后，`platform-placeholders` 的旧表述会过时] -> Mitigation: 同步修改该 spec，仅收窄 Android 的占位描述，保留 Web/backend 不变。
- [App 仍然是占位页面，容易被误解为已具备真实功能] -> Mitigation: 在 README、spec 和页面文案中明确说明当前只接通导航和基础边界。

## Migration Plan

1. 先通过 OpenSpec 定义 Android 壳层、本地存储基础与占位规范的变更边界。
2. 在 `apps/android` 初始化 Gradle 工程与四个模块，并让 App 先以占位页面成功启动。
3. 以测试优先方式补齐 `domain` 与 `data` 中的规则和本地 SQLite 基础。
4. 运行 Gradle 测试与构建命令，确认 Android App 可运行、可构建，再更新工作区说明文档。

## Open Questions

- 当前不阻塞实现。KMP、真实业务 UI、提醒调度和更高阶的 Android 架构拆分留到后续 change。
