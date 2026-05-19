# apple-platform-ui-adaptation Specification

## Purpose
TBD - created by archiving change adapt-apple-platform-ui. Update Purpose after archive.
## Requirements
### Requirement: Apple platform UI adapter

The system SHALL provide a public platform UI adapter layer for Apple platform presentation differences without duplicating feature page trees or embedding commercial logic.

#### Scenario: Platform UI seam is used
- **WHEN** Apple-specific page chrome, route, dialog, picker, action sheet, grouped list, icon, or adaptive control behavior is implemented
- **THEN** the behavior MUST be exposed through `platform/` UI adapter APIs or an equivalent centralized seam instead of scattered `Platform.isIOS` / `TargetPlatform.macOS` branches inside feature pages

#### Scenario: Feature page trees are not copied
- **WHEN** iOS, iPadOS, or macOS UI is adapted
- **THEN** the system MUST NOT create full duplicate `features_ios/`, `features_ipad/`, or `features_macos/` page trees

#### Scenario: Platform seam dependency direction
- **WHEN** files under the platform UI adapter are added or changed
- **THEN** they MUST NOT import `features/*`, `state/*`, `application/*`, or `data/*`

#### Scenario: Commercial logic is excluded
- **WHEN** Apple platform UI shell or adapter code is added to the public repository
- **THEN** it MUST NOT include StoreKit, subscription, buyout, entitlement, receipt, product ID, price, paywall, App Store Connect, signing secret, notarization, TestFlight, or private release automation logic

### Requirement: Apple shell differentiation

The system SHALL provide differentiated Apple shell strategies for iOS, iPadOS, and macOS while reusing existing business state and destination models.

#### Scenario: iPhone shell
- **WHEN** the app runs on iPhone-sized iOS devices
- **THEN** the primary shell MUST present Apple-native mobile navigation behavior, including Apple-style tab or primary navigation chrome, iOS route transition expectations, safe-area handling, and natural back navigation

#### Scenario: iPadOS shell
- **WHEN** the app runs on iPadOS or tablet-sized Apple layouts
- **THEN** the primary shell MUST prefer sidebar or split-view navigation over Android-style drawer presentation, with a responsive fallback for narrow layouts

#### Scenario: macOS shell
- **WHEN** the app runs on macOS
- **THEN** the primary shell MUST use an independent macOS desktop presentation with sidebar, toolbar, menu / shortcut / window semantics, and MUST NOT rely on Windows window controls as the final macOS UI

#### Scenario: Destination reuse
- **WHEN** Apple shells navigate among home, settings, memos, collections, review, resources, stats, and other existing app destinations
- **THEN** they MUST reuse existing destination models or boundary registries where practical instead of duplicating business routing state

### Requirement: Platform page and route behavior

The system SHALL route page-level chrome and transitions through platform-aware abstractions.

#### Scenario: Platform page chrome
- **WHEN** a migrated page needs title, leading action, trailing actions, body, safe area, drawer, sidebar, bottom navigation, or toolbar behavior
- **THEN** it MUST use `PlatformPage` or an equivalent platform page abstraction rather than directly encoding Apple-specific page chrome in the feature page

#### Scenario: Platform routes
- **WHEN** a migrated flow pushes a new page on iOS, iPadOS, macOS, Android, Windows, Linux, or web
- **THEN** it MUST use a platform route abstraction that preserves existing Material / Windows behavior while using Apple-appropriate transitions and back gesture behavior on Apple platforms

#### Scenario: Existing fallback
- **WHEN** a platform page or route adapter cannot provide a specialized Apple implementation yet
- **THEN** it MUST fall back to the existing Material behavior without changing business state or data flow

### Requirement: Platform dialogs, action sheets, menus, and pickers

The system SHALL provide semantic wrappers for high-perception transient UI on Apple platforms.

#### Scenario: Confirm and destructive dialog
- **WHEN** a migrated flow asks users to confirm, discard, delete, exit, overwrite, restore, or perform a destructive action
- **THEN** it MUST use a platform dialog abstraction that maps to Apple-appropriate alert or sheet behavior on Apple platforms

