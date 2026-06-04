## ADDED Requirements

### Requirement: Local mode setup page SHALL use semantic settings UI seams

`LocalModeSetupScreen` SHALL render page chrome, bounded task content, subtitle text, storage info, repository name input, validation messaging, confirm action, and cancel action through `SettingsPage`, `SettingsSection`, settings row/action components, `settingsPageTokens`, theme colors, or equivalent settings/platform seams instead of local scaffold/card implementations.

#### Scenario: Local mode setup page is migrated

- **WHEN** `LocalModeSetupScreen` renders title, subtitle, storage info, repository name field, confirm action, cancel action, or validation message
- **THEN** page chrome and grouped settings surfaces SHALL use settings semantic seams
- **AND** `LocalModeSetupScreen.show`, `LocalModeSetupResult`, title/confirm/cancel/subtitle parameters, storage info visibility, trimmed-name submit behavior, empty-name snackbar, cancel pop behavior, and debug logging SHALL be preserved
- **AND** the change SHALL NOT edit API files, request/response models, route adapters, version compatibility logic, local library persistence, database, file paths, sync, WebDAV behavior, local network migration behavior, private hooks, commercial logic, AI settings, desktop routing/window, shortcut editor, memo toolbar, quick QR, donation dialog, or import/export flows

#### Scenario: Drift guardrail reflects completed local mode setup migration

- **WHEN** this batch is implemented
- **THEN** `local_mode_setup_screen.dart` SHALL be removed from `legacyAllowlist`
- **AND** `local_mode_setup_screen.dart` SHALL be added to `migratedFiles`
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`
