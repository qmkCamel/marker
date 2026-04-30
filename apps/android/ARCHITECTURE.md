# Android 技术架构说明

本文档描述 `apps/android` 当前已经落地的技术架构，重点说明：

- 为什么选这套技术栈
- 模块边界如何划分
- 数据与状态如何在应用内流动
- 本地存储如何兼容旧版 `Habit` 数据

这是一份**实现架构说明**，不是产品需求文档。产品行为仍以 `openspec/specs` 与 `shared/contracts` 为真相源。

## 真相源边界

Android 侧实现遵循以下边界：

1. 行为规格真相源：`openspec/specs`
2. 领域语义真相源：`shared/contracts`
3. 平台实现：`apps/android`

这意味着：

- Android 不单独发明 `Tracker` / `TrackingEntry` 的核心字段
- Android 的 Today / History / Statistics / Settings 行为要对齐现有 specs
- Android 的实现以当前 iOS 为对齐参考，但不要求逐文件镜像 Swift 结构

## 技术选型

当前 Android 工作区采用：

- 语言：`Kotlin`
- UI：`Jetpack Compose`
- 本地存储：`Room + SQLite`
- 构建：`Gradle Kotlin DSL`
- 测试：`JUnit4 + Robolectric`

选择理由：

- `Kotlin`：与 Android 生态契合，表达领域模型和纯逻辑足够简洁。
- `Compose`：适合当前四 Tab 本地应用的快速迭代，和 iOS 的 SwiftUI 心智也更接近。
- `Room`：在保持 SQLite 语义的同时，能用较小样板成本落地本地 schema、DAO 和 migration。
- `Gradle Kotlin DSL`：和仓库当前类型化、显式配置的风格一致。
- `Robolectric`：可以在本地 JVM 环境验证 Room 和应用状态逻辑，不依赖模拟器。

当前明确不选：

- `KMP`：当前阶段不做跨端共享代码生成，先保持平台实现独立。
- `Hilt` / 大型 DI 框架：应用规模仍小，依赖装配可以通过轻量对象完成。
- 复杂状态框架：当前应用状态由单一 `MarkerAppModel` 足够承接。
- SQLDelight：现阶段 Room 已能满足本地存储与迁移需求。

## 模块划分

当前 Android 工程分为四个模块：

| 模块 | 角色 | 依赖 |
| --- | --- | --- |
| `app` | 应用入口、导航、页面、应用状态装配 | `domain`、`data`、`designsystem` |
| `domain` | `Tracker` 领域模型、`DayKey`、频率规则、偏好枚举 | 无平台层依赖 |
| `data` | Room schema、DAO、本地 store、旧数据迁移 | `domain` |
| `designsystem` | 基础 spacing、corner radius 等 UI token | 无业务依赖 |

依赖方向固定为：

```text
app
 ├─> domain
 ├─> data
 └─> designsystem

data
 └─> domain
```

这样设计的目标是：

- `domain` 保持纯 Kotlin，可被测试和复用
- `data` 负责持久化细节，不反向依赖 UI
- `app` 只负责装配状态与渲染界面
- `designsystem` 不承载业务语义

## 核心对象

Android 当前核心对象与 `shared/contracts` 对齐：

- `Tracker`
- `TrackingEntry`
- `TrackerKind`
- `TrackerSchedule`
- `TrackerReminder`
- `UserPreference`
- `DayKey`

其中：

- `Tracker` 是追踪项真相源对象
- `TrackingEntry` 是某个逻辑日的记录真相源对象
- `TrackerKind` 用于区分习惯、用药、经期和自定义等场景
- `DayKey` 是日级业务主键，历史与统计一律基于它解释

## 运行时架构

应用运行时的主链路如下：

```text
Compose UI
   │
   ▼
MarkerApp
   │
   ▼
MarkerAppModel
   │
   ├─ 读写持久化 ───────────────► MarkerLocalStore ─► Room / SQLite
   │
   └─ 派生展示状态 ────────────► TrackingEngine
```

各部分职责：

- `MarkerApp`
  - 装配根导航
  - 创建 `MarkerAppModel`
  - 承接全局错误弹层

- `MarkerAppModel`
  - 持有 `trackers`、`entries`、`preferences`
  - 负责 `reload()`、保存追踪项、切换记录、恢复归档、更新偏好
  - 对页面暴露 `todayItems`、`historySections`、`statisticsSummary`

