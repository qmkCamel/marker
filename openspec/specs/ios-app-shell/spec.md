# ios-app-shell Specification

## Purpose
定义 iOS 可运行应用壳子、可复现工程生成方式以及稳定的 Swift 包边界，为后续功能开发提供明确起点。

## Requirements
### Requirement: iOS 工作区提供可运行的应用壳子
iOS 工作区必须（MUST）构建并运行一个 SwiftUI 应用壳子，在业务功能尚未实现前为产品开发提供具体起点。

#### Scenario: 应用启动进入主导航壳子
- **WHEN** iOS 应用在应用此变更后启动
- **THEN** 用户会看到一个基于 Tab 的应用壳子
- **AND** 壳子暴露 `Today`、`History`、`Statistics` 和 `Settings` 作为顶层入口
- **AND** 每个入口都会渲染占位页面，以确认导航链路已接通

### Requirement: iOS 工作区使用可复现的工程生成方式
iOS 工作区必须（MUST）使用受版本控制的配置来描述应用工程，使协作者无需手工编辑 Xcode 工程文件也能复现该壳子。

#### Scenario: 开发者从配置生成 iOS 工程
- **WHEN** 开发者运行文档中记录的工程生成命令
- **THEN** iOS 的 Xcode 工程可以成功生成
- **AND** 生成结果包含应用 target 和所需的包依赖

### Requirement: iOS 壳子强制执行模块化 Swift 包边界
iOS 壳子必须（MUST）将稳定的业务抽象、数据基础设施和共享 UI 构件拆分到独立的 Swift 包中。

#### Scenario: 应用 target 组合包依赖
- **WHEN** 开发者查看生成后的 iOS 工程
- **THEN** 应用 target 依赖 `MarkerDomain`、`MarkerData` 和 `MarkerDesignSystem`
- **AND** `MarkerData` 依赖 `MarkerDomain`
- **AND** `MarkerDesignSystem` 不依赖业务包或存储实现包
- **AND** `MarkerDomain` 不依赖 UI 层或存储实现层

