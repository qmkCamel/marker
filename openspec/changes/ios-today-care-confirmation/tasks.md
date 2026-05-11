## 1. 规格与范围

- [x] 1.1 创建 `ios-today-care-confirmation` OpenSpec change，明确本轮只做 Today 信息架构与记录确认；验证命令：`openspec validate ios-today-care-confirmation --strict`。

## 2. Today 派生模型

- [x] 2.1 在 `apps/ios/MarkerApp/Sources/App/TrackingEngine.swift` 中新增 Today 分区派生模型，区分待确认、已记录和记录语义；验证方式：更新 `TrackingEngineTests`。
- [x] 2.2 在 `apps/ios/MarkerApp/Sources/App/MarkerAppModel.swift` 暴露 Today overview；验证方式：`xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'`。

## 3. Today UI

- [x] 3.1 在 `apps/ios/MarkerApp/Sources/Features/Today/TodayView.swift` 重构 Today 首屏结构为摘要、待确认、今日已记录、本地保存说明；验证方式：UI smoke 仍能进入 Today 并创建/记录。
- [x] 3.2 为不同 tracker 类型提供不同主操作文案，并让已跳过记录以“已记录但不计入完成”呈现；验证方式：`xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'`。

## 4. 验证

- [x] 4.1 运行 OpenSpec 严格校验：`openspec validate ios-today-care-confirmation --strict`。
- [x] 4.2 运行 iOS 测试：`cd apps/ios && xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'`。