#### Scenario: Action menu
- **WHEN** a migrated flow presents contextual actions such as memo more menu, share, edit, delete, attach, visibility, template, or tag actions
- **THEN** it MUST use a platform action sheet, menu, or popover abstraction appropriate to iPhone, iPadOS, macOS, and existing non-Apple platforms

#### Scenario: Enum and date-time selection
- **WHEN** a migrated flow asks the user to choose an enum value, single option, multi option, date, time, schedule, font, theme mode, or similar picker value
- **THEN** it MUST use a platform picker abstraction rather than hardcoding `AlertDialog`, `SimpleDialog`, `DropdownButton`, or `showModalBottomSheet` for all platforms

### Requirement: Platform grouped settings and form controls

The system SHALL provide Apple-appropriate grouped list and form controls for settings and configuration pages.

#### Scenario: Settings grouped list
- **WHEN** a migrated settings or configuration page displays groups of navigable rows, toggles, value rows, text input rows, or destructive rows
- **THEN** it MUST use `PlatformGroupedList`, `PlatformListTile`, or equivalent abstractions that can render Apple inset grouped lists on Apple platforms and preserve existing style elsewhere

#### Scenario: Adaptive form controls
- **WHEN** a migrated page displays switch, checkbox, radio, slider, progress, text field, search field, or segmented control behavior
- **THEN** it MUST use platform control wrappers or a documented platform adapter entry point rather than scattering direct `*.adaptive` or platform branches through the page

#### Scenario: Settings pilot
- **WHEN** the first Apple UI migration batch is implemented
- **THEN** `SettingsScreen` and `PreferencesSettingsScreen` MUST be treated as pilot pages for grouped list, picker, dialog, switch, route, and page chrome behavior

### Requirement: Apple UI migration coverage and progress tracking

The system SHALL track Apple UI migration coverage until all high-perception Apple UI areas are completed.

#### Scenario: Migration inventory
- **WHEN** implementation begins
- **THEN** the change MUST create or update a migration inventory covering scaffold / app bar / navigation, tab / sidebar / drawer, dialog / alert, bottom sheet / popup menu, picker, form controls, text input, grouped list / card, key icons, route transition / back gesture, scrolling, safe area, dark mode, dynamic type, accessibility, and macOS menu / window behavior

#### Scenario: Batch progress
- **WHEN** each migration batch is completed
- **THEN** `tasks.md` or an associated OpenSpec note MUST identify which Apple UI areas are complete, in progress, and still pending

#### Scenario: Completion standard
- **WHEN** the change is considered complete
- **THEN** high-perception Apple UI areas in home shell, settings, memo list, memo detail, memo editor, note input, collections, reminders, review, stats, and debug flows MUST either use the platform UI adapter or have a documented reason why existing behavior is acceptable on Apple platforms

### Requirement: App Store and modularity guardrails

The system SHALL preserve public/private boundaries and modularity constraints while adapting Apple UI.

#### Scenario: Public/private commercial boundary
- **WHEN** Apple UI code is added to public shell, settings, home, memo, platform, or shared UI files
- **THEN** it MUST NOT branch on subscription, paid feature, entitlement, receipt, product, price, Family Sharing, StoreKit, or `AccessDecision.source`

#### Scenario: Architecture guardrail
- **WHEN** platform UI adapter files are added or changed
- **THEN** architecture tests or repo scans MUST prevent new `platform -> features`, `platform -> state`, `platform -> application`, and `platform -> data` dependencies unless an explicit OpenSpec-approved adapter exception is documented

#### Scenario: Coupling hotspot touched
- **WHEN** a migration batch touches an existing coupled area such as `home`, `settings`, `memos`, `core`, or desktop shell code
- **THEN** the touched area MUST remain equal or better structured by extracting platform behavior into a seam, reducing platform-specific feature-page branching, or tightening a guardrail

