# iOS 技术架构说明

本文档描述 `apps/ios` 当前已经落地的技术架构，重点说明：

- 为什么选这套技术栈
- 模块边界如何划分
- 数据与状态如何在应用内流动
- 本地存储如何兼容旧版 `Habit` 数据

这是一份**实现架构说明**，不是产品需求文档。产品行为仍以 `openspec/specs` 与 `shared/contracts` 为真相源。

## 真相源边界

iOS 侧实现遵循以下边界：

1. 行为规格真相源：`openspec/specs`
2. 领域语义真相源：`shared/contracts`
3. 平台实现：`apps/ios`

这意味着：

- iOS 不单独发明 `Tracker` / `TrackingEntry` / `TrackingPayload` 的核心字段和共享语义
- `Today` / `History` / `Statistics` / `Settings` 的行为要对齐现有 specs
- SwiftUI 的组织方式可以按平台习惯实现，但不能绕开共享领域语义

## 技术选型

当前 iOS 工作区采用：

- 语言：`Swift 6`
- UI：`SwiftUI`
- 本地存储：`GRDB + SQLite`
- 工程生成：`XcodeGen`
- 模块化与依赖管理：`Swift Package Manager`
- 测试：`XCTest`

选择理由：

- `Swift 6`：和当前 iOS 生态一致，适合表达领域对象、纯计算逻辑和轻量应用编排
- `SwiftUI`：适合当前四 Tab 本地优先应用的快速迭代，也便于把导航和页面状态保持在同一套声明式心智下
- `GRDB`：保留 SQLite 的可控性，便于显式 schema、迁移和历史兼容逻辑的落地
- `XcodeGen`：让工程配置可追踪、可复现，避免手改 `.xcodeproj`
- `Swift Package Manager`：适合当前 `Domain / Data / DesignSystem` 的边界拆分
- `XCTest`：同时覆盖 Swift 包测试和 App target 测试，足以承接当前规模

当前明确不选：

- `SwiftData`：首轮更看重 SQLite schema、迁移和兼容逻辑的可控性
- 大型 DI 框架：当前依赖装配由轻量的 `MarkerAppDependencies` 即可承接
- 复杂状态框架：现阶段单一 `MarkerAppModel` 足够覆盖应用级状态
- 账号、同步、云端 API：当前坚持本地优先，不引入额外分布式复杂度

## 模块划分

当前 iOS 工程分为一个 App target 和三个 Swift 包：

| 模块 | 角色 | 依赖 |
| --- | --- | --- |
| `MarkerApp` | 应用入口、Tab 导航、页面、应用状态装配、表单草稿与展示映射 | `MarkerDomain`、`MarkerData`、`MarkerDesignSystem` |
| `Packages/MarkerDomain` | `Tracker` 领域模型、`DayKey`、追踪 payload、频率规则、偏好枚举、边界协议 | 无平台层依赖 |
| `Packages/MarkerData` | GRDB schema、SQLite store、本地查询与旧数据迁移 | `MarkerDomain` |
| `Packages/MarkerDesignSystem` | 基础 spacing、corner radius 等 UI token | 无业务依赖 |

依赖方向固定为：

```text
MarkerApp
 ├─> MarkerDomain
 ├─> MarkerData
 └─> MarkerDesignSystem

MarkerData
 └─> MarkerDomain
```

这样设计的目标是：

- `MarkerDomain` 保持纯 Swift，不依赖 UI 和存储实现
- `MarkerData` 负责持久化细节，不反向依赖页面层
- `MarkerApp` 负责装配状态与渲染界面
- `MarkerDesignSystem` 只沉淀通用 UI token，不承载业务语义

## 核心对象

iOS 当前核心对象与 `shared/contracts` 对齐：

- `Tracker`
- `TrackingEntry`
- `TrackingPayload`
- `TrackerKind`
- `TrackerSchedule`
- `TrackerReminder`
- `UserPreference`
- `DayKey`

其中：

