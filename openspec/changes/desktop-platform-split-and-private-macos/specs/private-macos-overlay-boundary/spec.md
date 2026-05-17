## ADDED Requirements

### Requirement: 公开仓库 SHALL 在没有私有商业代码时仍可构建
公开仓库 SHALL 在不依赖私有计费、权益、StoreKit 或 macOS 商业运行时代码的情况下继续构建和运行。

#### Scenario: 单独检出公开仓库
- **WHEN** 在没有私有覆盖仓库的情况下使用公开仓库
- **THEN** 应用必须仅通过公开代码路径和公开桩实现完成构建

### Requirement: 私有集成 SHALL 使用批准的私有接入点
私有仓库中的私有商业集成 SHALL 只能通过 `memos_flutter_app/lib/private_hooks/active_private_extension_bundle.dart` 这个批准的接入点进入公开 Flutter 代码，除非未来治理变更明确扩大接入点范围。

#### Scenario: 接入私有运行时
- **WHEN** 私有 macOS 商业仓库覆盖公开 checkout
- **THEN** 活跃私有 bundle 实现必须替换或提供批准的接入点，且不要求公开外壳文件直接导入私有商业模块

### Requirement: 机密商业数据 MUST NOT 进入公开仓库
公开仓库 MUST NOT 包含产品标识符、订阅档位、收据校验逻辑、权益评估逻辑、价格数据、签名密钥或 App Store 发布自动化。

#### Scenario: 引入新的商业关注点
- **WHEN** 某个变更需要订阅、计费、权益或发布密钥行为
- **THEN** 该行为及其相关数据只能在私有仓库中实现

### Requirement: Apple 平台脚手架在整改计划期间 SHALL 由私有仓库拥有
在后续治理变更另有规定前，macOS 平台脚手架和 Apple 原生商业运行时代码 SHALL 由私有仓库拥有，而不是由公开仓库拥有。

#### Scenario: 添加 macOS 支持
- **WHEN** 为商业版启动 macOS 平台支持
- **THEN** `macos/` 平台项目和 Apple 原生商业集成必须通过私有仓库引入
