## 1. 准备与边界

- [x] 1.1 读取 `ShortcutsSettingsScreen`、`ShortcutEditorScreen`、`MemoToolbarSettingsScreen`、settings UI seam、focused shortcut/toolbar tests、drift guardrail 和 modularity guardrail，确认本批只覆盖 shortcuts/toolbar settings UI layer。
- [x] 1.2 运行 `openspec validate migrate-settings-shortcuts-toolbar-surfaces --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 将 `ShortcutsSettingsScreen` root 迁移到 `SettingsPage`，用 settings sections/actions/rows 承载 add action、shortcuts list、空/加载/错误状态和 retry，保留 local/server save/delete、haptics、toast/snackbar、delete confirmation、labels 和 editor route。
- [x] 2.2 将 `ShortcutEditorScreen` page chrome 和主要 form groups 迁移到 settings seams，删除 direct `Scaffold`、page-local `AppBar`、direct `MemoFlowPalette` 等 drift patterns，保留 desktop secondary task surface、filter parsing/building、tag/date picker、visibility/match mode、validation 和 result behavior。
- [x] 2.3 将 `MemoToolbarSettingsScreen` root 和 toolbox/preview grouped surfaces 迁移到 settings seams，保留 drag/drop、add/remove/reset/clear、custom button dialog、desktop preference notification、existing keys 和 labels。
- [x] 2.4 验证 in-scope runtime files 不再命中 direct `Scaffold`、direct `MemoFlowPalette`、page-local `styleFrom`、bare `Switch` / `Switch.adaptive`、private `_ToggleCard` drift patterns。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`，将 `shortcuts_settings_screen.dart`、`shortcut_editor_screen.dart`、`memo_toolbar_settings_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`，保持 `desktop_shortcuts_overview_screen.dart` 和 desktop routing files deferred。
- [x] 3.2 更新 focused shortcut editor tests，覆盖 `SettingsPage`/settings sections/input/action seam、existing editor validation 和 done/cancel behavior。
- [x] 3.3 更新 focused memo toolbar tests，覆盖 `SettingsPage`/settings sections/actions seam，并保留 remove/add/reset/clear/custom button 行为断言。
- [x] 3.4 如现有 tests 没有覆盖 `ShortcutsSettingsScreen`，新增 focused widget test 覆盖 empty/list/error surface 的 settings seam 和 add route label，不触发真实 API 修改。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-shortcuts-toolbar-surfaces --strict`。
- [x] 4.2 运行 focused shortcuts/toolbar widget tests。
- [x] 4.3 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.4 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter analyze`。
- [x] 4.6 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
