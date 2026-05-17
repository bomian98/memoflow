## ADDED Requirements

### Requirement: 第 1 阶段 SHALL 冻结公开/私有仓库边界
在桌面重构开始前，项目 SHALL 明确冻结以下规则：公开仓库不得包含 macOS 平台脚手架、商业运行时逻辑、StoreKit 集成、权益评估、价格元数据或 Apple 发布自动化。

#### Scenario: 第 1 阶段审查公开边界
- **WHEN** 项目批准第 1 阶段基线
- **THEN** 公开/私有边界必须被记录，并作为后续变更的活动规则集

### Requirement: 第 1 阶段 SHALL 保留已批准的私有 Dart 接入点
在第 1 阶段，唯一批准的私有 Dart 集成接入点 SHALL 保持为 `memos_flutter_app/lib/private_hooks/active_private_extension_bundle.dart`。

#### Scenario: 第 1 阶段讨论私有集成
- **WHEN** 在边界冻结阶段提出新的私有集成路径
- **THEN** 除非后续治理变更明确扩大批准接入点，否则必须拒绝

### Requirement: 第 1 阶段 SHALL 阻止在公开仓库中过早启动私有 macOS
在第 1 阶段，公开仓库 MUST NOT 新增 `memos_flutter_app/macos/` 脚手架或 Apple 原生商业运行时代码。

#### Scenario: 第 1 阶段考虑 macOS 脚手架
- **WHEN** 团队在盘点和后续重构队列未获批准前，考虑向公开仓库添加 macOS 平台文件
- **THEN** 该工作必须延期，等待后续变更授权
