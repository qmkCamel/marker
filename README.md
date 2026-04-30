# Marker

一个参考 `HabitKit` 交互方向、但面向更广义追踪与记录场景的多端应用仓库。

当前阶段：
- `iOS` 是已落地客户端，技术栈为 `Swift + SwiftUI + GRDB`
- `Android` 是已落地客户端，技术栈为 `Kotlin + Jetpack Compose + Room`
- `Web / Backend` 先保留清晰坑位，不提前绑定技术选型
- 变更流程使用 `OpenSpec`

## 仓库结构

- `apps/ios`：iOS 主工程与 Swift 包
- `apps/android`：Android 主工程与 Gradle 模块
- `apps/web`：Web 端占位与接入说明
- `services/backend`：后端服务占位与接入说明
- `shared/product`：跨端产品信息架构、流程与说明
- `shared/contracts`：跨端共享契约与数据语义说明
- `shared/assets`：共享资源与命名规范
- `openspec`：OpenSpec 变更、规格与设计
- `docs`：仓库级补充文档
- `scripts`：仓库级脚本入口

## iOS 启动方式

1. 进入 `apps/ios`
2. 运行 `xcodegen generate`
3. 打开 `MarkerApp.xcodeproj`

## Android 启动方式

1. 进入 `apps/android`
2. 运行 `./gradlew :app:assembleDebug`
3. 使用 Android Studio 打开 `apps/android` 或安装生成的 Debug APK

## OpenSpec

当前主规格包括：
- `repository-foundation`
- `ios-app-shell`
- `platform-placeholders`
- `habit-domain-contracts`
- `habit-schedule-rules`
- `day-key-semantics`
- `tracking-domain-generalization`
- `tracking-entry-payloads`
- `android-local-tracker-app`

## AI 开发约定

- 非 trivial 的 AI 代码生成先从一个 `OpenSpec change` 开始，再进入实现
- `openspec/specs` 与 `shared/contracts` 是行为与领域语义真相，AI 不应擅自发明共享字段和规则
- 一个 change 只做一个可独立验证的能力，避免大杂烩式生成
- 实现任务必须写清楚要改哪些目录或文件，以及对应验证命令
- `JS / TS` 文件在接近 `600` 行前要按职责拆分，类型化语言中的函数参数要保持显式类型
