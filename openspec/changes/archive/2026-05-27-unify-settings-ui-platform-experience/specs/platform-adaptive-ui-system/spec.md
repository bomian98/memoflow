## ADDED Requirements

### Requirement: Settings UI SHALL use semantic settings components
The platform adaptive UI system SHALL provide a settings-owned semantic UI seam so settings screens express settings intent instead of directly owning colors, button styles, platform controls, and repeated card geometry.

#### Scenario: Settings page chrome is rendered
- **WHEN** a migrated settings page renders a title, leading action, body, background, safe area, or desktop width constraint
- **THEN** it SHALL use `SettingsPage`, `PlatformPage`, or an approved settings page seam
- **AND** page-local `Scaffold` and app bar construction SHALL NOT be introduced unless the page is explicitly allowlisted during migration

#### Scenario: Settings rows are rendered
- **WHEN** a migrated settings page renders a navigation row, value row, selectable row, toggle row, or destructive row
- **THEN** it SHALL use a settings semantic row such as `SettingsNavigationRow`, `SettingsValueRow`, `SettingsToggleRow`, or an equivalent seam
- **AND** platform-specific row, grouped-list, and switch behavior SHALL be delegated to shared settings/platform components

#### Scenario: Settings actions are rendered
- **WHEN** a migrated settings page renders save, confirm, continue, cancel, reset, destructive, or secondary actions
- **THEN** it SHALL express the semantic action variant instead of hardcoding button foreground/background colors in the screen

#### Scenario: Settings visual tokens are resolved
- **WHEN** a migrated settings screen needs background, section, card, row, divider, text, icon, active, disabled, primary, secondary, or danger styling
- **THEN** those values SHALL be resolved through the settings UI seam, `ThemeData`, `ColorScheme`, platform widgets, or approved design tokens
- **AND** the feature screen SHOULD NOT directly select raw palette colors except for genuinely page-specific preview/editing UI such as a color picker.

### Requirement: Settings pilot SHALL unify Preferences and Components
The first settings UI unification batch SHALL use `PreferencesSettingsScreen` and `ComponentsSettingsScreen` as sibling pilot pages for the settings UI seam.

#### Scenario: Preferences is migrated
- **WHEN** `PreferencesSettingsScreen` is migrated in this batch
- **THEN** it SHALL keep existing preference behavior while moving generic group, row, toggle, page background, and action presentation to the shared settings seam where applicable

#### Scenario: Components is migrated
- **WHEN** `ComponentsSettingsScreen` is migrated in this batch
- **THEN** it SHALL keep existing component toggle behavior while replacing page-local card/toggle styling with the shared settings seam

#### Scenario: Pilot pages are compared
- **WHEN** a user opens Settings -> Preferences and Settings -> Components on phone, tablet, macOS desktop, or Windows/Linux desktop contexts
- **THEN** both pages SHALL feel like siblings in the same settings system
- **AND** platform-appropriate differences SHALL come from the settings/platform seams rather than page-local style forks

### Requirement: Platform experience classification SHALL separate platform axes
The platform adaptive UI system SHALL define or expose a normalized platform experience classification that separates runtime platform from form factor, input model, window model, visual family, and navigation model.

#### Scenario: Apple platforms are classified
- **WHEN** the app runs on iPhone, iPad-width iOS, or macOS
- **THEN** the classification SHALL distinguish those experiences rather than treating all Apple platforms as one interaction model

#### Scenario: Desktop platforms are classified
- **WHEN** the app runs on macOS, Windows, or Linux
- **THEN** the classification SHALL allow shared desktop behavior while preserving platform-specific visual family and window chrome semantics

#### Scenario: Migrated UI asks semantic platform questions
- **WHEN** migrated settings or platform UI code chooses layout, row density, navigation model, or transient surface behavior
- **THEN** it SHOULD ask semantic experience questions such as form factor, input model, window model, or visual family instead of scattering direct `TargetPlatform` checks

#### Scenario: Platform classification remains layer-safe
- **WHEN** platform experience classification code is added or changed
- **THEN** it MUST remain in an approved platform/core seam and MUST NOT import `features/*`, `state/*`, `application/*`, or `data/*`

### Requirement: Settings UI migration SHALL be guardrailed
The settings UI unification SHALL include automated guardrails or reviewable allowlists so future settings changes do not reintroduce divergent local styling.

#### Scenario: Legacy settings files remain
- **WHEN** not all settings pages have been migrated
- **THEN** the guardrail MAY use an explicit allowlist for existing legacy files
- **AND** each future migration SHOULD remove migrated files from that allowlist

#### Scenario: New settings style drift is introduced
- **WHEN** a non-allowlisted migrated settings file introduces direct `MemoFlowPalette` styling, page-local `styleFrom`, bare `Switch`/`Switch.adaptive`, private `_ToggleCard`, or direct `Scaffold` where `SettingsPage` is expected
- **THEN** architecture verification SHALL fail or require an explicit documented exception
