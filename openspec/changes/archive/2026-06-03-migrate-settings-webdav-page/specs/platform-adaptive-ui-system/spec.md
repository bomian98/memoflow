## ADDED Requirements

### Requirement: WebDAV settings pages SHALL use semantic settings UI seams

WebDAV settings surfaces in `webdav_sync_screen.dart` SHALL render page chrome, grouped rows, toggles, navigation entries, input rows, action buttons, status/progress rows, warning/copy rows, and log entries through `SettingsPage`, `SettingsSection`, semantic settings rows/actions, or equivalent settings/platform seams instead of direct palette/local card/button/toggle implementations.

#### Scenario: WebDAV root page is migrated

- **WHEN** `WebDavSyncScreen` renders enable sync, connection entry, backup strategy entry, Vault security status entry, logs entry, backup/restore actions, progress state, or sync error copy
- **THEN** it SHALL use settings semantic page/section/row/action seams
- **AND** it SHALL preserve enable/disable writes, navigation targets, manual sync, backup now, restore backup, progress pause/resume, sync error presentation, and existing provider/service call paths

#### Scenario: WebDAV connection page is migrated

- **WHEN** `_WebDavConnectionScreen` renders server URL, username, password, auth mode, ignore TLS, root path, warning copy, or connection test action
- **THEN** it SHALL use settings semantic page/section/input/toggle/value/action seams
- **AND** it SHALL preserve controller binding, draft settings construction, validation hints, connection test behavior, toast/snackbar feedback, auth mode picker, TLS toggle, and root path normalization

#### Scenario: WebDAV backup settings page is migrated

- **WHEN** `_WebDavBackupSettingsScreen` renders backup content, config scope, backup mode, backup password/Vault entry, schedule, retention, unavailable hints, backup error copy, or exit guard
- **THEN** it SHALL use settings semantic page/section/row/action seams
- **AND** it SHALL preserve backup config/content writes, full config encryption guard, encryption mode picker, password setup flow, schedule picker, retention writes, backup password missing exit guard, and backup error presentation

#### Scenario: WebDAV logs page is migrated

- **WHEN** `WebDavLogsScreen` renders loading, empty state, log entries, refresh action, or log detail dialog
- **THEN** it SHALL avoid direct palette/local card styling and use settings/theme/platform seams
- **AND** it SHALL preserve log store reads, refresh behavior, entry ordering, and detail dialog content

#### Scenario: Drift guardrail reflects completed WebDAV migration

- **WHEN** this batch is implemented
- **THEN** `webdav_sync_screen.dart` SHALL be removed from `legacyAllowlist`
- **AND** it SHALL be added to `migratedFiles`
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`
