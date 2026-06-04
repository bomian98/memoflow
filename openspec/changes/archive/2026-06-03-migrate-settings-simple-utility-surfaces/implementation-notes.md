## 实施摘要

- `TemplateSettingsScreen` 已迁移到 `SettingsPage`、`SettingsSection`、`SettingsToggleCard`、`SettingsNavigationRow` 和 settings/theme tokens。
- 模板列表改为 settings section row composition，保留编辑、删除确认、新增模板、变量设置和变量说明 dialog 的原有行为。
- 变量说明 dialog 的表格高度改为按 viewport 收缩，避免小视口或 widget test 中固定高度溢出。
- `WidgetsScreen` 已迁移到 `SettingsPage`、`SettingsSection` 和 `SettingsAction`，保留三类 home widget preview、package version footer、非 Android unsupported toast 和 Android `HomeWidgetService.requestPinWidget` 调用。
- `settings_ui_drift_guardrail_test.dart` 已将 `template_settings_screen.dart` 和 `widgets_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- 新增 `test/features/settings/simple_utility_settings_pages_test.dart`，覆盖模板页 seam/list/dialog 和 widgets 页 seam/action/toast。

## 保留行为

- 未修改 `memoTemplateSettingsProvider`、`MemoTemplateSettingsRepository`、`MemoTemplateSettings` model、UID 生成、provider 触发的 sync request、`HomeWidgetService`、platform channel、package info plugin seam、API route/version/model 逻辑或 private/commercial hooks。
- widgets 页的 Android pin request gate 和非 Android fallback toast 保持在原调用点。

## 验证

- `openspec validate migrate-settings-simple-utility-surfaces --strict`
- `flutter test test/features/settings/simple_utility_settings_pages_test.dart --reporter expanded`
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`
- `flutter analyze`

## 剩余风险

- 本批只覆盖 simple utility settings surfaces；AI、desktop routing/window、import/export、migration、shortcut editor、memo toolbar、quick QR 和 donation dialog 仍留给后续专批。
- widgets preview 内仍有 page-local preview drawing，这是 literal preview content，不是 settings chrome/card/action drift。
