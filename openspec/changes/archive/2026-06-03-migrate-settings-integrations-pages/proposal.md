## Why

`ApiPluginsScreen` 和 `WebhooksSettingsScreen` 仍在 `settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 中，并各自持有本地 `Scaffold`、dark gradient、rounded card/group、direct `MemoFlowPalette` 和 page-local list/button/input styling。两个页面的 token/webhook 行为 owner 已在现有 API/provider/repository surface 中，本 change 只迁移 settings UI seam，不修改 API、request/response model、route adapter、repository 或 provider 行为。

继续迁移 integrations settings 页面可以缩小 settings legacy allowlist，同时保持 personal access token 创建/复制/刷新、webhook 添加/编辑/删除和加载错误处理行为不变。

## What Changes

- 将 `ApiPluginsScreen` root 迁移到 `SettingsPage` / `SettingsSection`，并用 settings semantic rows/tokens 承载创建 token 表单、expiration selector、token list、empty/loading/error/footer 状态。
- 将 `WebhooksSettingsScreen` root 迁移到 `SettingsPage` / `SettingsSection`，并用 settings semantic rows/tokens 承载 webhook list、empty/loading/error 状态和 edit/delete actions。
- 允许页面保留必要的本地交互 helper，例如 token created bottom sheet、webhook edit dialog、token status badge 和 action row，但这些 helper MUST 通过 `settingsPageTokens`、theme colors 或 settings/platform seams 获取视觉参数。
- 更新 `settings_ui_drift_guardrail_test.dart`：将 `api_plugins_screen.dart` 和 `webhooks_settings_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- 增加或更新 focused widget tests，覆盖 integrations 页面使用 settings seam、provider/API 行为仍通过现有 seam 触发、空/错误或行操作 UI 可渲染。

## Out of Scope

- 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters 或 version compatibility logic。
- 不修改 `memosApiProvider`、`personalAccessTokenRepositoryProvider`、`userWebhooksProvider`、repository implementation、API endpoint behavior、token/webhook data models 或 server compatibility behavior。
- 不修改 AI settings、desktop routing/window、desktop shortcut overview、import/export、migration、shortcut editor、memo toolbar 或 commercial/private hooks。
- 不引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、private overlay 或 `AccessDecision.source` business branching。

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `platform-adaptive-ui-system`: integrations settings pages SHALL use settings semantic UI seams and SHALL be tracked as migrated by the settings UI drift guardrail.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/api_plugins_screen.dart`
  - `memos_flutter_app/lib/features/settings/webhooks_settings_screen.dart`
  - `memos_flutter_app/lib/features/settings/settings_ui.dart` if a small shared settings row/helper is needed
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - focused settings widget tests for API plugins and webhooks settings pages
- Public/private/API boundary: this is a UI-only change and must not edit API files, data models, route adapters, repositories, provider behavior, private hooks, or commercial logic.
- Architecture phase: `evolve_modularity`; this change touches settings feature UI and guardrails, not known `state -> features`, `application -> features`, or `core -> higher-layer` hotspots. The modularity improvement is shrinking the settings UI drift allowlist and keeping future settings surfaces behind semantic seams.
