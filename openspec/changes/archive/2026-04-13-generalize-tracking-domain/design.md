## Context

当前 iOS 应用已经进入可本地使用状态，但领域核心仍然使用 `Habit`、`HabitSchedule`、`CheckIn` 等习惯语义。产品目标已经超出单纯习惯场景，未来明确会覆盖慢性病吃药记录、月经记录和其他更广义追踪场景，因此现在就需要把核心命名与语义泛化。

约束：
- 保持现有 iOS 本地可用能力不被破坏。
- 不在这一轮同时引入复杂的新业务类型输入控件。
- 领域、数据层、App 层和共享契约都要保持一致命名。
- 允许在本轮先完成命名泛化与类型分类，为后续更丰富记录模型留扩展口。

## Goals / Non-Goals

**Goals:**
- 将核心名词统一到 `Tracker` / `TrackingEntry` / `TrackerSchedule` 等更宽语义。
- 在模型中加入 `TrackerKind` 作为未来扩展点。
- 保持当前应用的创建、打卡、历史和统计能力正常工作。
- 更新共享契约和主规格，避免文档与代码语义背离。

**Non-Goals:**
- 不在本轮实现经期专用记录模型或复杂吃药剂量模型。
- 不在本轮引入可变 payload、数值记录或区间记录。
- 不实现新的跨端业务功能。

## Decisions

### 1. 用 `Tracker` 作为被追踪对象的核心名词

`Tracker` 足够宽，既能承接习惯，也能承接吃药、经期和未来的其他追踪场景。相比 `TrackedItem` 更简洁，比 `Habit` 更不带业务偏见。

### 2. 用 `TrackingEntry` 表示一次记录

当前应用的记录仍然是“某天完成了一次”这类事件，但命名上不再限定为 `CheckIn`。后续如果需要扩展到数值或状态记录，也更容易继续演化。

### 3. 保留当前频率模型，但将其泛化命名为 `TrackerSchedule`

当前频率能力对吃药等场景仍然有效，因此先保留既有 `daily / weeklyOnDays / weeklyQuota` 语义，只移除习惯专属命名。

### 4. 引入 `TrackerKind` 作为未来扩展锚点

本轮加入 `TrackerKind`，至少覆盖 `habit`、`medication`、`cycle` 和 `custom`。这样当前数据模型已经能表达“这是什么类型的追踪项”，未来再针对不同类型扩展专用字段时不会从零开始。

## Risks / Trade-offs

- [本轮仍未支持真正非计划型记录] -> Mitigation: 先完成语义泛化和类型分类，后续通过新的 change 扩展 payload 与无频率追踪。
- [OpenSpec 旧 spec slug 仍带 habit 痕迹] -> Mitigation: 先统一内容和代码语义，后续如有必要再清理 slug。
- [命名重构覆盖范围大] -> Mitigation: 通过测试和构建验证确保行为不回退。

## Migration Plan

1. 更新共享契约与主规格文字语义。
2. 重构 `MarkerDomain` 类型命名并补充 `TrackerKind`。
3. 重构 `MarkerData` 存储映射与仓储接口命名。
4. 重构 App 层视图模型、页面和用户文案。
5. 运行全量构建与测试验证。

## Open Questions

- `TrackerSchedule` 是否应在未来变为可选，用于支持非计划型记录。
- `TrackingEntry` 是否需要在后续演化出更通用的 payload 结构。
