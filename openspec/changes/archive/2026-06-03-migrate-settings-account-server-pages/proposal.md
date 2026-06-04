## Why

`coordinate-settings-ui-migration-batches` 的第一批 support/general 页面已完成并通过门禁，下一批应推进 account/server settings UI migration。当前 `AccountSecurityScreen` 和 `ServerSettingsScreen` 仍在 `settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 中，并且仍直接持有 page chrome、local card/row geometry、`MemoFlowPalette` token 和 page-local button/list styling。

本 change 只做 account/server 页面视觉与 settings semantic seam 迁移，不改变账户、本地文库、server settings provider 或 API contract。

## What Changes

- 将 `AccountSecurityScreen` 迁移到 `SettingsPage`、`SettingsSection`、`SettingsNavigationRow` 和共享 settings row seam。
- 将 `ServerSettingsScreen` 迁移到 `SettingsPage` 和 settings semantic form sections，保留两个 server limit controls 的保存、刷新、错误、只读和本地文库 unavailable 行为。
- 如现有 `settings_ui.dart` seam 不足，可做窄范围通用扩展，例如 profile summary、selectable account/local-library row、input row focus/formatter 支持、section action row。
- 更新 `settings_ui_drift_guardrail_test.dart`，把 `account_security_screen.dart` 和 `server_settings_screen.dart` 从 `legacyAllowlist` 移到 `migratedFiles`。
- 更新 focused settings widget tests，覆盖 account/server 页面仍渲染关键入口、server fields 行为不变、user general 仍不渲染 server-wide controls。
- 记录验证结果：OpenSpec validate、focused settings tests、settings drift guardrail、modularity guardrail 和 `flutter analyze`。

## Out of Scope

- 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters 或 version compatibility logic。
- 不迁移 `PasswordLockScreen`、`VaultSecurityStatusScreen`、`WebDavSyncScreen`、AI settings 或 desktop routing。
- 不改变 account/session/local library/server settings provider 的业务所有权。
- 不引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、private overlay 或 `AccessDecision.source` business branching。

## Capabilities

### Modified Capabilities

- `platform-adaptive-ui-system`: account/server settings pages SHALL use settings semantic UI seams and SHALL be tracked as migrated by the settings UI drift guardrail.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/account_security_screen.dart`
  - `memos_flutter_app/lib/features/settings/server_settings_screen.dart`
  - `memos_flutter_app/lib/features/settings/settings_ui.dart` only if narrow shared settings seam extensions are required
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - `memos_flutter_app/test/features/settings/settings_screen_test.dart`
- Public/private boundary: must remain commercial-free and must not alter private extension hooks.
