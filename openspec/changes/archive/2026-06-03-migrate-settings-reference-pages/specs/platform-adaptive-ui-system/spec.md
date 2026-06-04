## ADDED Requirements

### Requirement: Reference settings pages SHALL use semantic settings UI seams

Reference and entry settings pages in this batch SHALL render page chrome, grouped rows, helper text, and placeholder messaging through `SettingsPage`, `SettingsSection`, `SettingsNavigationRow`, `SettingsInfoRow`, `settingsPageTokens`, or equivalent settings/platform seams instead of local scaffold/card/palette implementations.

#### Scenario: Laboratory page is migrated

- **WHEN** `LaboratoryScreen` renders experimental settings entry rows
- **THEN** it SHALL use settings semantic page and row seams
- **AND** it SHALL preserve existing route targets, `showBackButton` behavior, package version display, and app identity display
- **AND** it SHALL NOT introduce API file edits, commercial branching, WebDAV, AI, desktop routing, import/export, or shortcut editor scope

#### Scenario: User guide page is migrated

- **WHEN** `UserGuideScreen` renders guide rows, external docs entry, helper footer text, or info surfaces
- **THEN** page chrome and guide rows SHALL use settings semantic seams
- **AND** existing haptics, external URL launch, snackbar fallback, Windows adaptive surface, and bottom sheet behavior SHALL be preserved

#### Scenario: Placeholder page is migrated

- **WHEN** `SettingsPlaceholderScreen` renders a title and message from legacy string keys
- **THEN** it SHALL use settings semantic page/section seams
- **AND** dynamic i18n key lookup and route dismissal behavior SHALL be preserved

#### Scenario: Drift guardrail reflects completed reference migration

- **WHEN** this batch is implemented
- **THEN** `laboratory_screen.dart`, `user_guide_screen.dart`, and `placeholder_settings_screen.dart` SHALL be removed from `legacyAllowlist`
- **AND** those files SHALL be added to `migratedFiles`
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`
