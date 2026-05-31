## MODIFIED Requirements

### Requirement: macOS settings menu commands SHALL open or fallback to a visible settings surface
The macOS application menu Settings command, Window menu Open Settings Window command, and settings-like MemoFlow menu commands SHALL route through the application-owned command seam and SHALL result in a visible settings surface.

#### Scenario: Application Settings command succeeds
- **WHEN** the user selects Settings from the macOS application menu or presses `Cmd+,`
- **THEN** the command seam SHALL request the macOS settings window
- **AND** the system SHALL open or focus the settings window when the window request succeeds

#### Scenario: Application Settings command falls back
- **WHEN** the user selects Settings from the macOS application menu or presses `Cmd+,`
- **AND** the macOS settings window request is unsupported or fails
- **THEN** the command seam SHALL open a visible fallback settings page in the main window

#### Scenario: Window menu command falls back
- **WHEN** the user selects Open Settings Window from the macOS Window menu
- **AND** the macOS settings window request is unsupported or fails
- **THEN** the command seam SHALL open a visible fallback settings page in the main window

#### Scenario: AI Settings command opens the settings window AI pane
- **WHEN** the user selects `AI Settings` from the macOS `AI` menu
- **THEN** the command seam SHALL request the desktop settings window with the AI settings target
- **AND** when the request succeeds, the settings window SHALL show the AI settings pane
- **AND** the command SHALL NOT open `AiSettingsScreen` as a standalone main-window route as its primary path

#### Scenario: AI Settings command falls back visibly
- **WHEN** the user selects `AI Settings` from the macOS `AI` menu
- **AND** the target settings window request is unsupported or fails
- **THEN** the command seam SHALL open a visible AI settings fallback page in the main window
