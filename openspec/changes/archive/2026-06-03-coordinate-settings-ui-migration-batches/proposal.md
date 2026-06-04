## Why

settings UI 迁移已经完成了 Preferences、Components、Settings home、图床和图片压缩等高感知页面，但 remaining allowlist 仍包含账户、安全、支持、WebDAV、AI、桌面设置窗口等多类复杂页面。下一阶段需要先写清楚分批探索、子 change 边界、自动有序 apply、验证门禁和暂停条件，避免把大页面、路由工作和普通视觉 cleanup 混在同一批里。

项目当前处于 `evolve_modularity` 阶段。本变更不直接迁移运行时代码，但会建立后续 settings UI migration 的规则，主要影响模块化清单中的 4（共享 UI 逻辑不继续藏在 screen-local widgets）、6（通过 settings seam / child change 边界协作）、8（guardrail 防止视觉漂移回归）和 10（每个触及批次必须让结构不变或更好）。

## What Changes

- 定义 settings UI 迁移总控规则：先探索、再拆子 change、按固定顺序逐个 apply、每批通过验证后才进入下一批。
- 明确总控 change 只负责规则、编排、验收策略和子 change 边界，不直接修改 `memos_flutter_app/lib/features/settings` 页面实现。
- 建议下一阶段子 change 拆分：
  - `migrate-settings-support-pages`: `FeedbackScreen`、`AboutUsScreen`、`UserGeneralSettingsScreen`。
  - `migrate-settings-account-server-pages`: `AccountSecurityScreen`、`ServerSettingsScreen`。
  - `migrate-settings-security-pages`: `PasswordLockScreen`、`VaultSecurityStatusScreen`。
  - `migrate-settings-webdav-page`: `WebDavSyncScreen` 单独处理。
  - AI / desktop settings routing 相关页面暂缓，等待现有 active changes 收敛后再纳入。
- 建立自动 apply 规则：子 change 必须无重叠或明确顺序、必须读取各自 contextFiles、完成 focused tests / guardrails 后才能继续下一批。
- 建立强制暂停规则：需求不清、设计发现冲突、涉及 API 文件、public/private 边界风险、guardrail/test/analyze 失败、WebDAV/AI/desktop 路由范围膨胀时必须暂停。
- 建立最后统一验收策略：每个子 change 独立记录验证结果，最后输出肉眼验收清单，允许用户一次性验收。
- 不在本 change 中执行页面迁移，不新增第三方依赖，不触碰 `memos_flutter_app/lib/data/api` 或 `memos_flutter_app/test/data/api`。

## Capabilities

### New Capabilities

- 无。本变更是 `platform-adaptive-ui-system` 下 settings UI 迁移规则的延续，不引入独立产品能力。

### Modified Capabilities

- `platform-adaptive-ui-system`: 补充 settings UI 后续迁移批次的总控规则，要求子 change 有明确边界、顺序、自动继续门禁、暂停条件、验证记录和最终统一验收清单。

## Impact

- Affected OpenSpec: `openspec/changes/coordinate-settings-ui-migration-batches/*` 和 `platform-adaptive-ui-system` delta spec。
- Potential future child changes: settings support/account/security/WebDAV 页面迁移 change；这些子 change 才会触碰运行时代码。
- Affected tests/guardrails in future child changes: `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`、settings focused widget tests、`modularity_dependency_guardrail_test.dart`、`flutter analyze` 和必要的 focused provider/behavior tests。
- Dependencies: 不新增第三方依赖。
- Public/private boundary: 后续所有子 change 都不得引入 subscription、billing、entitlement、StoreKit、receipt、paywall、product ID、private overlay 或 `AccessDecision.source` business branching。
