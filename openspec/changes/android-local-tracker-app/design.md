## Context

当前仓库中的 iOS 已经从 `Habit` 语义泛化到 `Tracker` / `TrackingEntry`，并且不仅完成了领域命名切换，还已经具备可运行的本地 Today、History、Statistics、Settings 工作流。相比之下，Android 虽然已经有 Kotlin + Compose + Room 的基础工程，但仍停留在 `Habit` / `CheckIn` 命名和占位页面阶段，无法与当前共享契约、主规格和 iOS 行为保持一致。

本轮变更的真相源边界如下：
- 行为规格以 `openspec/specs` 中已有的 `daily-tracking-workflow`、`habit-management-ui`、`history-and-statistics`、`basic-preferences`、`local-habit-storage`、`tracking-domain-generalization` 为准。
- 领域语义以 `shared/contracts/tracking-domain.md`、`shared/contracts/tracking-schedule.md` 和 `shared/contracts/day-key.md` 为准。
- iOS 是 Android 的当前对齐目标，但 Android 不复制 Swift 代码结构，只对齐语义、数据模型、页面能力和可验证行为。

约束：
- Android 保持 `Kotlin + Jetpack Compose + Room` 技术路线。
- 当前 Android 已有旧版 `Habit` schema 和 API，因此本轮必须把对齐当成一次可迁移升级，而不是重建新工程。
- 本轮不实现提醒调度、账号、同步或 Android 独有扩展能力，只对齐当前 iOS 已落地的本地 tracker 功能。

## Goals / Non-Goals

**Goals:**
- 将 Android 领域、数据和应用层从 `Habit` / `CheckIn` 迁移到 `Tracker` / `TrackingEntry` 语义。
- 为 Android Room 数据库引入 tracker 版 schema 与旧 habit 数据迁移逻辑。
- 落地与 iOS 对齐的 `MarkerAppModel`、`TrackingEngine`、`TrackerDraft` 和四个顶层页面。
- 提供 Today 记录切换、追踪项创建/编辑/归档、历史浏览、统计摘要和基础偏好能力。
- 用有价值的单元测试覆盖 Tracker 规则、Room store、TrackingEngine、TrackerDraft 和 App 顶层目标。

**Non-Goals:**
- 不修改共享契约与主规格的核心行为定义。
- 不引入 KMP、后台同步、通知调度、复杂图表或 Android 专属高级交互。
- 不为历史遗留命名做无关的大规模文件重命名；优先确保运行时语义和行为完整对齐。

## Decisions

### 1. 将 Android 对齐视为“应用升级迁移”，而不是“新建一套 tracker 应用”

Android 已经存在基于 `Habit` 的 domain/data/app 基线，因此本轮会在现有模块内完成命名、API、数据库和 UI 的升级，而不是丢弃旧模块重建。这样可以保留已有 Gradle、Compose 和 Room 基础，也为未来已安装旧版本时的数据连续性提供路径。

备选方案：
- 直接删除旧 `Habit` 代码并重写：实现更干净，但会失去旧数据迁移路径，放弃。
- 保留旧模型并增加一层映射：会让 Android 长期背负双重语义，放弃。

### 2. Room schema 升级到 tracker 结构，并提供从旧 habit 表迁移

Android 当前 Room 层将升级到新版本，主表调整为 `trackers`、`trackingEntries`、`userPreferences`。迁移策略将参考 iOS：如果已有旧 `habits` / `checkIns` 数据，则复制到新表，并把 `habitId` 映射为 `trackerId`，`completedAt` 映射为 `recordedAt`，默认 `kind = habit`。

备选方案：
- 保持旧表名，只在 Kotlin 层换名：会让存储语义长期与共享契约脱节，放弃。
- 不做迁移，直接清空旧数据：不符合“已存在基线应用升级”的预期，放弃。

### 3. Android 复用 iOS 的“一个应用模型 + 一个纯计算引擎”分工

Android 将新增一个应用级状态模型负责持久化交互、刷新和错误状态，同时把 Today/History/Statistics 的派生计算收敛到纯 Kotlin `TrackingEngine` 中。这样可以与 iOS 的 `MarkerAppModel` + `TrackingEngine` 结构对齐，也让测试更多落在纯逻辑层，而不是 UI 细节。

备选方案：
- 每个页面各自直接调 Room：短期可行，但会造成 Today/统计重复计算和状态不一致，放弃。
- 全部逻辑塞进 Compose 页面：测试困难且边界混乱，放弃。

### 4. Compose UI 直接对齐当前 iOS 的信息架构和最低可用交互

Android 的四个顶层页面会与 iOS 保持相同 IA：
- `Today`：今日进度、应做追踪项列表、完成切换、新建/编辑入口
- `History`：按 `dayKey` 分组的历史列表和日明细
- `Statistics`：汇总卡片和追踪项记录次数明细
- `Settings`：周起始日、统计窗口、已归档追踪项与应用信息

对应的文案统一切为“追踪项/记录”，不再把“习惯”当作实体总名词。

备选方案：
- 仅做语义改名，不补真实 UI：无法满足“完全对齐 iOS”目标，放弃。
- 做 Android 专属重设计：会降低与 iOS 的对齐速度，放弃。

### 5. 测试优先聚焦五个稳定层面

本轮测试分为：
- `domain`：`Tracker` 类型、`TrackerSchedule`、`DayKey`、默认偏好与边界导出
- `data`：Room store 的 tracker/entry/preference 持久化与迁移
- `app` 纯逻辑：`TrackerDraft` 校验与 `TrackingEngine` 计算
- `app` 顶层结构：`AppDestination` 顺序与基础装配
- 工程验证：`assembleDebug`

备选方案：
- 直接上 instrumentation/UI screenshot：成本高且对当前对齐任务收益有限，放弃。

## Risks / Trade-offs

- [Android 当前代码仍有部分旧文件名] -> Mitigation: 先统一运行时类型、API、测试和用户可见文案，文件名遗留只在不影响语义时暂时保留。
- [Room 迁移涉及旧 schema 到新 schema 的一次转换] -> Mitigation: 用针对性单元测试验证迁移后的 tracker、entry 和 preference 数据完整性。
- [iOS 自身仍保留部分旧文件名与 deprecated alias] -> Mitigation: Android 以共享契约和真实类型为主，不追随 iOS 的每个遗留命名细节。
- [Compose 页面一次性补齐四个功能页，改动面较大] -> Mitigation: 保持 `TrackingEngine`、`TrackerDraft`、`MarkerAppModel`、页面组件职责分离，并通过测试锁定关键行为。

## Migration Plan

1. 新建 Android tracker 应用 change，定义 Android 需要对齐的完整能力范围。
2. 先用测试锁定 Tracker 语义、TrackerDraft、TrackingEngine 和 Room 迁移期望。
3. 将 Android `domain` 和 `data` 升级到 tracker 结构并跑通测试。
4. 用真实 `MarkerAppModel` 和 Compose 页面替换占位壳层。
5. 运行完整 Android 验证，确认 App 可构建且本地 tracker 能力已可用。

## Open Questions

- 当前无阻塞问题。提醒调度、默认首页切换 UI 和更复杂统计展示继续留到后续 change。
