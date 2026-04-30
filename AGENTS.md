# Marker Agents Guide

本文件是本仓库面向 AI agent 的总入口约定。

## 工作流优先级

1. 先遵循 `openspec/specs`
2. 再遵循 `shared/contracts`
3. 最后才是平台实现代码

对非 trivial 改动，先创建或更新一个 `OpenSpec change`，再进入实现。

非 trivial 改动包括：
- 多文件改动
- 行为变更
- 新能力开发
- 跨模块重构

一个 change 只做一个可独立验证的能力，避免把不相关内容混进同一次生成。

## 仓库现状

- 当前唯一已落地的平台是 `iOS`
- `iOS` 技术栈固定为 `Swift + SwiftUI`
- `Android / Web / Backend` 目前是占位工作区，不要提前绑定未确认技术栈
- iOS 工程使用 `XcodeGen + Swift Package Manager`

## 真相源边界

- 行为规格真相源：`openspec/specs`
- 领域语义真相源：`shared/contracts`
- 不要在平台代码里擅自新增共享字段、共享对象语义或跨端规则
- 没有经过批准的 spec，不要新增新的共享抽象到 `shared/`
- 后续 `OpenSpec specs` 默认使用中文撰写；只有用户明确要求时才改用其他语言

## 代码约束

- 遵守 SOLID，按职责拆分模块和文件
- 对超过 `600` 行的 `JavaScript / TypeScript`，必须在继续扩展前按职责拆分
- 函数参数要保持显式类型说明，尤其是在类型化语言里
- 优先把平台代码放在所属工作区内，不要为了“复用”过早抽公共层

## 实现要求

- 实现前先确认本次任务修改哪些目录、包或文件
- 任务拆分要足够小，能够独立验证
- 涉及行为变化、领域规则、持久化语义时，优先补有价值的自动化测试
- 不要把“未来可能需要”的内容提前塞进当前 change

## 验证要求

- 不能在没有新鲜验证结果的情况下宣称完成
- `OpenSpec` 的 `tasks.md` 里应写明精确验证命令
- iOS 相关改动至少优先考虑这些验证方式：
  - `swift test`
  - `xcodebuild build`
  - `xcodebuild test`

## 提交与改动纪律

- 未经明确要求，不要主动 `commit`
- 不要回滚或覆盖用户已有改动
- 发现仓库里出现非本次任务产生的意外变更时，先停下来确认

## 参考入口

- 仓库说明：`README.md`
- OpenSpec 配置：`openspec/config.yaml`
- 主规格：`openspec/specs`
- 共享契约：`shared/contracts`
