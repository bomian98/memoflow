## Why

Apple 平台商业化 PRD 已经明确 Free / Pro / 买断版的产品边界，但公开仓当前只有粗粒度的 `AppCapability.subscriptionCenter`、`premiumEntitlements` 和 `iosCommercialRuntime`，还不能表达具体产品能力，也不能支撑入口、执行路径和降级路径的统一 gating。

现在需要先建立 Apple 商业化能力边界和模拟权益模型，再进入 StoreKit 或具体付费功能开发，避免商业逻辑散落到公开 shell、共享模型或功能 widget 中。

## What Changes

- 扩展公开仓可感知的 `AppCapability` 产品能力点，用产品能力名表达 AI 模板、AI 历史、高级统计、桌面原生效率和 Apple 生态增强。
- 建立公开仓能力查询 seam，使功能代码只依赖能力决策，不依赖订阅、价格、商品 ID、StoreKit、收据或权益状态。
- 定义私有仓通过 `active_private_extension_bundle.dart` 提供真实权益或本地模拟权益的职责边界。
- 定义 Free、订阅 Pro、买断 Pro、过期、退款、不可用等状态到能力决策的映射规则。
- 定义首个试点能力：AI 自定义总结模板。免费用户可用 1 个模板；Pro / 买断用户可用多个；过期后超额模板可查看、不可使用、不可编辑、不可复制，只能删除。
- 定义订阅中心入口仍由 private bundle 贡献；公开 `settings_screen.dart` 不做订阅、权益或商品判断。
- 增加 guardrail / 测试要求，防止 StoreKit、商品 ID、价格、权益状态或商业分支进入公开 shell 和共享公共模型。
- 不在本 change 中接入 StoreKit、不配置 App Store Connect、不实现真实购买/恢复购买、不实现签名发布。

## Capabilities

### New Capabilities

- `apple-commercialization-capability-boundary`: 定义 Apple 商业化能力边界、公开仓能力查询 seam、私有仓权益提供方式、模拟权益、Free / Pro / 买断 / 过期状态映射，以及首个 AI 模板 gating 试点规则。

### Modified Capabilities

- 无。

## Impact

- 影响公开仓 `memos_flutter_app/lib/access_boundary/`、`memos_flutter_app/lib/private_hooks/`、相关能力 provider / boundary seam，以及首个试点功能涉及的 AI 模板入口和执行路径。
- 影响私有仓 overlay 中 `active_private_extension_bundle.dart` 的后续实现方式，但真实 StoreKit、商品配置、价格、收据校验和发布脚本仍归私有仓后续 change。
- 需要新增或调整架构 guardrail，保护 `app.dart`、`main.dart`、`settings_screen.dart`、共享 session / preferences / account 模型不承载商业状态。
- 当前架构阶段为 `evolve_modularity`。本 change 触及 modularity checklist 的 item 5、6、8、9、10，并通过集中能力 seam 和 guardrail 避免新增 `state -> features`、`application -> features` 或公开 shell 商业分支。
