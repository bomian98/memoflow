# 第 1 阶段边界冻结

## 当前规则

第 1 阶段为后续所有工作冻结以下仓库边界规则：

1. 公开仓库在第 1 阶段不得新增 `memos_flutter_app/macos/` 平台脚手架。
2. 公开仓库不得包含 StoreKit 集成、收据校验、权益评估、价格元数据、Apple 签名资源、公证流程、TestFlight/App Store 自动化或其他 Apple 商业运行时逻辑。
3. 第 1 阶段唯一批准的私有 Dart 集成接入点必须保持为 `memos_flutter_app/lib/private_hooks/active_private_extension_bundle.dart`。
4. 公开外壳代码可以依赖 `privateExtensionBundleProvider` 并渲染 bundle 提供的条目，但不得直接导入私有商业实现。
5. Apple 原生外壳行为、Apple 原生商业运行时和 Apple 发布工作流在后续治理变更明确扩大公开归属之前，都仍然属于私有仓库职责。

## 第 1 阶段中的明确公开归属

公开仓库继续负责：

- 共享 Flutter 应用代码
- Android 平台代码
- Windows 平台代码
- 共享同步、存储、数据、状态和功能逻辑
- `lib/private_hooks/` 下的公开桩
- 未来可能抽取为桌面通用的非商业桌面基础设施

## 第 1 阶段明确延期到后续阶段的内容

第 1 阶段期间，公开仓库不得开始以下工作：

- 新增 `memos_flutter_app/macos/`
- 新增 Apple 计费代码
- 新增权益或订阅逻辑
- 新增 Apple 发布脚本或 CI
- 在没有接受的盘点和队列之前进行大规模桌面通用抽取

## 退出条件

当满足以下条件时，第 1 阶段边界冻结视为已接受：

- 本文档存在且已批准
- 归属图已存在
- 热点盘点已存在
- 第 2 阶段重构队列已存在
