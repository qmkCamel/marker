## Context

当前应用已经完成 `Tracker` 语义泛化，但 `TrackingEntry` 仍然只表达“这天记了一次”，无法记录更丰富的内容。产品目标已经明确包括习惯、用药、经期以及更广义的记录场景，因此必须让记录本身可携带结构化 payload。

约束：
- 保持当前本地可运行能力不被破坏。
- 兼容已有只包含简单完成型记录的本地 SQLite 数据。
- 不在本轮把 `TrackerSchedule` 改成完全事件化模型；先在当前计划型模型上叠加更丰富的 entry 内容。

## Goals / Non-Goals

**Goals:**
- 为 `TrackingEntry` 引入结构化 payload。
- 让领域、存储和 UI 可以表达完成型、用药型、经期型和备注型记录。
- 让历史与统计基于 payload 语义展示和计算。
- 为旧数据提供默认 payload 迁移。

**Non-Goals:**
- 不在本轮实现完全自由的 JSON payload 编辑器。
- 不引入云同步或远端 schema。
- 不把经期或用药做成高度专业化的复杂业务模块。

## Decisions

### 1. 采用“带 kind 的结构化 payload”而不是自由 JSON

本轮将使用强约束的 payload 模型，至少覆盖 `completion`、`medication`、`cycle` 和 `note` 四类内容。这样既保留扩展性，又避免自由 JSON 让统计和界面逻辑失控。

### 2. 让 payload 自己提供展示摘要和统计语义

payload 将负责提供可读摘要和“是否计入完成/记录”的语义，避免 Today、History、Statistics 各自重复解释同一条记录。

### 3. 在本轮保持 Tracker 的计划型调度模型

`TrackerSchedule` 暂时继续存在，用于 Today、进度和统计。payload 负责“记录了什么”，schedule 继续负责“今天应不应该出现”。

### 4. 旧记录迁移为默认 completion payload

已有记录在迁移后默认视为完成型 payload，这样不会破坏现有 Today/History/Statistics 能力。

## Risks / Trade-offs

- [经期和用药场景仍然只是第一版表达] -> Mitigation: 先完成结构化 payload，再按具体业务细化字段和 UI。
- [记录语义更复杂后 Today 逻辑更难维护] -> Mitigation: 把统计与展示解释集中在 payload 上，避免页面层自行判断。
- [数据库迁移失败会影响已存在本地数据] -> Mitigation: 为旧记录提供默认 payload，并通过测试验证 round-trip。

## Migration Plan

1. 在领域层加入 `TrackingPayload` 及相关子类型。
2. 在 SQLite 中为 `trackingEntries` 增加 payload 存储字段，并将旧记录迁移为默认 completion payload。
3. 在 App 中增加记录表单和历史展示摘要。
4. 跑通测试与构建，确保应用继续可运行。

## Open Questions

- 未来是否要把 payload 扩展到数值型、区间型和多字段自定义型。
- 未来是否要让某些 `TrackerKind` 彻底脱离 schedule，成为纯事件型记录。
