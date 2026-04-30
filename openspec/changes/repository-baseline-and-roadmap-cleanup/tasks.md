## 1. 仓库基线整理

- [x] 1.1 删除 `apps/android/domain/bin` 下误入暂存区的生成文件，并补充忽略规则；验证命令：`git status --short --untracked-files=all`。
- [x] 1.2 更新顶层 `README.md`，同步 iOS、Android、Web、backend 当前状态；验证方式：人工检查 README 与平台 README 一致。

## 2. 产品路线重排

- [x] 2.1 重排 `shared/product/PRODUCT_TODO.md`，把仓库基线、Android payload 对齐、补记/改记/删除和 Today 重构列为下一阶段优先事项；验证方式：人工检查优先级与当前实现状态一致。

## 3. 收尾检查

- [x] 3.1 检查本轮 diff，确认没有修改平台运行时代码；验证命令：`git diff --stat`。