- `Tracker` 是追踪项真相源对象，包含类型、颜色 token、频率、归档状态和时间戳
- `TrackingEntry` 是某个逻辑日上的记录真相源对象，通过 `trackerId + dayKey` 形成一条日级记录
- `TrackingPayload` 让记录从单纯“完成”扩展到用药、经期、自定义文本等场景
- `DayKey` 是 `yyyy-MM-dd` 形式的逻辑日主键，历史与统计都围绕它解释
- `UserPreference` 当前承接周起始日、默认首页 tab 和统计窗口等本地偏好

## 运行时架构

应用运行时主链路如下：

```text
SwiftUI View
   │
   ▼
MarkerRootView / AppDestination
   │
   ▼
MarkerAppModel
   │
   ├─ 读写持久化 ───────────────► MarkerSQLiteStore ─► GRDB / SQLite
   │
   ├─ 派生展示状态 ────────────► TrackingEngine
   │
   ├─ 表单草稿与校验 ──────────► TrackerDraft / TrackingEntryDraft
   │
   └─ 展示映射 ───────────────► MarkerPresentation
```

各部分职责：

- `MarkerAppApp`
  - 应用入口
  - 挂载 `MarkerRootView`

- `MarkerRootView`
  - 创建 `MarkerAppModel`
  - 维护四个顶层 Tab 的选中状态
  - 为每个顶层页面提供独立 `NavigationStack`
  - 承接全局错误弹层

- `MarkerAppDependencies`
  - 负责 live 环境下的轻量依赖装配
  - 创建 `MarkerSQLiteStore.live()`
  - 暴露当前数据层支持的领域边界集合

- `MarkerAppModel`
  - 持有 `trackers`、`entries`、`preferences`、`lastErrorMessage`
  - 负责 `reload()`、保存追踪项、切换记录、保存 payload 记录、恢复归档、更新偏好
  - 对页面暴露 `todayItems`、`historySections`、`statisticsSummary`、`archivedTrackers`
  - 当前采用“写入后整库重新加载”的一致性策略，优先保证实现简单和状态统一

- `TrackingEngine`
  - 纯计算层
  - 根据 `Tracker`、`TrackingEntry`、`DayKey`、`UserPreference` 生成 Today / History / Statistics 所需派生数据
  - 不直接依赖 SwiftUI 或 SQLite

- `TrackerDraft`
  - 承接追踪项编辑表单状态
  - 负责名称、频率等字段校验
  - 将表单输入转换为 `Tracker`

- `TrackingEntryDraft`
  - 承接非 habit 类型记录编辑状态
  - 根据 `TrackerKind` 生成不同 payload
  - 负责剂量、备注、自定义记录内容等输入校验

- `MarkerPresentation`
  - 负责颜色 token 与频率文案等展示映射
  - 把领域值转换成 UI 层可直接消费的展示值

## 本地存储架构

本地存储围绕 `MarkerSQLiteStore` 组织。

### 表结构

SQLite 当前主要表为：

- `trackers`
- `trackingEntries`
- `userPreferences`

其职责分别对应：

- 追踪项主数据
- 每日记录主数据
- 本地偏好

其中 `trackingEntries` 使用 `(trackerId, dayKey)` 唯一索引约束“同一追踪项在同一逻辑日只有一条记录”，同时保留 `payloadJSON` 字段承接更通用的记录载荷。

### Store API

`MarkerSQLiteStore` 对外暴露的能力包括：

- 读取全部 / 活跃 / 已归档追踪项
- 保存追踪项
- 读取全部记录、按 `dayKey` 读取、按范围读取
- 读取单条记录并按逻辑日删除记录
- 保存单条记录并在同日场景下做 upsert
- 读取周内记录次数
- 读取 / 保存偏好

### 迁移策略

iOS 当前已经内置两段 migration：

- `v1_local_tracking`
- `v2_tracking_entry_payloads`

迁移策略概要：

- `v1_local_tracking`
  - 建立 `trackers`、`trackingEntries`、`userPreferences` 三张表
  - 如果发现旧版 `habits` / `checkIns` 表，并且新表还没有数据，则自动迁移旧数据
  - 旧 `habitId` 会映射到新 `trackerId`
  - 旧习惯数据默认 `kind = habit`

