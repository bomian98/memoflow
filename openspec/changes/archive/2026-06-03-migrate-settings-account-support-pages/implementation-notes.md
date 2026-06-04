## Implementation Notes

本批按 `coordinate-settings-ui-migration-batches` 的第一批 support/general 规则执行。实际使用既有 scaffold `migrate-settings-account-support-pages`，但 runtime 范围仅覆盖：

- `FeedbackScreen`
- `AboutUsScreen`
- `UserGeneralSettingsScreen`

## Visible Changes

- `FeedbackScreen` 改为 `SettingsPage` + `SettingsSection` + `SettingsNavigationRow`，提交日志、自助修复和 GitHub issue 外链成为统一 settings row。
- `AboutUsScreen` 改为 `SettingsPage`，关于页 logo / app name / version 保留页面特定展示，官网、隐私、协议、帮助、更新日志、反馈、贡献与致谢改为统一 settings row。
- `UserGeneralSettingsScreen` 改为 `SettingsPage` + `SettingsSection` + `SettingsValueRow`，语言和默认可见性选择行进入 settings semantic seam。
- `settings_ui.dart` 窄范围扩展：
  - `SettingsValueRow.enabled`
  - `SettingsNavigationRow.enabled`
  - `SettingsNavigationRow.trailingIcon`

## Preserved Behavior

- `FeedbackScreen` 保留导出日志、自助修复 route、GitHub issue external launch、haptics 和失败 snackbar。
- `AboutUsScreen` 保留 version rendering、external launch、release notes route、donor wall route 和 debug logo tap 进入 debug tools 的行为。
- `UserGeneralSettingsScreen` 保留 locale / visibility picker、saving guard、`userGeneralSettingProvider` invalidation、`memosApiProvider.updateUserGeneralSetting` 调用和 error retry。
- 本批未修改 `AccountSecurityScreen`、`ServerSettingsScreen`、安全页面、WebDAV、AI settings、desktop routing、API files、private hooks 或 commercial logic。

## Guardrail State

- `feedback_screen.dart`、`about_us_screen.dart`、`user_general_settings_screen.dart` 已从 `legacyAllowlist` 移入 `migratedFiles`。
- 本批没有新增 `settings_ui_drift_guardrail_test.dart` allowance。

## Verification Results

- `openspec validate migrate-settings-account-support-pages --strict`: passed。
- `flutter test test/features/settings/settings_screen_test.dart --reporter expanded`: passed，`19/19` tests passed。
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`: passed，`1/1` test passed。
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`: passed，`32/32` tests passed。
- `flutter analyze`: passed，`No issues found`。

## Remaining Risks / Follow-up

- `migrate-settings-account-server-pages` 仍应单独处理 `AccountSecurityScreen` 和 `ServerSettingsScreen`。
- `migrate-settings-security-pages` 仍应单独处理 `PasswordLockScreen` 和 `VaultSecurityStatusScreen`。
- `WebDavSyncScreen` 仍 deferred，必须先 dedicated exploration。
- AI / desktop settings routing 仍 deferred，等待相关 active changes 收敛。
