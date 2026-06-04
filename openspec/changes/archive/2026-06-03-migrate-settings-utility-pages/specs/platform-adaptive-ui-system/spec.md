## ADDED Requirements

### Requirement: Utility settings pages SHALL use semantic settings UI seams

`ExportLogsScreen` and `SelfRepairScreen` SHALL render page chrome, grouped controls, utility rows, toggles, action rows, notes, and state surfaces through `SettingsPage`, `SettingsSection`, settings row components, `settingsPageTokens`, theme colors, or equivalent settings/platform seams instead of local scaffold/card/palette implementations.

#### Scenario: Export logs page is migrated

- **WHEN** `ExportLogsScreen` renders include toggles, network logging toggle, note input, generate/clear actions, last exported path, copy path action, or helper notes
- **THEN** page chrome and grouped surfaces SHALL use settings semantic seams
- **AND** report generation, export path resolution, log bundle export, log clearing, device preference writes, haptic behavior, clipboard copy, toast/snackbar behavior, busy/clearing state, and local include/note state SHALL be preserved
- **AND** the change SHALL NOT edit API files, request/response models, route adapters, version compatibility logic, log providers/stores, database repair logic, WebDAV behavior, path provider behavior, private hooks, commercial logic, AI settings, desktop routing/window, import/export, migration, shortcut editor, memo toolbar, quick QR, or donation dialog

#### Scenario: Self repair page is migrated

- **WHEN** `SelfRepairScreen` renders repair actions, subtitles, running/disabled state, confirmation dialog trigger, success/error messaging, or local-only note
- **THEN** page chrome and grouped surfaces SHALL use settings semantic seams
- **AND** confirmation dialogs, `selfRepairMutationServiceProvider` calls, running state, haptic behavior, snackbar behavior, and repair success/error messages SHALL be preserved
- **AND** the change SHALL NOT edit API files, request/response models, route adapters, version compatibility logic, self repair mutation service, database repair logic, log providers/stores, WebDAV behavior, private hooks, commercial logic, AI settings, desktop routing/window, import/export, migration, shortcut editor, memo toolbar, quick QR, or donation dialog

#### Scenario: Drift guardrail reflects completed utility migration

- **WHEN** this batch is implemented
- **THEN** `export_logs_screen.dart` and `self_repair_screen.dart` SHALL be removed from `legacyAllowlist`
- **AND** both files SHALL be added to `migratedFiles`
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`
