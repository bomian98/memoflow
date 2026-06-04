## 1. 准备与边界

- [x] 1.1 读取 `ImportExportScreen`、settings UI seam、focused test、drift guardrail 和 modularity guardrail，确认本批只覆盖入口 hub UI layer。
- [x] 1.2 运行 `openspec validate migrate-settings-import-export-hub --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 将 `ImportExportScreen` root 迁移到 `SettingsPage` / `SettingsSection`，并用 settings semantic rows/tokens 承载 Export、Import file 和 Local Network Migration entries。
- [x] 2.2 删除 hub 页面 direct `MemoFlowPalette`、dark gradient、page-local card/group visual drift；保留 haptic gate、`showBackButton`、`buildPlatformPageRoute` 和目标页面行为。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`，将 `import_export_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- [x] 3.2 更新 focused widget tests，覆盖 `ImportExportScreen` settings seam usage 和既有 export/local migration navigation 行为。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-import-export-hub --strict`。
- [x] 4.2 运行 focused import/export hub widget tests。
- [x] 4.3 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.4 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter analyze`。
- [x] 4.6 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
