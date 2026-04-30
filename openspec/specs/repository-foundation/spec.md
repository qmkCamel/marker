# repository-foundation Specification

## Purpose
定义仓库级多端工作区结构、基础协作约定与 OpenSpec 项目上下文，确保后续变更可以落在稳定边界上。

## Requirements
### Requirement: 仓库提供稳定的多端工作区结构
仓库必须（MUST）暴露一个顶层结构，将客户端应用、后端服务、跨端共享资产、文档和自动化脚本分开组织，使后续变更无需重新定义项目边界即可落地。

#### Scenario: 初始化后工作区结构已经就位
- **WHEN** 开发者在应用此变更后检查仓库
- **THEN** 仓库包含 `apps`、`services`、`shared`、`docs` 和 `scripts` 目录
- **AND** `apps` 下包含 `ios`、`android` 和 `web`
- **AND** `services` 下包含 `backend`
- **AND** `shared` 下包含 `product`、`contracts` 和 `assets`

### Requirement: 仓库定义基础协作与工作流约定
仓库必须（MUST）包含基础文档和忽略规则，用于说明各工作区的用途，并避免生成产物被错误纳入版本控制。

#### Scenario: 开发者阅读仓库入口文件
- **WHEN** 开发者在初始化后查看仓库根目录
- **THEN** 仓库包含根级 `README.md`
- **AND** 仓库包含覆盖构建产物与本地工具输出的 `.gitignore`
- **AND** 根文档说明了各顶层工作区的职责

### Requirement: 仓库记录 OpenSpec 项目上下文
仓库必须（MUST）提供 OpenSpec 项目上下文，使后续 change 可以继承既定的产品方向与架构边界。

#### Scenario: 后续 OpenSpec change 读取项目上下文
- **WHEN** 后续 change 调用 OpenSpec
- **THEN** 项目配置会描述多端仓库范围
- **AND** 配置会记录 iOS 使用 Swift 和 SwiftUI
- **AND** 配置会记录 Android、Web 和 backend 在当前阶段仍为占位工作区

