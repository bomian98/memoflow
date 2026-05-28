## MODIFIED Requirements

### Requirement: Platform adaptive UI system SHALL centralize platform presentation strategy
The system SHALL provide a platform adaptive UI strategy that maps shared feature intent to platform-appropriate presentation without duplicating business state, full feature page trees, or migrated top-level desktop shell branches.

#### Scenario: Feature page uses adaptive presentation
- **WHEN** a migrated feature page needs scaffold, navigation, primary action, command bar, list section, dialog, picker, sheet, popover, master-detail, or form control behavior
- **THEN** the page SHALL use `platform/` adapters, desktop shell host boundaries, adaptive UI components, or feature-owned composition seams instead of scattering direct platform branches through the page

#### Scenario: Desktop destination page uses shell seam
- **WHEN** a migrated top-level desktop drawer destination needs sidebar, rail, overlay navigation, titlebar, command bar, actions, secondary pane, modal surface, or window chrome integration
- **THEN** the page SHALL use a unified desktop destination shell seam instead of locally branching between Windows `DesktopShellHost` and macOS `Scaffold` / `AppBar`

#### Scenario: Platform-specific page trees are not copied
- **WHEN** the app adapts UI for iPhone, iPadOS, macOS, Windows, Linux, Android, or web
- **THEN** the system MUST NOT create complete duplicate `features_ios/`, `features_ipad/`, `features_macos/`, `features_windows/`, or equivalent parallel feature trees

#### Scenario: Business state remains shared
- **WHEN** a platform-specific UI renders existing features
- **THEN** it SHALL reuse existing providers, repositories, models, destination registries, and feature-owned business state unless a separate OpenSpec change explicitly approves a new owner

### Requirement: Platform shell strategies SHALL remain composable and platform-specific
The system SHALL preserve independent shell strategies for mobile, tablet, macOS, Windows, and Linux while sharing feature intent and navigation state through centralized shell or adaptive seams.

#### Scenario: Desktop shell host is used
- **WHEN** a migrated desktop feature needs sidebar, rail, toolbar, command bar, preview pane, modal surface, or window chrome integration
- **THEN** it SHALL compose through `DesktopShellHost` or an equivalent desktop shell boundary rather than importing a specific Windows or macOS shell implementation directly

#### Scenario: Top-level desktop destination remains platform-specific below the seam
- **WHEN** a top-level desktop destination is rendered through the unified shell seam
- **THEN** Windows SHALL remain free to render Windows-appropriate command bar and window controls
- **AND** macOS SHALL remain free to render macOS-appropriate toolbar, traffic-light safe area, and expanded-sidebar title suppression

#### Scenario: Apple platforms differ by form factor
- **WHEN** UI is adapted for Apple platforms
- **THEN** iPhone, iPadOS, and macOS SHALL be allowed to use different shell and interaction models while sharing Apple-appropriate visual semantics and existing business state

#### Scenario: Windows desktop remains distinct
- **WHEN** UI is adapted for Windows desktop
- **THEN** the system SHALL preserve Windows-appropriate command bar, sidebar/rail, preview pane, window controls, context menu, and keyboard interaction patterns instead of forcing macOS or mobile behavior
