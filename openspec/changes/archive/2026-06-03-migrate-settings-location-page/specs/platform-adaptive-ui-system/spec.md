## ADDED Requirements

### Requirement: Location settings page SHALL use semantic settings UI seams

`LocationSettingsScreen` SHALL render page chrome, grouped controls, location enabled toggle, provider selection, API key inputs, helper text, and precision controls through `SettingsPage`, `SettingsSection`, `SettingsToggleRow`, `SettingsMenuRow`, `SettingsInputRow`, `settingsPageTokens`, or equivalent settings/platform seams instead of local scaffold/card/palette implementations.

#### Scenario: Location page is migrated

- **WHEN** `LocationSettingsScreen` renders the location enabled control, provider picker, provider-specific API key fields, or precision selector
- **THEN** page chrome and grouped controls SHALL use settings semantic seams
- **AND** enabled toggle, provider selection, API key writes, precision writes, controller lifecycle, provider subscription, and `_dirty` behavior SHALL be preserved
- **AND** the change SHALL NOT edit API files, location data models, repositories, adapters, provider behavior, permission logic, geocoder behavior, private hooks, commercial logic, AI settings, desktop routing, import/export, or WebDAV config transfer

#### Scenario: Drift guardrail reflects completed location migration

- **WHEN** this batch is implemented
- **THEN** `location_settings_screen.dart` SHALL be removed from `legacyAllowlist`
- **AND** it SHALL be added to `migratedFiles`
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`
