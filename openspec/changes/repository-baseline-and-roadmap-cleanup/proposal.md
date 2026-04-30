## Why

Marker 已经从初始仓库推进到 iOS 与 Android 都具备本地 tracker 基线的阶段，但仓库说明、产品 TODO 和 Git 基线还停留在更早状态。当前大量文件仍处于未提交状态，并且 Android 生成目录被加入暂存区，继续开发前需要先把项目基线整理清楚。

这次变更不改变平台运行时行为，目标是降低后续 AI 与人工协作的上下文噪音，让接下来的产品任务可以基于稳定、准确的仓库状态推进。

## What Changes

- 清理不应进入仓库的 Android 生成文件，并补充忽略规则。
- 同步顶层 README 中的当前平台状态，准确描述 iOS 与 Android 的落地情况。
- 重排产品 TODO，把仓库基线、跨端 payload 对齐、记录编辑和 Today 信息架构放到更靠前的位置。
- 明确哪些能力应后置到 P1/P2，避免过早进入提醒、导出、分组或模板细节。

## Capabilities

### New Capabilities

无。

### Modified Capabilities

无。本轮只调整仓库维护与产品规划文档，不修改已批准的行为规格。

## Impact

- 影响 `.gitignore`、`README.md`、`shared/product/PRODUCT_TODO.md`。
- 删除 `apps/android/domain/bin` 下误入暂存区的生成文件。
- 新增本 OpenSpec change 记录本轮整理边界。
