## Implementation Notes

本批按 UI-only 边界迁移 `LocationSettingsScreen`。runtime 范围只覆盖：

- `memos_flutter_app/lib/features/settings/location_settings_screen.dart`

## Visible Changes

- `LocationSettingsScreen` root 改为 `SettingsPage`。
- enable location control 改为 `SettingsToggleRow`。
- provider picker 改为 `SettingsMenuRow<LocationServiceProvider>`。
- AMap / Baidu / Google key fields 改为 `SettingsInputRow`。
- precision selector 保留本页 `_PrecisionRow`，但改用 `settingsPageTokens` / theme `colorScheme`，不再直接使用 `MemoFlowPalette`。
- 删除 `_Group`、`_ToggleCard`、`_ProviderRow` 和 `_InputRow`。

## Preserved Behavior

- 保留 `locationSettingsProvider` writes：`setEnabled`、`setProvider`、`setAmapWebKey`、`setAmapSecurityKey`、`setBaiduWebKey`、`setGoogleApiKey`、`setPrecision`。
- 保留 text controllers、provider subscription 和 `_dirty` 防覆盖行为。
- 保留 provider-specific conditional input fields。
- 本批未修改 API files、data API tests、location data models、repositories、adapters、permission logic、geocoder behavior、WebDAV config transfer、private hooks、commercial logic、AI settings 或 desktop routing。

## Guardrail State

- `location_settings_screen.dart` 已从 `legacyAllowlist` 移入 `migratedFiles`。
- 本批没有新增 `settings_ui_drift_guardrail_test.dart` allowance。

## Verification Results

- `openspec validate migrate-settings-location-page --strict`: passed。
- `flutter test test/features/settings/location_settings_screen_test.dart --reporter expanded`: passed，`1/1` test passed。
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`: passed，`1/1` test passed。
- `flutter test test/features/settings/desktop_settings_window_app_test.dart --plain-name "initial nested target opens inside the owning settings pane" --reporter expanded`: passed，`1/1` test passed。
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`: passed，`32/32` tests passed。
- `flutter analyze`: passed，`No issues found`。
- 备注：尝试过 `flutter test test/features/settings/desktop_settings_window_app_test.dart --plain-name "location" --reporter expanded`，没有匹配测试名，随后改用上面的完整测试名并通过。

## Remaining Risks / Follow-up

- 本批只验证 UI seam 和 provider write behavior，没有做系统定位权限或 geocoder runtime smoke；这些不属于 UI-only migration 范围。
- AI settings 和 desktop routing remain deferred per total-control rule because related active changes still have pending manual/platform smoke tasks.
