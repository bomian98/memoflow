## Implementation Notes

本批按 `coordinate-settings-ui-migration-batches` 的第三批 security 规则执行。runtime 范围仅覆盖：

- `PasswordLockScreen`
- `VaultSecurityStatusScreen`

`VaultSecurityStatusScreen` 是 `webdav_sync_screen.dart` 的 `part`，因此父 file 仅补充 settings/platform presentation imports；未修改 `WebDavSyncScreen` 同步、备份、导入或冲突处理行为。

## Visible Changes

- `PasswordLockScreen` 改为 `SettingsPage` + `SettingsSection`，启用 app lock 使用 `SettingsToggleRow`，修改密码和 auto-lock time 使用 `SettingsNavigationRow`，说明文案使用 `SettingsInfoRow`。
- `VaultSecurityStatusScreen` 改为 `SettingsPage` + `SettingsSection`，Vault 状态项使用 platform list row + settings row text seam，本地明文缓存开关使用 `SettingsToggleRow`，恢复码/清理/备份测试操作使用 `SettingsAction`。
- `webdav_sync_screen.dart` 仅新增 `settings_ui.dart`、`platform_list_section.dart`、`platform_primary_action.dart` imports，供 `vault_security_status_screen.dart` part 使用。

## Preserved Behavior

- `PasswordLockScreen` 保留 enable/disable app lock、设置密码、修改密码、auto-lock picker、`appLockProvider` 写入和 password updated toast。
- `VaultSecurityStatusScreen` 保留 status load、cleanup reminders、恢复码查看、Vault 密码验证、备份恢复测试、本地明文缓存 toggle、清理远端/导出/本地明文、snackbar/toast/dialog 和所有 WebDAV/Vault provider/service 调用路径。
- 本批未修改 API files、data API tests、request/response models、route adapters、private hooks、commercial logic、account/server 页面、完整 `WebDavSyncScreen` flow、AI settings 或 desktop routing。

## Guardrail State

- `password_lock_screen.dart` 和 `vault_security_status_screen.dart` 已从 `legacyAllowlist` 移入 `migratedFiles`。
- 本批没有新增 `settings_ui_drift_guardrail_test.dart` allowance。

## Verification Results

- `openspec validate migrate-settings-security-pages --strict`: passed。
- `flutter test test/features/settings/settings_screen_test.dart --reporter expanded`: passed，`22/22` tests passed。
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`: passed，`1/1` test passed。
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`: passed，`32/32` tests passed。
- `flutter analyze`: passed，`No issues found`。

## Remaining Risks / Follow-up

- `WebDavSyncScreen` 仍 deferred，必须先 dedicated exploration，再决定是否拆 presentation helpers 或 behavior owner。
- AI / desktop settings routing 仍 deferred，等待相关 active changes 收敛后另建 follow-up。
