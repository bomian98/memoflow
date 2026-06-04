## 1. 准备与边界

- [x] 1.1 读取 `ApiPluginsScreen`、`WebhooksSettingsScreen`、settings UI seam、focused test harness 和 drift guardrail，确认本批只覆盖 UI layer。
- [x] 1.2 运行 `openspec validate migrate-settings-integrations-pages --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 将 `ApiPluginsScreen` root 迁移到 `SettingsPage` / `SettingsSection`，并用 settings semantic rows/tokens 承载 token creation、expiration selector、loading/error/empty/token rows 和 helper text。
- [x] 2.2 将 `WebhooksSettingsScreen` root 迁移到 `SettingsPage` / `SettingsSection`，并用 settings semantic rows/tokens 承载 webhook list、empty/loading/error state 和 edit/delete actions。
- [x] 2.3 删除 integrations 页面 direct `Scaffold`、direct `MemoFlowPalette`、page-local rounded group/card visual drift；保留 API/provider/repository calls、dialogs、bottom sheets、toasts/snackbars 和 current behavior。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`，将 `api_plugins_screen.dart` 和 `webhooks_settings_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- [x] 3.2 增加 focused widget tests，覆盖 API plugins settings seam usage 与代表性 token UI/state。
- [x] 3.3 增加 focused widget tests，覆盖 webhooks settings seam usage 与 empty/loaded/error 或 row action UI。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-integrations-pages --strict`。
- [x] 4.2 运行 focused integrations settings widget tests。
- [x] 4.3 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.4 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter analyze`。
- [x] 4.6 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
