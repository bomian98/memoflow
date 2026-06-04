## Why

settings UI migration 已经完成大部分普通 settings 页面，但 `shortcuts_settings_screen.dart`、`shortcut_editor_screen.dart` 和 `memo_toolbar_settings_screen.dart` 仍在 `settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 中，并且仍混用 direct `Scaffold`、page-local `AppBar`、direct `MemoFlowPalette`、local card/segmented/button styling 与 editor-specific surfaces。

本批按 `coordinate-settings-ui-migration-batches` 的总控规则继续收敛 app shortcuts 与 memo toolbar settings/editor surfaces。`desktop_shortcuts_overview_screen.dart`、`desktop_settings_window_app.dart`、AI settings、WebDAV 和 API files 不纳入本批。

## What Changes

- 将 `ShortcutsSettingsScreen` page chrome 迁移到 `SettingsPage`，用 settings sections/actions/rows 承载 shortcuts 列表、空状态、加载/错误状态、add/edit/delete 入口，并保留 local/server shortcut 存储选择、provider invalidation、haptics、toast/snackbar 和删除确认行为。
- 将 `ShortcutEditorScreen` 的 page chrome 与主要 form sections 迁移到 settings seams，保留 desktop secondary task surface、filter parsing/building、tag picker、date range picker、visibility/match mode、validation 和 submit result 行为。
- 将 `MemoToolbarSettingsScreen` root 与 toolbox/preview grouped surfaces 迁移到 settings seams，保留 drag/drop、add/remove/reset/clear、custom button dialog、desktop preference notification 和现有 keys。
- 更新 `settings_ui_drift_guardrail_test.dart`，将本批 3 个 files 从 `legacyAllowlist` 移入 `migratedFiles`。
- 更新/补充 focused widget tests，覆盖 shortcuts/editor/toolbar 已使用 settings semantic seams，同时保留既有行为断言。
- 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `platform-adaptive-ui-system`: app shortcuts、shortcut editor 和 memo toolbar settings surfaces SHALL use settings semantic UI seams and SHALL be tracked as migrated by the settings UI drift guardrail.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/shortcuts_settings_screen.dart`
  - `memos_flutter_app/lib/features/settings/shortcut_editor_screen.dart`
  - `memos_flutter_app/lib/features/settings/memo_toolbar_settings_screen.dart`
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - `memos_flutter_app/test/features/settings/shortcut_editor_screen_test.dart`
  - `memos_flutter_app/test/features/settings/memo_toolbar_settings_screen_test.dart`
  - 可能新增 focused shortcuts settings test
- Out of scope:
  - `desktop_shortcuts_overview_screen.dart`
  - `desktop_settings_window_app.dart`
  - AI settings、WebDAV、API files、migration protocol、private hooks、commercial logic
- Public/private/API boundary: 本批为 UI-only migration，不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters 或 version compatibility logic。
- Architecture phase: `evolve_modularity`。本批触碰 settings feature UI 和 guardrail，必须缩小 drift allowlist，并保持 shortcuts/toolbar behavior owners 不变。
