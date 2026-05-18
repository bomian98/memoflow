## Why

AI 总结已经具备模板化分析能力，`apple-commercialization-capability-boundary` 也已经落地 `AppCapability.aiSummaryHistory` 这个产品级能力点。现在缺少的是一个真正面向用户的成品能力：用户生成 AI 总结后，结果难以回看、复用、对比，也难以沉淀为长期知识资产。

这个 change 以 AI 总结历史作为能力边界后的第一个成品功能。目标不是继续扩展商业化框架，而是把一个可感知的产品功能做完整，并验证公开功能代码只依赖 `capability decision` 的模式。公开仓仍然不接入 StoreKit，不写商品、价格、收据或原始权益状态，也不让商业逻辑进入 public shell 或共享模型。

## What Changes

- 为已完成的 AI 总结 / AI insight 结果增加本地历史记录。
- 在现有 AI 总结页面提供历史入口，展示历史运行记录，包括模板标题、来源范围、生成时间和结果预览。
- 提供历史详情页，用于查看已保存结果、复制结果文本，并在产品规则允许时复用相同模板或范围重新生成。
- 通过 `AppCapability.aiSummaryHistory` 控制历史保留额度和受限操作：
  - public/default 行为保留小额度的 Free 基线历史。
  - private-enabled / Pro / buyout 行为可保留和浏览更多历史。
  - expired / downgraded 行为不得自动删除用户历史；超出当前可用额度的记录按最终产品规则限制操作。
- 商业状态映射继续留在 private overlay。公开代码只能读取 `appCapabilityEnabledProvider(AppCapability.aiSummaryHistory)` 或等价的产品级能力决策。
- 增加测试和 guardrail，覆盖 public 默认行为、能力启用行为、降级保留行为，以及无商业实现泄漏。

## Capabilities

### New Capabilities

- `ai-summary-history`: 定义 AI 总结结果持久化、历史列表/详情、保留和降级语义、通过 `AppCapability.aiSummaryHistory` 接入能力边界，以及 public/private 商业边界。

### Dependencies

- 依赖 `apple-commercialization-capability-boundary`。
- 复用现有 AI 总结和模板基础设施，主要涉及 `memos_flutter_app/lib/features/review/` 以及 AI settings/state providers。

### Related Changes

- `aiCustomSummaryTemplates` gating 已由 `apple-commercialization-capability-boundary` 覆盖。
- 真实 StoreKit 购买、恢复购买、收据校验、商品 ID、价格和订阅中心实现仍然不在本 change 范围内。

## Impact

- 影响运行时代码：AI 总结页面、AI insight 结果流、AI 总结历史本地持久化、历史列表/详情 UI、localization 和测试。
- 影响架构边界：这是第一个继续复用商业能力边界的成品功能；历史写入和读取应由 repository / provider / service 承担，而不是继续堆在 screen-local state 里。
- 不计划修改 Memos server API route、request/response model、version adapter 或 `memos_flutter_app/lib/data/api`。
- 不在 public runtime 中加入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID 或 price 逻辑。
- 当前架构阶段：`evolve_modularity`。
- 触及 modularity checklist：item 4（避免把可复用历史/持久化逻辑藏在 widget 内）、item 7（历史写路径需要清晰 owner）、item 8（能力和商业泄漏 guardrail）、item 10（触及 AI 总结区域后结构应不变差）。

## Non-Goals

- 不实现 StoreKit、App Store Connect 商品、购买、恢复购买、收据校验或签名发布。
- 不把商业状态加入 `AppPreferences`、session/account models、update config、donor config 或通用 public repositories。
- 不使用 `AccessDecision.source` 做 UI 可见性、路由、解锁或 feature flag。
- 不修改 Memos server API 兼容层。
- 不实现 AI 总结历史的跨设备同步。
- 不实现 AI chat history 或任意 AI task history，本 change 只覆盖 AI 总结 / insight 结果。
- 不自动把 AI 总结历史发布为 memos；如果后续需要，应另开 change 设计。
