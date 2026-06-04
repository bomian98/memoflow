## ADDED Requirements

### Requirement: Shortcuts and toolbar settings surfaces SHALL use semantic settings UI seams

`ShortcutsSettingsScreen`, `ShortcutEditorScreen`, and `MemoToolbarSettingsScreen` SHALL render page chrome, grouped list/form/editor surfaces, status rows, action rows, manual inputs, high-level editor sections, toolbar toolbox/preview groups, explanatory notes, and empty/error states through `SettingsPage`, `SettingsSection`, settings row/action/input components, `settingsPageTokens`, platform controls, theme colors, or equivalent settings/platform seams instead of local scaffold/card/palette/button implementations.

#### Scenario: App shortcuts list is migrated

- **WHEN** `ShortcutsSettingsScreen` renders page chrome, add action, shortcuts list, shortcut rows, empty state, loading state, error state, retry action, edit action, delete action, or delete confirmation entry point
- **THEN** those visible settings surfaces SHALL use settings semantic seams or equivalent settings/platform seams
- **AND** haptics, local/server shortcut selection, provider invalidation, save/delete calls, toast/snackbar behavior, delete confirmation labels, unsupported-server error formatting, shortcut labels, and route to `ShortcutEditorScreen` SHALL be preserved
- **AND** the change SHALL NOT modify API route adapters, request/response models, shortcut data models, local shortcut repository semantics, or server compatibility logic

#### Scenario: Shortcut editor is migrated

- **WHEN** `ShortcutEditorScreen` renders title/name input, match mode, unsupported-filter warning, tag condition, created date condition, visibility condition, tag picker entry, date range picker entry, clear actions, cancel/done actions, embedded desktop task surface content, or validation messages
- **THEN** page chrome and grouped visible editor surfaces SHALL use settings semantic seams or equivalent settings/platform seams
- **AND** desktop secondary task surface selection, filter parsing/building, tag selection, date range selection, visibility selection, validation, `ShortcutEditorResult`, and existing labels SHALL be preserved
- **AND** the change SHALL NOT modify shortcut filter grammar, memo search semantics, tag providers, or desktop secondary task surface policy

#### Scenario: Memo toolbar settings editor is migrated

- **WHEN** `MemoToolbarSettingsScreen` renders page chrome, restore defaults, toolbox section, create custom button action, toolbox items, toolbar preview section, clear action, drag/drop targets, add/remove actions, empty toolbox state, custom button dialog entry, or explanatory copy
- **THEN** page chrome and high-level grouped surfaces SHALL use settings semantic seams or equivalent settings/platform seams
- **AND** drag/drop behavior, toolbar preference mutations, reset/clear behavior, custom button dialog, icon catalog behavior, desktop preference notification, existing `ValueKey`s, and labels SHALL be preserved
- **AND** the change SHALL NOT modify `MemoToolbarPreferences`, compose toolbar runtime behavior, desktop quick-input channel semantics, or custom icon catalog data

#### Scenario: Drift guardrail reflects completed shortcuts and toolbar migration

- **WHEN** this batch is implemented
- **THEN** `shortcuts_settings_screen.dart`, `shortcut_editor_screen.dart`, and `memo_toolbar_settings_screen.dart` SHALL be removed from `legacyAllowlist`
- **AND** those files SHALL be added to `migratedFiles`
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`
- **AND** `desktop_shortcuts_overview_screen.dart` and `desktop_settings_window_app.dart` SHALL remain deferred unless a separate OpenSpec change approves their migration
