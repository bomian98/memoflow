## ADDED Requirements

### Requirement: Settings security pages SHALL use semantic settings UI seams

Security settings pages in this batch SHALL render page chrome, grouped rows, toggle rows, value/navigation rows, status rows, action controls, loading states, and explanatory copy through `SettingsPage`, `SettingsSection`, semantic settings rows/actions, or equivalent settings/platform seams instead of page-local scaffold/card/palette/switch implementations.

#### Scenario: Password lock page is migrated

- **WHEN** `PasswordLockScreen` renders app lock enablement, change password entry, auto-lock time entry, or explanatory copy
- **THEN** it SHALL use settings semantic page/section/row seams
- **AND** it SHALL preserve enable app lock, disable app lock, set password dialog, change password dialog, auto-lock picker, provider writes, and toast behavior
- **AND** it SHALL NOT edit WebDAV sync behavior, API files, private hooks, account/server pages, AI settings, desktop routing, or commercial logic

#### Scenario: Vault security status page is migrated

- **WHEN** `VaultSecurityStatusScreen` renders Vault enabled status, recovery code status, remote/local/export plaintext status, local plaintext cache toggle, cleanup actions, recovery code action, backup test action, or loading state
- **THEN** it SHALL use settings semantic page/section/row/action seams
- **AND** it SHALL preserve status loading, cleanup reminders, recovery code password verification, backup restore test mode selection, local plain cache toggle, clear plaintext actions, snackbars, toasts, dialogs, and existing provider/service call paths
- **AND** it SHALL NOT change WebDAV sync/backup/import/export behavior or provider ownership

#### Scenario: Drift guardrail reflects completed security migration

- **WHEN** this batch is implemented
- **THEN** `password_lock_screen.dart` and `vault_security_status_screen.dart` SHALL be removed from `legacyAllowlist`
- **AND** those files SHALL be added to `migratedFiles`
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`
