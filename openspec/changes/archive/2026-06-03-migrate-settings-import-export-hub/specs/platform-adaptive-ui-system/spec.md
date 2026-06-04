## ADDED Requirements

### Requirement: Import/export settings hub SHALL use semantic settings UI seams

`ImportExportScreen` SHALL render page chrome, grouped hub categories, route rows, labels, values, and navigation affordances through `SettingsPage`, `SettingsSection`, settings row components, `settingsPageTokens`, theme colors, or equivalent settings/platform seams instead of local scaffold/card/palette implementations.

#### Scenario: Import/export hub is migrated

- **WHEN** `ImportExportScreen` renders Export, Import file, or Local Network Migration entries
- **THEN** page chrome and grouped settings surfaces SHALL use settings semantic seams
- **AND** haptic behavior, `showBackButton`, `buildPlatformPageRoute` navigation, target screens, labels, and route values SHALL be preserved
- **AND** the change SHALL NOT edit API files, request/response models, route adapters, version compatibility logic, `ExportMemosScreen`, `ImportSourceScreen`, `LocalNetworkMigrationScreen`, shared import/export widgets, import/export file logic, local migration behavior, WebDAV behavior, private hooks, commercial logic, AI settings, desktop routing/window, shortcut editor, memo toolbar, quick QR, or donation dialog

#### Scenario: Drift guardrail reflects completed import/export hub migration

- **WHEN** this batch is implemented
- **THEN** `import_export_screen.dart` SHALL be removed from `legacyAllowlist`
- **AND** `import_export_screen.dart` SHALL be added to `migratedFiles`
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`
