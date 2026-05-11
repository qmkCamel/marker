## Why

`PRODUCT_TODO` 已经把 iOS 试点方向、记录编辑闭环、Today 首页重构、History / Statistics 和信任感列为下一阶段重点，但目前这些事项仍是列表形态，缺少一份能覆盖核心页面、状态、流程和拆分顺序的产品交互母版。

如果直接进入实现，容易把 Today、记录编辑、创建模板、统计口径和 Settings 信任感拆散处理，导致每个页面局部可用但整体体验仍像任务打卡工具。本次变更先补一份 iOS V1 产品交互稿，用来统一“温和记录、认真照料”的体验方向。

## What Changes

- 新增 `shared/product/IOS_V1_INTERACTION_DRAFT.md`。
- 覆盖 iOS V1 的核心页面：Today、创建追踪项、记录编辑器、History、Statistics、Settings、归档管理。
- 明确四类 tracker 的最低交互：习惯、用药、经期、自定义备注。
- 明确关键状态：空状态、保存成功、异常失败、删除确认、撤销、时间归属、本地优先说明。
- 给出后续可拆分的 OpenSpec change 顺序。

## Capabilities

### New Capabilities

- `ios-product-interaction-v1`: 增加 iOS V1 产品交互稿的覆盖范围与真相源边界要求。

### Modified Capabilities

无。本轮只新增产品交互设计稿，不修改已批准行为规格，不改变平台运行时代码。

## Impact

- 影响 `shared/product/IOS_V1_INTERACTION_DRAFT.md`。
- 新增本 OpenSpec change 记录设计边界。
- 不修改 `openspec/specs`、`shared/contracts` 或 `apps/ios` 运行时代码。

## Non-goals

- 不实现 iOS UI。
- 不调整 SQLite schema。
- 不新增共享领域字段。
- 不承诺 Android、Web 或 backend 对齐。
- 不做账号、同步、导出、提醒、小组件等后续能力。
