## 1. 产品交互稿

- [x] 1.1 新增 `shared/product/IOS_V1_INTERACTION_DRAFT.md`，覆盖 iOS V1 核心页面、关键流程、状态反馈和后续拆分建议；验证方式：人工检查文档覆盖 Today、History、Statistics、Settings、创建和记录编辑器。

## 2. OpenSpec 边界记录

- [x] 2.1 新增 `ios-v1-product-interaction-draft` OpenSpec change，明确本轮只新增产品交互设计稿，不修改 contracts 或运行时代码；验证命令：`openspec validate ios-v1-product-interaction-draft --strict`。
- [x] 2.2 新增 `ios-product-interaction-v1` specs delta，约束交互稿必须覆盖核心页面、关键记录状态和后续拆分边界；验证命令：`openspec validate ios-v1-product-interaction-draft --strict`。

## 3. 收尾检查

- [x] 3.1 检查本轮改动只包含产品与 OpenSpec 文档；验证命令：`git status --short --untracked-files=all -- shared/product/IOS_V1_INTERACTION_DRAFT.md openspec/changes/ios-v1-product-interaction-draft`。
