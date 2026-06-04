## Why

`coordinate-settings-ui-migration-batches` 的第三批安全页面迁移覆盖 `PasswordLockScreen` 与 `VaultSecurityStatusScreen`。这两个页面仍在 `settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 中，并且各自持有 direct `Scaffold`、page-local card/row geometry、bare switch 和 direct `MemoFlowPalette` styling。

本 change 只做 security settings 页面 presentation migration，让安全设置与已迁移的 Preferences、Components、support/general、account/server 页面使用同一组 settings semantic seams。密码锁、Vault 状态读取、确认弹窗、清理动作和备份验证行为必须保持原有 owner 与调用路径。

## What Changes

- 将 `PasswordLockScreen` 迁移到 `SettingsPage`、`SettingsSection`、`SettingsToggleRow`、`SettingsValueRow`、`SettingsNavigationRow` 或等价 settings seams。
- 将 `VaultSecurityStatusScreen` 迁移到 settings semantic page/section/row/action seams，保留现有 WebDAV/Vault provider/service 调用路径。
- 如 `VaultSecurityStatusScreen` 因 `part of webdav_sync_screen.dart` 需要 settings seam import，可在父 file 仅补 presentation import，不改变 `WebDavSyncScreen` runtime behavior。
- 更新 `settings_ui_drift_guardrail_test.dart`，把 `password_lock_screen.dart` 和 `vault_security_status_screen.dart` 从 `legacyAllowlist` 移到 `migratedFiles`。
- 增加或更新 focused settings widget tests，覆盖 password lock 与 Vault status 页面仍渲染关键安全 controls/actions。
- 记录验证结果：OpenSpec validate、focused tests、settings drift guardrail、modularity guardrail 和 `flutter analyze`。

## Out of Scope

- 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters 或 version compatibility logic。
- 不迁移 account/server、完整 `WebDavSyncScreen`、AI settings、desktop routing 或 deferred large flow。
- 不改变 WebDAV sync behavior、Vault 加密/解密/备份/导入 provider/service ownership 或 data model。
- 不引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、private overlay 或 `AccessDecision.source` business branching。

## Capabilities

### Modified Capabilities

- `platform-adaptive-ui-system`: security settings pages SHALL use settings semantic UI seams and SHALL be tracked as migrated by the settings UI drift guardrail.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/password_lock_screen.dart`
  - `memos_flutter_app/lib/features/settings/vault_security_status_screen.dart`
  - `memos_flutter_app/lib/features/settings/webdav_sync_screen.dart` only if needed for a presentation-only import used by the part file
  - `memos_flutter_app/lib/features/settings/settings_ui.dart` only if a narrow shared security presentation seam is required
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - `memos_flutter_app/test/features/settings/settings_screen_test.dart` or a focused settings widget test file
- Public/private boundary: must remain commercial-free and must not alter private extension hooks.
