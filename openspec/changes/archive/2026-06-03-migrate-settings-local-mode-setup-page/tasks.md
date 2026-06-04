## 1. 准备与边界

- [x] 1.1 读取 `LocalModeSetupScreen`、settings UI seam、focused test、drift guardrail 和 modularity guardrail，确认本批只覆盖 UI layer。
- [x] 1.2 运行 `openspec validate migrate-settings-local-mode-setup-page --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 将 `LocalModeSetupScreen` root 迁移到 `SettingsPage`，并用 settings semantic sections/rows/actions 承载 subtitle、storage info、repository name input、confirm 和 cancel。
- [x] 2.2 删除 direct `Scaffold` 和 page-local card/form visual drift；保留 `LocalModeSetupScreen.show`、trimmed result、empty-name snackbar、debug logging 和 labels。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`，将 `local_mode_setup_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- [x] 3.2 更新 focused widget tests，覆盖 `LocalModeSetupScreen` settings seam usage、storage info visibility、rename result 和 empty-name validation。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-local-mode-setup-page --strict`。
- [x] 4.2 运行 focused local mode setup widget tests。
- [x] 4.3 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.4 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter analyze`。
- [x] 4.6 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
