## ADDED Requirements

### Requirement: Desktop settings window SHALL support targeted pane routing
桌面设置窗口 SHALL support opening or focusing a specific settings destination through a stable target seam, without requiring menu handlers to construct feature pages directly.

#### Scenario: AI settings target is requested
- **WHEN** the app requests the desktop settings window with the AI settings target
- **THEN** the settings window SHALL open or focus
- **AND** the AI settings pane SHALL be selected
- **AND** the content SHALL render the same AI settings composition used by the desktop settings window pane list

#### Scenario: Existing settings window receives a target request
- **GIVEN** the desktop settings window is already open
- **WHEN** the app requests the AI settings target
- **THEN** the existing settings window SHALL be focused
- **AND** it SHALL switch to the AI settings pane without creating a duplicate settings window

#### Scenario: Target request fails
- **WHEN** the app requests a target settings window destination
- **AND** the settings window cannot be shown, focused, routed, or confirmed responsive
- **THEN** the open operation SHALL report a non-opened result
- **AND** the caller SHALL be able to show a visible fallback page

### Requirement: Settings window target seam SHALL remain layer-safe
Settings window target routing SHALL be expressed through stable target values or method payloads and SHALL NOT move feature widget construction into lower layers.

#### Scenario: Target seam is changed
- **WHEN** desktop settings window target routing is added or changed
- **THEN** `application` and `core` layers SHALL NOT import `features/settings` UI files for target resolution
- **AND** target-to-widget mapping SHALL remain owned by the settings window UI composition
- **AND** the seam MUST NOT include commercial, subscription, entitlement, StoreKit, private overlay, or paid-feature branching logic
