## ADDED Requirements

### Requirement: Navigation customization settings pages SHALL use semantic settings UI seams

Navigation and home customization settings pages in this batch SHALL render page chrome, grouped rows, toggle rows, selectable rows, helper text, and preview surfaces through `SettingsPage`, `SettingsSection`, `SettingsToggleRow`, `SettingsNavigationRow`, `SettingsSelectableItemRow`, `settingsPageTokens`, or equivalent settings/platform seams instead of local scaffold/card/palette implementations.

#### Scenario: Navigation mode page is migrated

- **WHEN** `NavigationModeScreen` renders classic and bottom bar navigation mode choices
- **THEN** it SHALL use settings semantic page and row seams
- **AND** classic/bottom selection behavior, `bottomSelectKey`, `bottomSettingsKey`, and bottom settings detail navigation SHALL be preserved
- **AND** bottom settings SHALL remain unavailable until bottom bar mode is selected

#### Scenario: Bottom navigation detail page is migrated

- **WHEN** `BottomNavigationModeSettingsScreen` renders preview, slot rows, fixed center action, or destination picker dialog
- **THEN** page chrome and slot grouping SHALL use settings semantic seams
- **AND** preview MAY remain a page-local presentation helper if it uses settings/theme tokens
- **AND** destination availability filtering, duplicate destination disabling, center fixed action behavior, and provider writes SHALL be preserved

#### Scenario: Drawer customization page is migrated

- **WHEN** `CustomizeDrawerScreen` renders drawer visibility toggles
- **THEN** it SHALL use `SettingsToggleRow` or equivalent settings toggle seam
- **AND** each toggle SHALL preserve its existing `currentWorkspacePreferencesProvider` setter

#### Scenario: Home shortcuts customization page is migrated

- **WHEN** `CustomizeHomeShortcutsScreen` renders quick entry slots or picker dialog
- **THEN** page chrome and slot rows SHALL use settings semantic seams
- **AND** local-only / signed-in candidate filtering, used action disabled state, dialog selection, and provider writes SHALL be preserved

#### Scenario: Drift guardrail reflects completed navigation migration

- **WHEN** this batch is implemented
- **THEN** `navigation_mode_screen.dart`, `bottom_navigation_mode_settings_screen.dart`, `customize_drawer_screen.dart`, and `customize_home_shortcuts_screen.dart` SHALL be removed from `legacyAllowlist`
- **AND** those files SHALL be added to `migratedFiles`
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`
