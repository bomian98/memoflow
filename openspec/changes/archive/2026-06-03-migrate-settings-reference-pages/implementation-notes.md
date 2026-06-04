## Implementation Notes

本批在 `coordinate-settings-ui-migration-batches` 默认四批完成后，继续推进一个不与 AI / desktop active changes 交叠的 reference / entry pages 批次。runtime 范围覆盖：

- `LaboratoryScreen`
- `UserGuideScreen`
- `SettingsPlaceholderScreen`

## Visible Changes

- `LaboratoryScreen` 改为 `SettingsPage` + `SettingsSection` + `SettingsNavigationRow`，实验入口列表与其他已迁移 settings 页面使用同一 page chrome 和 row seam。
- `UserGuideScreen` 改为 `SettingsPage` + `SettingsSection` + `SettingsNavigationRow`，外部文档入口、说明条目和底部提示使用 settings tokens。
- `SettingsPlaceholderScreen` 改为 `SettingsPage` + `SettingsSection` + `SettingsProfileSummary`，占位信息从本地卡片迁入 semantic settings section。
- 本批没有修改 `settings_ui.dart` shared seam。

## Preserved Behavior

- 保留 `LaboratoryScreen` 的所有入口目标、`showBackButton` 行为、`PackageInfo` 版本展示和 MemoFlow identity block。
- 保留 `UserGuideScreen` 的 usememos docs URL、url launcher snackbar fallback、haptics gate、Windows adaptive surface、bottom sheet info surface 和所有说明文案。
- 保留 `SettingsPlaceholderScreen` 的 dynamic legacy string key lookup 和 route dismissal behavior。
- 本批未修改 API files、data API tests、private hooks、commercial logic、AI settings、desktop routing、import/export、WebDAV、shortcut editor 或 account/server/security flows。

## Guardrail State

- `laboratory_screen.dart`、`user_guide_screen.dart`、`placeholder_settings_screen.dart` 已从 `legacyAllowlist` 移入 `migratedFiles`。
- 本批没有新增 `settings_ui_drift_guardrail_test.dart` allowance。

## Verification Results

- `openspec validate migrate-settings-reference-pages --strict`: passed。
- `flutter test test/features/settings/reference_settings_pages_test.dart --reporter expanded`: passed，`3/3` tests passed。
- `flutter test test/features/settings/settings_screen_test.dart --reporter expanded`: passed，`22/22` tests passed。
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`: passed，`1/1` test passed。
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`: passed，`32/32` tests passed。
- `flutter analyze`: passed，`No issues found`。

## Remaining Risks / Follow-up

- AI settings and desktop routing remain deferred per total-control rule because related active changes still have pending manual/platform smoke tasks.
- Remaining legacy settings files include behavior-heavy customization, import/export, migration, local mode, location, self-repair, webhooks/API/plugin, donation/QR, and AI/desktop surfaces; they should be split into dedicated future batches rather than mixed into this reference batch.
