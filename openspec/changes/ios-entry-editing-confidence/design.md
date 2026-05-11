## Context

`TrackingEntryDraft` 已经携带 `dayKey`、`recordedAt` 和 `existingEntryID`，所以记录编辑器可以在不改领域模型的情况下展示时间归属，并区分新记录与已有记录。底层删除能力也已经支持指定 dayKey。

## Decisions

### 1. 删除必须确认

删除会影响历史和统计，必须先弹出确认。确认文案使用 draft 的 `dayKey`，避免用户在补记或历史编辑时误以为只会删除今天。

### 2. 保存使用一个明确主按钮

导航栏只保留取消，保存放在表单底部作为 `保存记录`。这样更接近高保真稿，也降低误触。

### 3. 撤销后置

撤销需要保存被删除 entry 的临时副本，并处理跨页面反馈。本轮先做确认和明确文案，撤销单独推进。

## Verification

```bash
openspec validate ios-entry-editing-confidence --strict
cd apps/ios
xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'
```
