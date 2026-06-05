## ADDED Requirements

### Requirement: Inline compose resize SHALL account for dynamic compose chrome
桌面首页 resizable inline compose 面板 SHALL 将 pending attachment preview、linked memo chips、location 状态、toolbar 和其他 editor 外内容计入 panel chrome height。`homeInlineComposePanelLayout.editorHeight` MUST continue to represent only the editor viewport height, and dynamic chrome changes MUST NOT corrupt the persisted editor height.

#### Scenario: Adding an attachment grows the panel without overflow
- **GIVEN** the app is running on a supported desktop platform
- **AND** the home inline compose panel is using a persisted or restored `editorHeight`
- **WHEN** the user adds one or more pending attachments
- **THEN** the panel SHALL allocate enough height for the attachment preview and existing toolbar chrome
- **AND** the editor viewport SHALL keep the restored `editorHeight` within configured bounds
- **AND** the UI SHALL NOT render a Flutter bottom overflow

#### Scenario: Removing attachments updates chrome without changing saved editor height
- **GIVEN** the home inline compose panel contains pending attachments
- **AND** the user has a persisted `homeInlineComposePanelLayout.editorHeight`
- **WHEN** the pending attachments are removed
- **THEN** the panel chrome height SHALL update to the current compose content
- **AND** the persisted editor height SHALL remain the user's editor viewport height
- **AND** toolbar and send controls SHALL remain visible and hit-testable

#### Scenario: Dynamic chrome remains within viewport bounds
- **GIVEN** the home inline compose panel is near the bottom of the available desktop viewport
- **WHEN** attachment preview, linked memo chips, or location state adds editor-external chrome
- **THEN** the panel SHALL clamp or reposition within the available viewport bounds
- **AND** the compose draft text and pending attachments SHALL remain available
- **AND** the resize handles SHALL remain usable when supported

### Requirement: Inline compose resize layout metrics SHALL be guarded against tight-parent measurement drift
The implementation SHALL provide focused automated verification for the resizable inline compose metrics path so dynamic editor-external chrome cannot be hidden by tight parent constraints.

#### Scenario: Controlled editor height reports attachment chrome
- **WHEN** a widget test renders `MemosListInlineComposeCard` with `desktopEditorViewportHeight`
- **AND** the composer contains at least one pending attachment
- **THEN** the reported layout metrics SHALL include the attachment preview in chrome or desired total height
- **AND** the measured editor viewport height SHALL still match the requested desktop editor viewport height

#### Scenario: Desktop route test fails on overflow regression
- **WHEN** a focused desktop `MemosListScreen` test renders the supported resizable home inline compose panel with pending attachments
- **THEN** the test SHALL assert that no Flutter overflow exception is produced
- **AND** the panel height SHALL be at least the editor viewport height plus current compose chrome height
