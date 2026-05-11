## 1. 规格与范围

- [x] 1.1 创建 `ios-backfill-tracking-entry` OpenSpec change，明确只做历史 dayKey 补记；验证命令：`openspec validate ios-backfill-tracking-entry --strict`。

## 2. iOS 补记模型能力

- [x] 2.1 在 `MarkerAppModel` 中提供指定 `dayKey` 的 entry draft 构造与删除入口；验证方式：新增或更新单元测试覆盖指定 dayKey 和 existing entry。
- [x] 2.2 确保补记保存复用现有 store 覆盖语义，不新增 schema；验证命令：`xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'`。

## 3. History 补记 UI

- [x] 3.1 在 History 页增加补记入口，打开日期和 tracker 选择 sheet；验证方式：UI smoke 可找到入口。
- [x] 3.2 选择历史日期和 tracker 后进入 `TrackingEntryEditorView`，保存后 History 展示对应 dayKey 明细；验证方式：UI test 覆盖创建历史补记。
- [x] 3.3 为补记入口和关键控件添加 accessibility identifiers；验证方式：UI test 使用 identifier 操作。

## 4. 验证

- [x] 4.1 运行 OpenSpec 严格校验：`openspec validate ios-backfill-tracking-entry --strict`。
- [x] 4.2 运行 iOS 测试：`cd apps/ios && xcodegen generate && xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'`。
