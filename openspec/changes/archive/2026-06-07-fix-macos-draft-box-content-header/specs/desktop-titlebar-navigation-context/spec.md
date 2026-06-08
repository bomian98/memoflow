## ADDED Requirements

### Requirement: Desktop destination chrome SHALL separate window chrome from page navigation
Desktop destination shells SHALL treat titlebar / command bar leading as window chrome and shell operation space, not page navigation space. Page-level dismissal controls, menu controls, and page titles SHALL render in a safe content region when the page design requires them beside the current content. macOS native traffic lights are one platform-specific reserved area under this desktop rule; Windows command bar leading follows the same page-chrome ownership rule even though it is Flutter-rendered.

#### Scenario: Page title belongs to content header
- **WHEN** a desktop destination needs to show a page-level title for the current content pane
- **THEN** that title SHALL be available in the content pane header or another chrome-safe content region
- **AND** it SHALL NOT be rendered in the desktop titlebar / command bar leading area

#### Scenario: Page leading control remains visible
- **WHEN** a desktop destination has a valid page-level leading control such as Back, menu, close-current-task, or return-to-primary-destination
- **THEN** the control SHALL remain visible and interactive in the content pane header or an equivalent chrome-safe page region
- **AND** it SHALL NOT be hidden solely to avoid desktop shell chrome overlap

#### Scenario: Titlebar trailing keeps lightweight operations
- **WHEN** a desktop destination exposes lightweight operations such as search or page actions through titlebar / command bar trailing
- **THEN** those operations MAY remain in titlebar trailing if they are laid out outside native window controls
- **AND** they SHALL NOT force page-level Back/title content into titlebar / command bar leading

#### Scenario: Draft Box desktop navigation reuses Home titlebar context
- **WHEN** Draft Box is opened from Home navigation on desktop
- **THEN** it SHALL reuse the existing Home desktop titlebar / command bar context
- **AND** Draft Box content SHALL render in the Home primary content area
- **AND** Draft Box SHALL NOT create a separate destination titlebar context for that navigation entry
