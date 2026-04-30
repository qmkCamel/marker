## 1. 规格与共享契约

- [x] 1.1 更新主规格中的领域、存储和界面语义，将 Habit 术语泛化为 Tracking 术语
- [x] 1.2 将 `shared/contracts` 中的核心文档改为 Tracking 命名，并补充 `TrackerKind`

## 2. iOS 领域与数据层

- [x] 2.1 重构 `MarkerDomain` 中的核心类型、枚举和测试命名
- [x] 2.2 重构 `MarkerData` 中的本地存储映射、方法命名和测试

## 3. iOS App 层

- [x] 3.1 重构应用模型、页面、草稿对象和引擎命名
- [x] 3.2 将用户可见文案从“习惯”调整为更通用的“追踪项”

## 4. 验证与收尾

- [x] 4.1 运行 `MarkerDomain` 和 `MarkerData` 测试
- [x] 4.2 运行 iOS 构建与 App 测试
- [x] 4.3 验证并归档该 change
