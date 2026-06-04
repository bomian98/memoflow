## ADDED Requirements

### Requirement: Integrations settings pages SHALL use semantic settings UI seams

`ApiPluginsScreen` and `WebhooksSettingsScreen` SHALL render page chrome, grouped controls, integration rows, token/webhook state surfaces, and helper text through `SettingsPage`, `SettingsSection`, settings row components, `settingsPageTokens`, theme colors, or equivalent settings/platform seams instead of local scaffold/card/palette implementations.

#### Scenario: API plugins page is migrated

- **WHEN** `ApiPluginsScreen` renders token creation controls, expiration selection, loading state, error state, empty state, existing token rows, copy action, or helper text
- **THEN** page chrome and grouped surfaces SHALL use settings semantic seams
- **AND** token creation, one-time token display, clipboard copy, repository save/read, refresh behavior, form validation, current-account guard, toast/snackbar behavior, and token masking SHALL be preserved
- **AND** the change SHALL NOT edit API files, request/response models, route adapters, version compatibility logic, token data models, repositories, provider behavior, private hooks, commercial logic, AI settings, desktop routing/window, import/export, migration, shortcut editor, or memo toolbar

#### Scenario: Webhooks page is migrated

- **WHEN** `WebhooksSettingsScreen` renders webhook rows, empty state, loading state, error state, add action, edit action, delete action, or retry action
- **THEN** page chrome and grouped surfaces SHALL use settings semantic seams
- **AND** webhook add/edit/delete API calls, `userWebhooksProvider` invalidation, dialog behavior, haptic behavior, toast/snackbar behavior, and unsupported-server load error messaging SHALL be preserved
- **AND** the change SHALL NOT edit API files, request/response models, route adapters, version compatibility logic, webhook data models, repositories, provider behavior, private hooks, commercial logic, AI settings, desktop routing/window, import/export, migration, shortcut editor, or memo toolbar

#### Scenario: Drift guardrail reflects completed integrations migration

- **WHEN** this batch is implemented
- **THEN** `api_plugins_screen.dart` and `webhooks_settings_screen.dart` SHALL be removed from `legacyAllowlist`
- **AND** both files SHALL be added to `migratedFiles`
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`
