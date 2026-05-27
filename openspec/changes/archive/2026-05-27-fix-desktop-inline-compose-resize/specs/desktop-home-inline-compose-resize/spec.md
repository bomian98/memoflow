## ADDED Requirements

### Requirement: Desktop home inline compose SHALL expose resize on supported desktop platforms
Supported desktop home memo list surfaces SHALL render a resizable inline compose panel whenever the home inline compose layout is active and the current platform is explicitly supported for this capability.

Linux desktop is not adapted in this batch and MUST remain disabled or fallback unless a later change explicitly enables and verifies it.

#### Scenario: Windows home inline compose can be resized
- **GIVEN** the app is running on Windows desktop
- **AND** the user is viewing the home `MemosListScreen` with inline compose active
- **WHEN** the page renders the inline compose panel
- **THEN** the panel SHALL expose active resize handles
- **AND** dragging a resize handle SHALL change the panel dimensions within configured min/max bounds

#### Scenario: Unsupported Linux desktop does not silently enable resize
- **GIVEN** the app is running on Linux desktop
- **WHEN** the home inline compose panel is rendered
- **THEN** resize handles SHALL NOT be enabled unless Linux support is explicitly added by a later change
- **AND** the inline compose panel SHALL remain usable through the non-resizable fallback layout

### Requirement: Desktop home memo entry paths SHALL share resize capability decisions
All desktop entry paths that build the primary home memo list SHALL use the same resize capability decision instead of relying on scattered route-specific flags.

#### Scenario: Initial home route and drawer memos route match
- **GIVEN** the app is running on Windows desktop
- **WHEN** the user reaches all memos from the initial home route
- **AND** the user reaches all memos through a drawer or replacement destination route
- **THEN** both routes SHALL render the same inline compose resize capability state
- **AND** neither route SHALL accidentally disable resize by omitting an entry-specific flag

#### Scenario: Desktop utility return route preserves resize
- **GIVEN** the app is running on Windows desktop
- **AND** a desktop utility view such as notifications or sync queue is opened from home
- **WHEN** the user returns to the memo list primary content
- **THEN** the home inline compose resize capability SHALL remain available if it was available on the original memo list route

### Requirement: Inline compose resize SHALL preserve compose and desktop pane behavior
Resizing the desktop home inline compose panel SHALL change only the panel layout geometry and SHALL preserve compose state, desktop preview state, and keyboard ownership semantics.

#### Scenario: Resize preserves compose draft state
- **GIVEN** the desktop home inline compose editor contains draft text or pending attachments
- **WHEN** the user drags a resize handle
- **THEN** the draft text and pending attachments SHALL remain available
- **AND** the resize action SHALL NOT submit, clear, or close the inline compose editor

#### Scenario: Resize preserves desktop preview pane state
- **GIVEN** the desktop home right-side preview pane is visible
- **AND** the inline compose panel is visible
- **WHEN** the user resizes the inline compose panel
- **THEN** the preview pane SHALL remain governed by the existing desktop preview state
- **AND** the resize action SHALL NOT open, close, or replace the preview pane by itself

#### Scenario: Resize preserves keyboard ownership
- **GIVEN** the desktop home inline compose editor is focused
- **WHEN** the user resizes the inline compose panel
- **THEN** existing inline compose keyboard ownership and publish shortcut behavior SHALL remain unchanged
- **AND** the resize action SHALL NOT introduce selected-memo Enter navigation while the editor owns keyboard input

### Requirement: Inline compose resize layout SHALL persist safely
When a supported desktop user resizes the home inline compose panel, the app SHALL persist the layout through the existing device preference owner and restore it within current viewport bounds.

#### Scenario: Resized layout is persisted
- **GIVEN** the app is running on a supported desktop platform
- **WHEN** the user completes a resize interaction on the home inline compose panel
- **THEN** the app SHALL persist the resulting width, editor height, and normalized position using the existing `homeInlineComposePanelLayout` preference

#### Scenario: Saved layout is clamped on smaller viewport
- **GIVEN** a saved home inline compose panel layout exists
- **AND** the desktop viewport becomes smaller than the viewport where the layout was saved
- **WHEN** the home memo list renders
- **THEN** the restored panel SHALL be clamped within current viewport bounds
- **AND** it SHALL remain at least the configured minimum usable size

### Requirement: Inline compose resize SHALL be guarded against route drift
The implementation SHALL include focused automated verification that protects both resize hit testing and entry-path capability consistency.

#### Scenario: Real drag changes panel geometry
- **WHEN** focused widget tests render the supported desktop home inline compose panel
- **AND** the test drags a visible resize handle
- **THEN** the observed panel geometry or persisted layout SHALL change
- **AND** the test SHALL fail if the handle is present but not hit-testable in the real route tree

#### Scenario: New desktop memos entry does not bypass capability seam
- **WHEN** a new desktop memos entry path is added or an existing entry path is changed
- **THEN** tests or guardrails SHALL verify that the entry uses the shared resize capability decision
- **AND** the entry SHALL NOT hardcode a conflicting resize flag without an explicit documented exception

### Requirement: Inline compose resize SHALL preserve architecture boundaries
The desktop home inline compose resize fix SHALL preserve existing dependency directions and MUST NOT introduce new lower-layer imports from feature UI.

#### Scenario: No lower-layer reverse dependency is introduced
- **WHEN** the resize fix is implemented
- **THEN** `state`, `application`, and `core` layers MUST NOT add new imports from `features/memos`
- **AND** resize capability decisions SHALL be owned by an existing route composition seam, a same-layer feature helper, or a feature-agnostic platform/layout seam
