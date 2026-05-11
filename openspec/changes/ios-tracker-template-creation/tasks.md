## 1. 规格与范围

- [x] 1.1 创建 `ios-tracker-template-creation` OpenSpec change，明确本轮只做 iOS 创建模板化；验证命令：`openspec validate ios-tracker-template-creation --strict`。

## 2. 模板 draft

- [x] 2.1 在 `apps/ios/MarkerApp/Sources/App/TrackerDraft.swift` 增加按 `TrackerKind` 创建默认 draft 的能力；验证方式：更新 `TrackerDraftTests`。

## 3. iOS 创建 UI

- [x] 3.1 在 `apps/ios/MarkerApp/Sources/Features/Today/TodayView.swift` 中让新建入口先打开模板选择页；验证方式：UI smoke 覆盖创建路径。
- [x] 3.2 在 `apps/ios/MarkerApp/Sources/Features/Today/TrackerEditorView.swift` 中为新建场景隐藏 kind picker，并展示模板类型摘要；验证命令：`xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'`。

## 4. 验证

- [x] 4.1 运行 OpenSpec 严格校验：`openspec validate ios-tracker-template-creation --strict`。
- [x] 4.2 运行 iOS 测试：`cd apps/ios && xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'`。
