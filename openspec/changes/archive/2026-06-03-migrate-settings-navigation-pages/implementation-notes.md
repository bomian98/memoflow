## Implementation Notes

本批继续推进 settings UI migration，范围覆盖 navigation / home customization settings：

- `NavigationModeScreen`
- `BottomNavigationModeSettingsScreen`
- `CustomizeDrawerScreen`
- `CustomizeHomeShortcutsScreen`

## Visible Changes

- `NavigationModeScreen` 改为 `SettingsPage` + `SettingsSection` + `SettingsSelectableItemRow`，bottom settings 独立入口改为 `SettingsNavigationRow`。
- `BottomNavigationModeSettingsScreen` 改为 `SettingsPage` + `SettingsSection`，slot rows 使用 `SettingsNavigationRow`，center fixed action 使用 platform list row，preview 保留本页 helper 并改用 settings/theme tokens。
- `CustomizeDrawerScreen` 改为 `SettingsPage` + `SettingsSection` + `SettingsToggleRow`，删除本地 `_ToggleRow` / `_Group` / bare `Switch`。
- `CustomizeHomeShortcutsScreen` 改为 `SettingsPage` + `SettingsSection` + `SettingsNavigationRow`，slot picker dialog 保留原有 `RadioListTile` 行为并改用 theme primary color。
- 本批没有修改 `settings_ui.dart` shared seam。

## Preserved Behavior

- 保留 `NavigationModeScreen.classicOptionKey`、`bottomSelectKey`、`bottomSettingsKey`，保留 classic / bottom bar mode provider writes 和 bottom settings disabled-then-enabled 行为。
- 保留 bottom navigation preview、slot picker、center action fixed row、unavailable destination filtering、duplicate destination disabling 和 `setHomeNavigationSlot` writes。
- 保留 drawer visibility toggles 对 `currentWorkspacePreferencesProvider` 的所有 setter。
- 保留 home shortcut three-slot resolver、local-only / signed-in candidates、used action disabled state 和 `setHomeQuickActions` writes。
- 本批未修改 API files、data API tests、private hooks、commercial logic、AI settings、desktop routing、import/export、WebDAV、shortcut editor 或 memo toolbar flows。

## Guardrail State

- `navigation_mode_screen.dart`、`bottom_navigation_mode_settings_screen.dart`、`customize_drawer_screen.dart`、`customize_home_shortcuts_screen.dart` 已从 `legacyAllowlist` 移入 `migratedFiles`。
- 本批没有新增 `settings_ui_drift_guardrail_test.dart` allowance。

## Verification Results

- `openspec validate migrate-settings-navigation-pages --strict`: passed。
- `flutter test test/features/settings/navigation_mode_screen_test.dart --reporter expanded`: passed，`4/4` tests passed。
- `flutter test test/features/settings/settings_screen_test.dart --reporter expanded`: passed，`22/22` tests passed。
- `flutter test test/features/collections/collections_entry_test.dart --reporter expanded`: passed，`6/6` tests passed。
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`: passed，`1/1` test passed。
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`: passed，`32/32` tests passed。
- `flutter analyze`: passed，`No issues found`。

## Remaining Risks / Follow-up

- AI settings and desktop routing remain deferred per total-control rule because related active changes still have pending manual/platform smoke tasks.
- Remaining legacy settings files include import/export, migration, local mode/network migration, location, self-repair, webhooks/API plugins, donation/QR, shortcut editor, memo toolbar, templates, widgets, and AI/desktop surfaces. Behavior-heavy groups should continue as dedicated future batches.
