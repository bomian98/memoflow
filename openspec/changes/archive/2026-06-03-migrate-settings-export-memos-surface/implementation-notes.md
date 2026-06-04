## 实施记录

本批将 `ExportMemosScreen` 的可见 settings UI 迁移到统一 settings seam：

- 页面 root 改为 `SettingsPage`，不再在页面本地持有 direct `Scaffold`、page-local `AppBar`、desktop titlebar helper 或 direct `MemoFlowPalette` UI token。
- date range、include archived、export format、export action、last export path 与说明文案分别由 `SettingsSection`、`SettingsValueRow`、`SettingsToggleRow`、`SettingsAction`、`SettingsInfoRow` 承载。
- `import_export_shared_widgets.dart` 经仓库范围引用扫描确认无 runtime/tool/workflow/path references 后删除。
- `settings_ui_drift_guardrail_test.dart` 已将 `export_memos_screen.dart` 移入 `migratedFiles`，并移除已删除 shared wrapper 的 legacy tracking。

## 保留行为

本批只修改 UI layer，保留以下导出行为：

- `_export` 主流程、date range picker、`_rangeToUtcSec`、include archived state。
- haptics、top toast、snackbar、完成 dialog、clipboard copy path。
- zip/markdown/sidecar/attachment export、memo filename/path sanitization、attachment bytes reading、导出目录解析和固定 `Markdown + ZIP` 文案。
- 未修改 API files、request/response models、route adapters、version compatibility logic、数据库查询、export data format、WebDAV、local network migration、private hooks 或 commercial logic。

## 验证

- `openspec validate migrate-settings-export-memos-surface --strict`：通过。
- `flutter test test/features/settings/export_memos_screen_test.dart test/features/settings/import_export_screen_test.dart --reporter expanded`：通过。
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`：通过。
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`：通过。
- `flutter analyze`：通过。

## 剩余风险

- focused widget test 覆盖 settings seams、labels、include archived toggle 和 import/export hub navigation；实际 zip 文件生成、附件读取和平台目录写入未在本批 widget test 中执行。
- local network migration、bridge 和 migration 子页面仍属于后续独立 settings UI migration 批次。