- `v2_tracking_entry_payloads`
  - 为历史 `trackingEntries` 补齐 `payloadJSON`
  - 缺省 payload 会回填为 `.completion()`

这意味着旧版本地数据不会因为 tracker 语义扩展而直接失效，而是会被提升到新的数据模型下继续使用。

## 页面结构

当前应用保持四个顶层入口：

- `Today`
- `History`
- `Statistics`
- `Settings`

页面职责如下：

- `Today`
  - 展示今日应做追踪项
  - 展示今日进度卡片
  - 对 `habit` 类型提供一键切换记录
  - 对其他 tracker 类型通过 `TrackingEntryEditorView` 编辑 payload
  - 支持新建 / 编辑追踪项

- `History`
  - 按 `dayKey` 展示历史记录分组
  - 支持进入某一天的记录明细

- `Statistics`
  - 展示活跃追踪项数、累计记录数、窗口完成率、当前连胜
  - 展示按追踪项聚合的记录次数

- `Settings`
  - 修改周起始日
  - 修改统计窗口
  - 管理已归档追踪项
  - 展示应用基础信息

## 为什么当前没有继续拆成 Feature ViewModel / Repository / DI

当前没有继续引入按页面拆分的 `ObservableObject`、完整 `Repository` 实现类或大型 DI 框架，属于**有意保持轻量**：

- 当前应用规模较小，单一 `MarkerAppModel` 足以承接应用级状态
- `TrackingEngine`、`TrackerDraft`、`TrackingEntryDraft` 已经把关键规则从页面中拆出
- `MarkerSQLiteStore` 已经形成明确的数据访问边界
- `MarkerDomain` 虽然定义了 `TrackerRepository` 等边界协议，但当前阶段还没有多数据源、同步层或复杂异步流程需要把它们真正落成完整仓储体系

这套结构的目标不是“永远不升级”，而是在当前阶段避免为了分层而分层。

如果未来出现以下信号，可以考虑继续拆分：

- 单一 `MarkerAppModel` 明显变重，页面状态与副作用持续增长
- 本地存储之外出现远端同步、缓存协调或提醒调度
- 多个页面开始共享复杂异步流程和装配逻辑

## 测试与验证

当前验证分三层：

- `MarkerDomain`
  - `DayKey`
  - `TrackerSchedule`
  - `TrackingPayload`
  - 领域对象与边界导出

- `MarkerData`
  - tracker / entry / preference 持久化
  - payload round-trip
  - 旧 `Habit` 数据迁移

- `MarkerApp`
  - `AppDestination`
  - `TrackerDraft`
  - `TrackingEntryDraft`
  - `TrackingEngine`
  - `MarkerAppModel`

常用命令：

```bash
cd apps/ios && xcodegen generate
cd apps/ios/Packages/MarkerDomain && swift test
cd apps/ios/Packages/MarkerData && swift test
cd apps/ios/Packages/MarkerDesignSystem && swift test
```

App 构建与测试在生成工程后执行。示例：

```bash
cd apps/ios && xcodebuild build -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'generic/platform=iOS Simulator'
cd apps/ios && xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=<本机可用模拟器>'
```

## 当前取舍

当前架构有几个明确取舍：

- 优先保证本地 tracker 闭环可用，而不是先引入大而全的架构层
- 允许 `MarkerApp` 直接依赖 `MarkerSQLiteStore`，以换取更轻的装配成本
- 写操作后采用整库 `reload()`，优先一致性和实现简单性，而不是最细粒度状态更新
- `defaultHomeTab` 已进入偏好模型，但当前首页仍固定从 `Today` 进入
- `MarkerDesignSystem` 目前仍停留在基础 token 层，不包含复杂组件抽象

## 后续扩展建议

后续如果继续演进，建议按下面顺序考虑：

1. 让 `defaultHomeTab` 真正驱动应用默认入口
2. 将提醒调度与 `TrackerReminder` 从领域定义推进到平台实现
3. 在出现更复杂副作用后，再拆分更细粒度的 feature 状态对象或 use case
4. 在接入同步或多数据源前，稳定 `Repository` 抽象和依赖注入边界
5. 继续沉淀 iOS 设计系统组件，而不只是 spacing / radius token
