## Implementation Notes

本批按 `coordinate-settings-ui-migration-batches` 的第二批 account/server 规则执行。runtime 范围仅覆盖：

- `AccountSecurityScreen`
- `ServerSettingsScreen`

## Visible Changes

- `AccountSecurityScreen` 改为 `SettingsPage` + `SettingsSection`，账户 summary 使用 `SettingsProfileSummary`，账户/本地文库列表使用 `SettingsSelectableItemRow`。
- `AccountSecurityScreen` 的 add account、add local library、user general、server settings、sign out 入口改为 `SettingsNavigationRow`。
- `ServerSettingsScreen` 改为 `SettingsPage`，两个 limit controls 使用 settings section + `SettingsInputRow` + `SettingsAction`。
- `settings_ui.dart` 窄范围扩展：
  - `SettingsInputRow.focusNode`
  - `SettingsInputRow.inputFormatters`
  - `SettingsInputRow.fieldLabel`
  - `SettingsProfileSummary`
  - `SettingsSelectableItemRow`

## Preserved Behavior

- `AccountSecurityScreen` 保留 add account、add local library、user general settings route、server settings route、sign out/remove account、本地文库 switch/scan/rename/remove、dialogs、snackbars 和 haptics。
- `ServerSettingsScreen` 保留 refresh、controller sync、focus blur restore、positive integer validation、save result message、unavailable/read-only state、retry 和 `serverSettingsProvider` provider/API 调用路径。
- 本批未修改 API files、data API tests、request/response models、route adapters、private hooks、commercial logic、WebDAV、AI settings、desktop routing 或 security pages。

## Guardrail State

- `account_security_screen.dart` 和 `server_settings_screen.dart` 已从 `legacyAllowlist` 移入 `migratedFiles`。
- 本批没有新增 `settings_ui_drift_guardrail_test.dart` allowance。

## Verification Results

- `openspec validate migrate-settings-account-server-pages --strict`: passed。
- `flutter test test/features/settings/settings_screen_test.dart --reporter expanded`: passed，`20/20` tests passed。
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`: passed，`1/1` test passed。
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`: passed，`32/32` tests passed。
- `flutter analyze`: passed，`No issues found`。

## Remaining Risks / Follow-up

- `migrate-settings-security-pages` 仍应单独处理 `PasswordLockScreen` 和 `VaultSecurityStatusScreen`。
- `WebDavSyncScreen` 仍 deferred，必须先 dedicated exploration。
- AI / desktop settings routing 仍 deferred，等待相关 active changes 收敛。
