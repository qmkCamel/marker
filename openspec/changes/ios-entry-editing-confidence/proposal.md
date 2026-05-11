## Why

Today 已经开始区分待确认和已记录，但记录编辑器仍缺少可信闭环：删除按钮写死为“删除今日记录”，补记或历史改记时会误导用户；删除没有确认；保存动作在导航栏里比较轻，不符合交互稿中“明确保存”的要求。

健康与自我照料记录需要让用户确认每次修改会影响哪一天、会删除什么，并在危险操作前得到清楚提示。本次变更先把记录编辑器的改记/删除信任感补上。

## What Changes

- 记录编辑器标题按创建/编辑场景区分。
- 记录编辑器展示归属日期、记录时间和设备时区说明。
- 保存动作收敛为一个明确的 `保存记录` 主按钮。
- 删除按钮按记录 dayKey 呈现，不再写死为今日。
- 删除前弹出确认，说明删除会影响对应日期的历史和统计。

## Capabilities

### Modified Capabilities

- `daily-tracking-workflow`: 记录编辑和删除必须清楚说明 dayKey 归属，并在删除前确认。

## Impact

- 影响 `apps/ios/MarkerApp/Sources/Features/Today/TrackingEntryEditorView.swift`。
- 影响 `apps/ios/MarkerApp/UITests/MarkerAppSmokeUITests.swift`（如果 UI 路径需要适配）。
- 不修改共享领域契约或数据库 schema。

## Non-goals

- 不实现删除撤销。
- 不实现全局 Toast 系统。
- 不重构 History 列表。
