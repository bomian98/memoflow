## 实现记录

### 肉眼可见变化

- `ShortcutsSettingsScreen` 现在使用 `SettingsPage`、`SettingsSection`、settings rows/actions 展示 add action、shortcuts 列表、空状态、加载状态、错误状态和 retry action。
- `ShortcutEditorScreen` 普通路由现在使用 `SettingsPage`，嵌入桌面 task surface 继续使用 `PlatformSecondaryTaskFrame`，并通过 settings sections/input/action 承载 name、match mode、tags、created date 和 visibility 条件。
- `MemoToolbarSettingsScreen` 现在使用 `SettingsPage` 和两个 `SettingsSection` 展示 toolbox 与 toolbar preview，高层分组不再使用 page-local `Scaffold` / `AppBar` / palette。
- `settings_ui_drift_guardrail_test.dart` 已将 `shortcuts_settings_screen.dart`、`shortcut_editor_screen.dart`、`memo_toolbar_settings_screen.dart` 移入 `migratedFiles`；`desktop_shortcuts_overview_screen.dart` 和 desktop routing files 保持 deferred。

### 保留行为

- 保留 shortcut local/server fallback、save/delete calls、provider invalidation、haptics、toast/snackbar、delete confirmation、unsupported-server error formatting、editor route 和 labels。
- 保留 shortcut editor 的 desktop secondary task surface、filter parsing/building、tag picker、date range picker、visibility/match mode、validation 和 `ShortcutEditorResult` 行为。
- 保留 memo toolbar editor 的 drag/drop、add/remove/reset/clear、custom button dialog、icon catalog behavior、desktop preference notification、existing `ValueKey`s 和 labels。
- 未修改 API route adapters、request/response models、shortcut data model、local shortcut repository semantics、memo search/filter grammar、`MemoToolbarPreferences`、desktop quick-input channel、private hooks 或 commercial logic。

### 验证结果

- `openspec validate migrate-settings-shortcuts-toolbar-surfaces --strict`：通过。
- `flutter test test/features/settings/shortcut_editor_screen_test.dart test/features/settings/memo_toolbar_settings_screen_test.dart test/features/settings/shortcuts_settings_screen_test.dart --reporter expanded`：通过，13 个 focused widget tests 全部通过。
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`：通过。
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`：通过。
- `flutter analyze`：通过，无 issues。
- `rg -n "return\s+Scaffold|desktop_titlebar_navigation_policy|MemoFlowPalette|SwitchListTile|styleFrom|\bSwitch\s*\(|Switch\.adaptive|class\s+_ToggleCard" ...`：in-scope runtime files 无匹配。

### 剩余风险

- Focused tests 覆盖 settings seams、shortcut editor result、toolbar drag/drop/reset/clear/custom button behavior，但不执行真实 server shortcut API mutation。
- `desktop_shortcuts_overview_screen.dart`、`desktop_settings_window_app.dart` 仍按总控规则 deferred，等待 desktop routing/window active changes 收敛后单独处理。
- AI settings 和 WebDAV 不属于本批。
