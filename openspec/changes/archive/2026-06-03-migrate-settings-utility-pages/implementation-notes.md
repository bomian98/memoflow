## 实现摘要

- `SelfRepairScreen` 已迁移到 `SettingsPage` / `SettingsSection`，repair actions、running/disabled state 和 local-only note 通过 settings seam / `PlatformListSectionRow` / `settingsPageTokens` 渲染。
- `ExportLogsScreen` 已迁移到 `SettingsPage` / `SettingsSection`，include toggles、network logging toggle、note input、actions、last path row 和 helper notes 通过 settings semantic rows 渲染。
- `settings_ui_drift_guardrail_test.dart` 已将 `export_logs_screen.dart` 和 `self_repair_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- 新增 `test/features/settings/utility_settings_pages_test.dart`，覆盖 self repair seam/confirmation dialog，以及 export logs seam/toggle/note/clear confirmation UI。

## 保留行为

- `SelfRepairScreen` 的 confirmation dialog、`selfRepairMutationServiceProvider` calls、running state、haptic gate、snackbar success/error 行为保持原 owner 和路径。
- `ExportLogsScreen` 的 log report generation、export directory/path resolution、file writing、log bundle export、log clearing、device preference writes、clipboard copy、toast/snackbar 和 busy/clearing state 保持原 owner 和路径。
- 未修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters、version compatibility logic、database repair service、logging providers/stores、WebDAV behavior、private hooks 或 commercial logic。

## 验证

- `openspec validate migrate-settings-utility-pages --strict`
- `flutter test test/features/settings/utility_settings_pages_test.dart --reporter expanded`
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`
- `flutter analyze`

## 剩余风险

- focused tests 不触发真实文件导出或数据库 repair mutation，避免 UI migration 扩大到 filesystem/database behavior；这些行为由既有 provider/service 测试和 runtime owner 保持。
- AI settings、desktop routing/window、import/export/migration、shortcut editor、memo toolbar、quick QR 和 donation dialog 仍在后续批次范围。
