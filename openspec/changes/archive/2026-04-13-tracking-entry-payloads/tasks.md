## 1. 领域模型与测试

- [x] 1.1 为 `MarkerDomain` 增加 `TrackingPayload`、相关枚举/结构与摘要、统计语义测试
- [x] 1.2 扩展 `TrackingEntry` 以持有 payload，并验证不同 payload 类型的构造与行为

## 2. 本地存储与迁移

- [x] 2.1 为 `MarkerData` 扩展 `trackingEntries` 存储结构，持久化 payload 数据
- [x] 2.2 为旧完成型记录增加默认 payload 迁移逻辑
- [x] 2.3 用测试验证 payload round-trip、旧记录兼容和查询行为

## 3. App 层与界面

- [x] 3.1 为 App 增加按 `TrackerKind` 驱动的记录草稿与记录表单
- [x] 3.2 更新 Today，使其支持快速完成和 richer payload 记录入口
- [x] 3.3 更新 History 与 Statistics，使其显示和计算 payload 驱动的记录语义

## 4. 验证与收尾

- [x] 4.1 运行 `MarkerDomain` 与 `MarkerData` 测试
- [x] 4.2 运行 iOS 构建与完整 App 测试
- [x] 4.3 验证并归档该 change
