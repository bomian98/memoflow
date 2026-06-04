## ADDED Requirements

### Requirement: Simple utility settings surfaces SHALL use semantic settings UI seams

`TemplateSettingsScreen` and `WidgetsScreen` SHALL render page chrome, grouped controls, template rows, widget preview actions, helper notes, and settings navigation affordances through `SettingsPage`, `SettingsSection`, settings row/action components, `settingsPageTokens`, theme colors, or equivalent settings/platform seams instead of local scaffold/card/palette implementations.

#### Scenario: Template settings page is migrated

- **WHEN** `TemplateSettingsScreen` renders template enablement, template list rows, empty template state, variable settings entry, variable docs entry, edit/delete actions, or helper text
- **THEN** page chrome and grouped settings surfaces SHALL use settings semantic seams
- **AND** template add/edit/delete behavior, delete confirmation, variable settings dialog, variable docs dialog, provider calls, sync requests triggered by the provider, UID handling, and localized text SHALL be preserved
- **AND** the change SHALL NOT edit API files, request/response models, route adapters, version compatibility logic, template repository/model/provider behavior, WebDAV sync behavior, home widget service behavior, private hooks, commercial logic, AI settings, desktop routing/window, import/export, migration, shortcut editor, memo toolbar, quick QR, or donation dialog

#### Scenario: Widgets settings page is migrated

- **WHEN** `WidgetsScreen` renders home widget preview groups, add actions, unsupported-target toast behavior, supported Android pin request behavior, or version footer
- **THEN** page chrome, grouped surfaces, action controls, and footer styling SHALL use settings semantic seams, theme colors, or platform components
- **AND** preview contents, `HomeWidgetService.requestPinWidget` invocation, Android support gate, toast messages, package version lookup, and `showBackButton` behavior SHALL be preserved
- **AND** the change SHALL NOT edit API files, request/response models, route adapters, version compatibility logic, `HomeWidgetService`, platform channel implementation, package info plugin seam, private hooks, commercial logic, AI settings, desktop routing/window, import/export, migration, shortcut editor, memo toolbar, quick QR, or donation dialog

#### Scenario: Drift guardrail reflects completed simple utility migration

- **WHEN** this batch is implemented
- **THEN** `template_settings_screen.dart` and `widgets_screen.dart` SHALL be removed from `legacyAllowlist`
- **AND** both files SHALL be added to `migratedFiles`
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`
