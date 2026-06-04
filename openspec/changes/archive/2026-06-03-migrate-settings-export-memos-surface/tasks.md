## 1. 准备与边界

- [x] 1.1 读取 `ExportMemosScreen`、`import_export_shared_widgets.dart`、settings UI seam、focused tests、drift guardrail 和 modularity guardrail，确认本批只覆盖 export memos UI layer。
- [x] 1.2 运行 `openspec validate migrate-settings-export-memos-surface --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 将 `ExportMemosScreen` root 迁移到 `SettingsPage`，删除 direct `Scaffold`、page-local `AppBar`、desktop titlebar helper import 和 direct `MemoFlowPalette` UI token usage。
- [x] 2.2 用 `SettingsSection`、`SettingsValueRow`、`SettingsToggleRow`、`SettingsAction`、`SettingsInfoRow` 或等价 settings seams 承载 date range、include archived、export format、export action、last export path 和说明文字。
- [x] 2.3 保留 `_export`、range picker、include archived state、haptics、toast/snackbar/dialog、clipboard copy path、zip/markdown/sidecar/attachment export behavior 和 labels。
- [x] 2.4 验证 `import_export_shared_widgets.dart` 引用；若无 runtime/tool/workflow/path references，则删除该文件，否则迁移其 UI seam 并保留。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`，将 `export_memos_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`，并移除或迁移 `import_export_shared_widgets.dart` tracking。
- [x] 3.2 增加 focused export memos widget tests，覆盖 `SettingsPage`、settings rows/actions、include archived toggle 和 export format/date range labels。
- [x] 3.3 确认 import/export hub navigation test 仍能进入 export page 并看到关键 labels。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-export-memos-surface --strict`。
- [x] 4.2 运行 focused export/import-export widget tests。
- [x] 4.3 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.4 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter analyze`。
- [x] 4.6 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
