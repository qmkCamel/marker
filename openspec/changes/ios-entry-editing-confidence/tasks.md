## 1. 规格与范围

- [x] 1.1 创建 `ios-entry-editing-confidence` OpenSpec change，明确本轮只做记录编辑器保存与删除信任感；验证命令：`openspec validate ios-entry-editing-confidence --strict`。

## 2. 记录编辑器

- [x] 2.1 在 `apps/ios/MarkerApp/Sources/Features/Today/TrackingEntryEditorView.swift` 中增加时间归属说明；验证命令：`xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'`。
- [x] 2.2 将保存动作收敛为单一主按钮，并保留 UI test 使用的 accessibility identifier；验证命令：`xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'`。
- [x] 2.3 删除前弹出 dayKey 相关确认，并把删除文案从“今日记录”改为“这条记录”；验证命令：`xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'`。

## 3. 验证

- [x] 3.1 运行 OpenSpec 严格校验：`openspec validate ios-entry-editing-confidence --strict`。
- [x] 3.2 运行 iOS 测试：`cd apps/ios && xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'`。
