## ADDED Requirements

### Requirement: Settings follow-up migration SHALL unify high-perception settings surfaces
The platform adaptive UI system SHALL continue settings UI migration by moving the settings home surface and direct Components detail surfaces onto the settings semantic UI seam.

#### Scenario: Settings home is migrated
- **WHEN** `SettingsScreen` renders profile entry, shortcut entries, grouped settings entries, extension entries, version footer, page background, desktop width, or navigation rows
- **THEN** it SHALL use `SettingsPage`, `SettingsSection`, settings semantic entry widgets, `PlatformPage`, or an approved settings/home composition seam
- **AND** it SHALL NOT reintroduce independent page-local card, row, shadow, radius, palette, or app bar visual systems for reusable settings navigation UI

#### Scenario: Component detail pages are migrated
- **WHEN** `ImageBedSettingsScreen` or `ImageCompressionSettingsScreen` renders page chrome, settings sections, toggles, selectable rows, text input rows, numeric stepper rows, warning/info rows, or actions
- **THEN** those controls SHALL be expressed through settings semantic components or narrow settings-owned form seams
- **AND** platform-specific row density, grouped-list behavior, desktop width, switches, and action geometry SHALL be delegated to settings/platform seams

#### Scenario: Page roles remain distinct
- **WHEN** a migrated settings page is a settings home, feature management list, or feature detail configuration page
- **THEN** it SHALL keep its page role distinct while sharing settings semantic UI seams
- **AND** detail configuration pages SHALL NOT be forced into `SettingsFeatureModule` unless they are actually managing a list of feature modules

### Requirement: Settings follow-up migration SHALL preserve behavior and ownership
The settings UI follow-up migration SHALL change presentation ownership without changing setting semantics, provider ownership, persistence behavior, API behavior, or public/private boundaries.

#### Scenario: Settings home behavior is preserved
- **WHEN** `SettingsScreen` is migrated
- **THEN** existing navigation entries, desktop settings platform gate, private extension bundle entries, donation entry, drawer/close behavior, embedded presentation behavior, and version footer SHALL remain functional
- **AND** the page SHALL NOT add capability, subscription, entitlement, paywall, StoreKit, product ID, receipt, private overlay, or `AccessDecision.source` business branching

#### Scenario: Image bed behavior is preserved
- **WHEN** `ImageBedSettingsScreen` is migrated
- **THEN** existing image bed enabled state, provider selection, base URL normalization, credential inputs, retry settings, and save/update callbacks SHALL continue to use the existing `imageBedSettingsProvider` owner
- **AND** reusable visual behavior SHALL move to settings UI seams rather than into state, application, core, or data layers

#### Scenario: Image compression behavior is preserved
- **WHEN** `ImageCompressionSettingsScreen` is migrated
- **THEN** existing compression mode, output format, lossless, metadata, resize, quality, size-limit, skip, warning, and numeric adjustment behavior SHALL continue to use the existing `imageCompressionSettingsProvider` owner
- **AND** reusable visual behavior SHALL move to settings UI seams rather than into state, application, core, or data layers

### Requirement: Settings follow-up migration SHALL shrink legacy drift guardrails
The settings UI follow-up migration SHALL tighten automated drift protection for every settings file migrated in this batch.

#### Scenario: Migrated files leave the legacy allowlist
- **WHEN** `SettingsScreen`, `ImageBedSettingsScreen`, or `ImageCompressionSettingsScreen` has been migrated to settings semantic UI seams
- **THEN** `settings_ui_drift_guardrail_test.dart` SHALL remove that file from the legacy allowlist and include it in migrated coverage
- **AND** architecture verification SHALL fail if the migrated file reintroduces direct reusable `Scaffold`, bare `Switch` or `Switch.adaptive`, page-local `styleFrom`, private `_ToggleCard`, or direct `MemoFlowPalette` visual decisions beyond an explicit narrow exception

#### Scenario: Remaining settings pages are not silently claimed as migrated
- **WHEN** this batch completes
- **THEN** remaining legacy settings pages such as `WebDavSyncScreen`, `AiSettingsScreen`, `PasswordLockScreen`, and other allowlisted pages MAY remain in the legacy allowlist
- **AND** their remaining status SHALL be documented by tasks, guardrail comments, or follow-up OpenSpec planning rather than being treated as complete
