## Context

`TrackerDraft` 已经能表达 kind、颜色、备注和频率。模板化创建不需要新增领域字段，只需要提供不同 kind 的默认 draft，并让新建入口先经过模板选择页。

## Decisions

### 1. 模板选择只用于新建

编辑已有 tracker 时不经过模板选择，避免用户误以为可以安全改变历史语义。已有编辑表单保留类型展示。

### 2. 模板设置保守默认值

- 习惯：绿色或蓝色，每日。
- 用药：蓝色，每日。
- 经期：粉色，每日，等待后续事件型 schedule。
- 自定义：紫色，每日。

这些默认值只服务首轮低门槛创建，不写入共享契约。

### 3. 新建表单隐藏类型 picker

用户已在模板页完成类型选择，新建表单只展示“类型”只读摘要，重点填写名称、备注、颜色和频率。

## Verification

```bash
openspec validate ios-tracker-template-creation --strict
cd apps/ios
xcodebuild test -project MarkerApp.xcodeproj -scheme MarkerApp -destination 'platform=iOS Simulator,name=iPhone 17'
```
