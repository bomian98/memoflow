## Why

总控 change `coordinate-settings-ui-migration-batches` 已把下一批 settings UI migration 排在 support/general 页面：`FeedbackScreen`、`AboutUsScreen`、`UserGeneralSettingsScreen`。这些页面仍在 `settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 中，并且局部持有 page chrome、card/row geometry、palette token 和 repeated row widgets。继续迁移它们可以缩小 settings legacy allowlist，让更多 settings 页面通过 `SettingsPage`、`SettingsSection`、`SettingsNavigationRow` 和 `SettingsValueRow` 表达语义，而不是各自复制视觉结构。

本 change 复用现有空 scaffold `migrate-settings-account-support-pages`，但实际范围按总控第一批 support/general 执行。`AccountSecurityScreen`、`ServerSettingsScreen`、安全页面、WebDAV、AI 和 desktop routing 不进入本批。

## What Changes

- 将 `FeedbackScreen` 迁移到 settings semantic UI seam，保留提交日志、自修复、外部反馈链接和 haptics 行为。
- 将 `AboutUsScreen` / `AboutUsContent` 迁移到 settings semantic UI seam，保留版本信息、外部链接、捐赠鸣谢入口、发布说明入口和 debug logo tap 行为。
- 将 `UserGeneralSettingsScreen` 迁移到 settings semantic UI seam，保留 locale、default memo visibility、保存状态、错误/重试和 provider/API 调用行为。
- 如现有 `settings_ui.dart` seam 缺少本批必要表达能力，可做窄范围扩展，例如 disabled value row 或 external trailing icon，但不得引入页面特有商业逻辑。
- 更新 `settings_ui_drift_guardrail_test.dart`：把本批三页从 `legacyAllowlist` 移到 `migratedFiles`。
- 增加或更新 focused settings widget tests，覆盖本批页面仍渲染关键入口和 user general 不渲染 server-wide controls。
- 记录验证结果：`openspec validate`、focused tests、settings drift guardrail、相关 architecture guardrail 和 `flutter analyze`。

## Out of Scope

- 不修改 `AccountSecurityScreen`、`ServerSettingsScreen`、`PasswordLockScreen`、`VaultSecurityStatusScreen`、`WebDavSyncScreen`、AI settings 或 desktop routing 页面。
- 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters 或 version compatibility logic。
- 不引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、private overlay 或 `AccessDecision.source` business branching。
- 不改变 user general settings 的业务所有权；`UserGeneralSettingsScreen` 仍只调用既有 provider/API seam。

## Capabilities

### Modified Capabilities

- `platform-adaptive-ui-system`: support/general settings pages SHALL use settings semantic UI seams and SHALL be tracked as migrated by the settings UI drift guardrail.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/feedback_screen.dart`
  - `memos_flutter_app/lib/features/settings/about_us_screen.dart`
  - `memos_flutter_app/lib/features/settings/user_general_settings_screen.dart`
  - `memos_flutter_app/lib/features/settings/settings_ui.dart` only if a narrow shared seam extension is required
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - `memos_flutter_app/test/features/settings/settings_screen_test.dart` or a focused settings widget test file
- Public/private boundary: this change must remain commercial-free and must not alter private extension hooks.
