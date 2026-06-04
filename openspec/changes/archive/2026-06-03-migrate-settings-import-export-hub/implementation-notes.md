## 实施摘要

- `ImportExportScreen` 已迁移到 `SettingsPage`、`SettingsSection` 和 `SettingsNavigationRow`。
- Export、Import file、Local Network Migration 三个入口保留原 label/value、icon、haptic gate 和 `buildPlatformPageRoute` navigation。
- 删除 hub 页面 direct `MemoFlowPalette`、dark gradient、page-local section heading 和 `ImportExportCardGroup` / `ImportExportSelectRow` 依赖。
- `settings_ui_drift_guardrail_test.dart` 已将 `import_export_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- `import_export_screen_test.dart` 增加 settings seam 断言，并保留 export/local migration navigation 验证。

## 保留行为

- 未修改 `ExportMemosScreen`、`ImportSourceScreen`、`LocalNetworkMigrationScreen`、`import_export_shared_widgets.dart`、导入/导出文件处理、local network migration、API route/version/model 逻辑、private hooks 或 commercial logic。
- 现有 haptic preference 读取和目标页面路由保持在原入口。

## 验证

- `openspec validate migrate-settings-import-export-hub --strict`
- `flutter test test/features/settings/import_export_screen_test.dart --reporter expanded`
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`
- `flutter analyze`

## 剩余风险

- 本批只覆盖 Import / Export 入口 hub；`ExportMemosScreen`、`import_export_shared_widgets.dart`、`LocalNetworkMigrationScreen`、`memoflow_bridge_screen.dart` 和 `migration/*` 仍留给后续专批。
