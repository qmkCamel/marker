## Context

Marker 的产品 TODO 和品牌调性已经明确：首轮应在 iOS 上验证 `快记`、`低负担`、`可信`、`可回看`、`可扩展`。现有 iOS 实现已经具备四 Tab、payload、补记入口、History 摘要和基础 Statistics，但页面信息架构仍偏“习惯完成率”和“任务进度”，还没有形成完整的自我照料记录体验。

本设计稿位于 `shared/product`，定位是产品层参考，不直接替代 `openspec/specs` 或 `shared/contracts`。后续进入实现时，仍应按一个可独立验证的能力创建或更新 OpenSpec change。

## Source of Truth Boundaries

- 行为规格真相源仍是 `openspec/specs`。
- 领域语义真相源仍是 `shared/contracts`。
- 本交互稿只描述 iOS V1 产品体验方向、页面结构、状态和拆分建议。
- 若交互稿与现有 spec 冲突，必须先通过 OpenSpec change 更新规格，再修改平台代码。

## Decisions

### 1. V1 聚焦 iOS，不推动 Android 对齐

iOS 是当前试点平台。Android 先保持现有基线，等 iOS 的记录语义、Today 信息架构和统计表达稳定后再对齐。

### 2. Today 从“完成进度”调整为“照料确认”

Today 应优先回答：

- 今天需要确认什么？
- 哪些已经记录？
- 是否有用药跳过、备注记录等不应误算的状态？

因此交互稿把 Today 分为 `待确认` 与 `今日已记录`，并按 tracker 类型呈现行内状态。

### 3. 用药、经期、自定义不再套用习惯打卡心智

习惯可以快速完成；用药必须进入表单确认 `已服用 / 已跳过`；经期和自定义记录强调状态与备注。这个区分先在产品交互层明确，后续再分 change 实现。

### 4. History 是补记和改记主入口

补记和改记都属于回看场景。History 需要从单纯按天列表升级为最近记录时间线 + 按天详情 + 类型筛选，并允许从历史记录进入编辑。

### 5. Statistics 弱化泛完成率

统计页应按类型表达不同含义：习惯看稳定性，用药看已服用 / 已跳过 / 未记录，经期看状态回看，自定义看记录频率。泛完成率和连胜需要谨慎使用。

### 6. Settings 承担信任感说明

本地优先、同步状态、备份状态、归档管理和危险操作都集中到 Settings。Today 只保留轻量状态提示，不承载低频配置。

## Allowed Change Surfaces

本轮只允许新增产品和 OpenSpec 文档：

- `shared/product/IOS_V1_INTERACTION_DRAFT.md`
- `openspec/changes/ios-v1-product-interaction-draft/*`
- `openspec/changes/ios-v1-product-interaction-draft/specs/ios-product-interaction-v1/spec.md`

## Deferred

- iOS 运行时代码实现。
- 自动化测试新增。
- 已批准 spec 修改。
- `shared/contracts` 字段调整。
- Android 对齐。

## Verification

```bash
openspec validate ios-v1-product-interaction-draft --strict
test -f shared/product/IOS_V1_INTERACTION_DRAFT.md
```
