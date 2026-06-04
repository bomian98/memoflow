## 1. 准备与边界

- [x] 1.1 读取 `ExportLogsScreen`、`SelfRepairScreen`、settings UI seam、focused test harness、drift guardrail 和 modularity guardrail，确认本批只覆盖 UI layer。
- [x] 1.2 运行 `openspec validate migrate-settings-utility-pages --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 将 `SelfRepairScreen` root 迁移到 `SettingsPage` / `SettingsSection`，并用 settings semantic rows/tokens 承载 repair actions、running/disabled state 和 local-only note。
- [x] 2.2 将 `ExportLogsScreen` root 迁移到 `SettingsPage` / `SettingsSection`，并用 settings semantic rows/tokens 承载 include toggles、network logging toggle、note input、actions、last path 和 helper notes。
- [x] 2.3 删除 utility 页面 direct `Scaffold`、direct `MemoFlowPalette`、bare `Switch`、page-local rounded group/card visual drift；保留 provider/service calls、dialogs、file/path logic、toasts/snackbars、clipboard 和 current behavior。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`，将 `export_logs_screen.dart` 和 `self_repair_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- [x] 3.2 增加 focused widget tests，覆盖 `SelfRepairScreen` settings seam usage 和代表性 confirmation/action UI。
- [x] 3.3 增加 focused widget tests，覆盖 `ExportLogsScreen` settings seam usage、toggle/note UI 和 action rows，不触发真实文件导出。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-utility-pages --strict`。
- [x] 4.2 运行 focused utility settings widget tests。
- [x] 4.3 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.4 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter analyze`。
- [x] 4.6 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