- `TrackingEngine`
  - 纯计算层
  - 根据 `Tracker`、`TrackingEntry`、`DayKey`、`UserPreference` 生成 Today / History / Statistics 所需派生数据

- `TrackerDraft`
  - 承接追踪项编辑表单状态
  - 负责字段校验与 `makeTracker()`

- `MarkerPresentation`
  - 负责颜色 token 与频率文案等展示映射

## 本地存储架构

本地存储围绕 `MarkerLocalStore` 组织。

### 表结构

Room 当前主要表为：

- `trackers`
- `trackingEntries`
- `userPreferences`

其职责分别对应：

- 追踪项主数据
- 每日记录主数据
- 本地偏好

### Store API

`MarkerLocalStore` 对外暴露的能力包括：

- 读取全部 / 活跃 / 已归档追踪项
- 保存追踪项
- 读取全部记录、按 `dayKey` 读取、按范围读取
- 保存 / 删除单条记录
- 读取周内记录次数
- 读取 / 保存偏好

### 迁移策略

Android 当前已经内置 `Migration(1, 2)`，用于把旧版 foundation 阶段的 `Habit` schema 升级到 tracker schema。

迁移规则概要：

- 旧 `habits` -> 新 `trackers`
- 旧 `checkIns` -> 新 `trackingEntries`
- `habitId` -> `trackerId`
- `completedAtMillis` -> `recordedAtMillis`
- 旧数据默认 `kind = habit`

这意味着旧版 Android 本地数据在升级后不会丢失，而是被转换到当前 tracker 语义下继续使用。

## 页面结构

当前应用保持四个顶层入口：

- `Today`
- `History`
- `Statistics`
- `Settings`

页面职责如下：

- `Today`
  - 展示今日应做追踪项
  - 展示进度卡片
  - 支持切换记录状态
  - 支持新建 / 编辑追踪项

- `History`
  - 按 `dayKey` 展示历史记录分组
  - 可查看某一天的记录明细

- `Statistics`
  - 展示活跃追踪项数、累计记录数、窗口完成率、当前连胜
  - 展示按追踪项聚合的记录次数

- `Settings`
  - 修改周起始日
  - 修改统计窗口
  - 管理已归档追踪项
  - 展示应用基础信息

## 为什么不用 ViewModel / Repository 分层

当前没有再引入 `ViewModel`、完整 `Repository` 实现类或 DI 框架，属于**有意保持轻量**：

- 当前应用规模较小，`MarkerAppModel` 足以承接应用级状态
- `TrackingEngine` 和 `TrackerDraft` 已把关键规则从页面中拆出
- `MarkerLocalStore` 已经形成清晰的数据访问边界

这套结构的目标不是“永远不升级”，而是在当前阶段避免过度抽象。

如果未来出现以下信号，可以考虑继续拆分：

- 页面状态明显变多，单一 `MarkerAppModel` 过重
- 多个页面开始共享复杂异步流程
- 本地存储之外出现远端同步或缓存层

## 测试与验证

当前验证分三层：

- `domain`
  - `DayKey`
  - `TrackerSchedule`
  - 领域对象与边界导出

- `data`
  - tracker / entry / preference 持久化
  - 旧 `Habit` schema -> tracker schema 迁移

- `app`
  - `TrackerDraft`
  - `TrackingEngine`
  - `MarkerAppModel`
  - `AppDestination`

常用命令：

```bash
./gradlew :domain:test
./gradlew :data:testDebugUnitTest
./gradlew :app:testDebugUnitTest
./gradlew :app:assembleDebug
```

完整回归：

```bash
./gradlew :domain:test :data:testDebugUnitTest :app:testDebugUnitTest :app:assembleDebug
```

## 当前取舍

当前架构有几个明确取舍：

- 优先保证本地 tracker 闭环可用，而不是先引入大而全的架构层
- 优先对齐 iOS 的现有产品能力，而不是做 Android 专属扩展
- 允许少量 legacy 兼容符号存在，用于迁移和向后兼容
- 文档和代码共同约束，而不是只靠口头约定

## 后续扩展建议

后续如果继续演进，建议按下面顺序考虑：

1. 提醒调度与 `TrackerReminder` 的真正落地
2. 默认首页 tab 的用户可配置化
3. 更细粒度的 UI/状态拆分
4. 同步或远端能力接入前的 Repository 抽象稳定化
5. 更系统的 Android 设计系统沉淀
