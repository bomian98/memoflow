## ADDED Requirements

### Requirement: Export memos page SHALL use semantic settings UI seams

`ExportMemosScreen` SHALL render page chrome, export option rows, include archived toggle, export format row, export action, last export path display, and explanatory note through `SettingsPage`, `SettingsSection`, settings row/action components, `settingsPageTokens`, theme colors, or equivalent settings/platform seams instead of local scaffold/card/button/switch implementations.

#### Scenario: Export memos settings page is migrated

- **WHEN** `ExportMemosScreen` renders title, date range row, include archived toggle, export format row, export action, last export path, copy path action, or explanatory note
- **THEN** page chrome and grouped settings surfaces SHALL use settings semantic seams
- **AND** `_export`, date range picker behavior, include archived state, haptics, toast/snackbar/dialog behavior, clipboard copy path behavior, zip/markdown/sidecar/attachment export behavior, existing labels, and route entry behavior SHALL be preserved
- **AND** the change SHALL NOT edit API files, request/response models, route adapters, version compatibility logic, export data format, database queries, attachment fetching, SAF/path provider behavior, WebDAV behavior, local network migration behavior, private hooks, commercial logic, AI settings, desktop routing/window, shortcut editor, memo toolbar, or migration flows

#### Scenario: Import/export shared UI wrappers are removed or migrated

- **WHEN** `ExportMemosScreen` no longer uses `ImportExportCardGroup`, `ImportExportSelectRow`, or `ImportExportToggleRow`
- **THEN** `import_export_shared_widgets.dart` SHALL either be deleted after repository-wide reference verification
- **OR** it SHALL be migrated to settings/platform seams and tracked by the drift guardrail
- **AND** no unused legacy direct `MemoFlowPalette` or bare `Switch` wrapper SHALL remain in the settings UI legacy allowlist

#### Scenario: Drift guardrail reflects completed export memos migration

- **WHEN** this batch is implemented
- **THEN** `export_memos_screen.dart` SHALL be removed from `legacyAllowlist`
- **AND** `export_memos_screen.dart` SHALL be added to `migratedFiles`
- **AND** `import_export_shared_widgets.dart` SHALL be removed from `legacyAllowlist` if deleted, or added to `migratedFiles` if retained
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`
