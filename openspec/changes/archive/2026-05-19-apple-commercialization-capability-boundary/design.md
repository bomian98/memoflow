## Context

当前公开仓已经有 `memos_flutter_app/lib/access_boundary/`、`private_hooks/` 和 `module_boundary/`，并通过 `privateExtensionBundleProvider` 允许私有 overlay 贡献 settings entries 和 app ready hook。私有仓 `memoflow-macos-private` 已经维护 Apple 商业化 PRD 和 macOS overlay，但真实 StoreKit、商品、权益和发布流水线尚未实现。

现有 `AppCapability` 只有粗粒度商业壳能力，无法表达 AI 自定义模板、AI 总结历史、高级统计、桌面原生效率或 Apple 生态增强等产品能力。如果直接接 StoreKit 或在功能 UI 中写订阅判断，会破坏公开/私有边界，并让商业逻辑散落到 shell、共享模型和 widget 中。

当前架构阶段是 `evolve_modularity`，模块化评分基线为 4/10。本 change 触及 checklist item 5、6、8、9、10；设计必须通过 provider boundary、private bundle seam 和 guardrail 防止新增反向依赖或商业状态泄露。

## Goals / Non-Goals

**Goals:**

- 建立公开仓可使用的产品级 `AppCapability` 集合。
- 建立能力查询 seam，让功能代码只关心 capability 是否 enabled。
- 让私有仓通过 `active_private_extension_bundle.dart` 提供真实权益或开发期模拟权益。
- 明确 Free、订阅 Pro、买断 Pro、trial、expired、refunded、unavailable 到能力决策的映射。
- 以 AI 自定义总结模板作为首个 gating 试点，验证入口、执行路径和降级路径。
- 增加 guardrail，防止 StoreKit、商品 ID、价格、收据和商业状态进入公开 shell / shared model。

**Non-Goals:**

- 不接入 StoreKit。
- 不配置 App Store Connect。
- 不实现真实购买、恢复购买、收据校验或服务器权益。
- 不实现签名发布或 App Store 上传。
- 不在公开仓写商品价格、订阅计划、Family Sharing 或买断商业策略。
- 不在本 change 中实现 RSS 第二阶段收费能力。
- 不实现 CloudKit 真同步。

## Decisions

### 1. 公开仓使用产品能力名，不使用商品或套餐名

公开仓的 `AppCapability` 应表达产品行为，例如：

```text
subscriptionCenter
premiumEntitlements
appleCommercialRuntime

aiCustomSummaryTemplates
aiSummaryHistory
advancedStats

desktopNativeCapture
appleICloudDriveIntegration
appleShortcutsIntegration
appleSpotlightIndexing
```

理由：

- 商品、价格、订阅、买断、Family Sharing 都属于私有商业策略。
- 产品能力名可以被 Free、订阅 Pro、买断 Pro、trial 或模拟权益共同映射。
- 公开功能代码不需要知道用户是通过年订阅还是买断获得能力。

考虑过的替代方案：

- 使用 `isPro` 或 `isSubscribed`：拒绝，因为这会把套餐语义扩散到公开功能代码。
- 按商品 ID 命名能力：拒绝，因为商品 ID 必须留在私有仓。

### 2. 能力查询通过 provider boundary 暴露

公开仓应新增或收敛到单一能力查询 provider / service，例如：

```text
feature code
  └─ watches capability decision provider
       └─ delegates to privateExtensionBundleProvider
            └─ active_private_extension_bundle.dart
```

依赖方向：

```text
features/state/application
  -> access_boundary
  -> private_hooks provider seam
```

不允许：

```text
features -> private StoreKit implementation
state    -> features subscription UI
app.dart -> entitlement state machine
```

理由：

- 维持公开 shell 的 composition root 职责。
- 避免 `state -> features` 和 `application -> features` 新增耦合。
- 让测试可以 override provider 验证 Free / Pro / expired 行为。

### 3. 私有 bundle 可提供真实权益或模拟权益，但公开仓只接收 capability decision

