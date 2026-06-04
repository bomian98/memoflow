## 实施记录

本批已将 `LocalModeSetupScreen` 从 direct `Scaffold`、page-local `AppBar`、manual `Card` 和 `PlatformBoundedContent` 迁移到 settings semantic UI seam。

## 肉眼可见变化

- 页面 root 改为 `SettingsPage`，并保留约 560px 的 desktop/tablet content width。
- subtitle、storage info、repository name input、confirm action、cancel action 改由 `SettingsSection`、`SettingsInfoRow`、`SettingsInputRow` 和 `SettingsAction` 承载。
- `settings_ui_drift_guardrail_test.dart` 已将 `local_mode_setup_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。

## 保留行为

- 保留 `LocalModeSetupScreen.show` 的 `MaterialPageRoute` 入口。
- 保留 `LocalModeSetupResult` 与 trimmed repository name 返回行为。
- 保留空名称 snackbar validation message。
- 保留 cancel `maybePop` 行为、existing labels、storage info visibility 和 debug logging。
- 未修改 API files、request/response models、route adapters、local persistence、sync、WebDAV、private hooks 或 commercial logic。

## 验证

- `openspec validate migrate-settings-local-mode-setup-page --strict`
- `flutter test test/features/settings/local_mode_setup_screen_test.dart --reporter expanded`
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`
- `flutter analyze`

以上均通过。

## 剩余风险

- 本批不迁移 larger local migration surfaces，例如 `local_network_migration_screen.dart`、`memoflow_bridge_screen.dart` 或 `migration/*`；它们仍需后续 dedicated batch。
