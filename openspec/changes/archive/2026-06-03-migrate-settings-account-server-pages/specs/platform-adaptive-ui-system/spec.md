## ADDED Requirements

### Requirement: Settings account/server pages SHALL use semantic settings UI seams

Account/server settings pages in this batch SHALL render page chrome, grouped rows, selectable account/local-library rows, server setting form sections, loading states, retry actions, and footer text through `SettingsPage`, `SettingsSection`, semantic settings rows/actions, or equivalent settings/platform seams instead of page-local scaffold/card/palette implementations.

#### Scenario: Account security page is migrated

- **WHEN** `AccountSecurityScreen` renders account summary, account actions, remote accounts, local libraries, or removal warning text
- **THEN** it SHALL use settings semantic page/section/row seams
- **AND** it SHALL preserve add account, add local library, user general settings navigation, server settings navigation, sign out/remove account, local library switch, local library scan, local library rename, local library remove, dialog, haptics, and snackbar behavior
- **AND** it SHALL NOT edit API files, private hooks, WebDAV sync behavior, AI settings, desktop routing, security pages, or commercial logic

#### Scenario: Server settings page is migrated

- **WHEN** `ServerSettingsScreen` renders memo content limit or attachment upload limit controls
- **THEN** it SHALL use settings semantic page/form/action seams
- **AND** it SHALL preserve refresh, loading, unavailable/read-only, empty-field hint, focus blur restore, local positive integer validation, save status message, and retry behavior
- **AND** it SHALL keep provider/API ownership in `serverSettingsProvider` and existing data layers without editing API contract files

#### Scenario: Drift guardrail reflects completed account/server migration

- **WHEN** this batch is implemented
- **THEN** `account_security_screen.dart` and `server_settings_screen.dart` SHALL be removed from `legacyAllowlist`
- **AND** those files SHALL be added to `migratedFiles`
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`