私有仓在后续实现中可以维护更丰富的状态：

```text
free
trial
subscriptionPro
buyoutPro
expired
refunded
unavailable
```

公开仓只接收：

```text
AccessDecision(enabled: bool, source: diagnostic string)
```

或等价的 capability decision。`AccessDecision.source` 仍是 diagnostic-only，不能用于路由、可见性或解锁判断。

理由：

- 保护公开仓不承载商业状态。
- 支持开发期模拟权益，但不让模拟开关成为正式 release 的后门。
- 为未来 StoreKit 和服务器权益映射保留空间。

### 4. AI 自定义总结模板作为首个 gating 试点

首个试点选择 AI 自定义总结模板，而不是 iCloud、Shortcuts 或高级统计：

- Free 用户可使用 1 个自定义总结模板。
- Pro / 买断用户可使用多个模板。
- Pro 过期后模板不删除；超出免费额度的模板可查看，但不可使用、不可编辑、不可复制，只能删除。
- 恢复 Pro 后全部模板恢复可用。

理由：

- 边界清楚，能验证“数量限制 + 降级体验 + 执行路径拦截”。
- 不需要 StoreKit 或 Apple 原生 API。
- 适合先测试 capability seam 是否足够。

### 5. 订阅中心仍由 private bundle 贡献 settings entry

公开 `settings_screen.dart` 继续只渲染 `SettingsEntryContribution`，不得直接判断订阅、买断、Family Sharing、trial 或商品状态。

理由：

- 该文件是公开 shell 限制文件。
- 订阅中心文案、商品、价格和购买入口属于私有商业策略。

### 6. Guardrail 是本 change 的模块化改进

在 `evolve_modularity` 阶段，本 change 的模块化改进不是大范围移动代码，而是新增或收紧 guardrail：

- 限制公开 shell import 商业实现。
- 限制共享 model / preference / session 持有商业状态。
- 限制 `decision.source` 被用于业务分支。
- 限制 StoreKit、商品 ID、价格、receipt 等强商业词进入公开 runtime。
- 对新增 capability seam 增加测试，防止功能直接绕过 boundary。

## Risks / Trade-offs

- [能力点过多] → 初期维护成本升高。缓解：只落地首批 MVP 能力点，RSS 和高级导出保留后续阶段。
- [能力点过粗] → 买断和订阅差异无法表达。缓解：用产品行为能力点，不用套餐名；私有权益层负责映射。
- [模拟权益误进 release] → 形成付费绕过风险。缓解：模拟开关只允许私有仓 debug/profile 或明确测试入口；公开仓不包含模拟商业状态。
- [只隐藏入口] → 用户可能从执行路径绕过限制。缓解：spec 要求入口、执行和降级路径都检查 capability。
- [模板锁定体验争议] → 用户可能认为自己的内容被限制。缓解：模板可查看、可删除；只限制使用、编辑和复制。
- [公开/私有边界过窄] → 私有仓实现复杂。缓解：必要时扩展 public seam，但必须先更新 spec 和 guardrail。

## Migration Plan

1. 扩展 `AppCapability` 和能力查询 seam。
2. 保持公开默认 bundle 为 Free / no-op 行为。
3. 在私有 overlay 中实现本地模拟权益映射，但不接 StoreKit。
4. 接入 AI 自定义总结模板试点 gating。
5. 添加 focused tests 和 architecture guardrail。
6. 在私有 worktree 中验证无签名本地构建。

回滚策略：

- 如果能力 seam 设计不适合，回滚到公开默认 no-op bundle 不应影响基础记录能力。
- AI 模板 gating 必须保持数据不删除；回滚时不应破坏用户已有模板。

## Open Questions

- 年订阅是否提供 7 天 Apple 原生 free trial，仍待产品最终确认。
- AI 总结历史记录过期后的精确 UI 行为仍需在对应功能 change 中细化。
- 高级导出的产品定义尚未冻结，不进入本 change。
