## MODIFIED Requirements

### Requirement: Desktop memo list layout SHALL not hide shared desktop behavior behind Windows-only gates

Desktop memo list card-width and preview-pane behavior SHALL be expressed as desktop layout behavior unless a platform-specific exception is explicitly documented. Preview-pane support and default memo-click preview behavior SHALL use shared desktop memo-list layout tiers rather than a Windows-only tier or a macOS-only legacy preview breakpoint.

#### Scenario: Shared desktop card width
- **WHEN** a memo card is rendered in a desktop target memo list
- **THEN** it MUST use the shared desktop memo card maximum width rather than a Windows-only width constraint

#### Scenario: Shared desktop media tile proportions
- **WHEN** a memo media grid is rendered in a desktop target memo surface and its configured max height is smaller than its unconstrained square grid height
- **THEN** the grid MUST preserve square tile proportions by shrinking tile width and height together
- **AND** this behavior MUST NOT be limited to Windows-only platform checks

#### Scenario: Expanded desktop memo list supports right-side preview pane
- **GIVEN** the app is running in the desktop home memo list on Windows or macOS
- **AND** the window width is at least the shared expanded desktop threshold of `1200`
- **WHEN** the memo list builds its desktop layout state
- **THEN** the memo list SHALL consider the right-side desktop preview pane supported for that platform
- **AND** this support MUST NOT depend on the legacy `1440` desktop preview breakpoint for macOS home memo list behavior

#### Scenario: Wide desktop memo click opens preview by default
- **GIVEN** the app is running in the desktop home memo list on Windows or macOS
- **AND** the window width is at least the shared wide desktop threshold of `1360`
- **WHEN** the user clicks a memo card
- **THEN** the memo list SHALL select that memo and open or update the right-side desktop preview pane
- **AND** it SHALL NOT navigate directly to `MemoDetailScreen` for the ordinary single-click action

#### Scenario: Expanded non-wide desktop width can support preview without default click-to-preview
- **GIVEN** the app is running in the desktop home memo list on Windows or macOS
- **AND** the window width is at least `1200` and less than `1360`
- **WHEN** the memo list builds its desktop layout state
- **THEN** the right-side preview pane SHALL be available as a supported secondary pane
- **AND** ordinary memo single-click behavior MAY remain non-preview until the preview pane is already active or explicitly opened

#### Scenario: Platform shell chrome remains platform-specific
- **WHEN** shared desktop preview layout tiers are applied to macOS
- **THEN** macOS titlebar, native traffic-light safe area, native close/minimize/zoom semantics, and hybrid titlebar behavior SHALL remain governed by macOS shell policy
- **AND** the implementation MUST NOT introduce Windows-style Flutter-drawn window controls into the default macOS home shell
