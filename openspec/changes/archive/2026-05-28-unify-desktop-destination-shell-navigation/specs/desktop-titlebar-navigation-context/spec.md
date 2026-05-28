## MODIFIED Requirements

### Requirement: Titlebar navigation context policy SHALL be centralized and verifiable
The system SHALL centralize desktop title visibility, leading action visibility, top-level dismissal visibility, navigation mode selection, and desktop window chrome placement decisions in a shell, platform adapter, or equivalent desktop UI seam rather than distributing platform-specific title rules across feature pages.

#### Scenario: Feature page provides semantic title
- **WHEN** a feature page provides a title, leading action, trailing action, command bar, or body content to a desktop shell
- **THEN** the feature page SHALL NOT need to know whether macOS expanded-sidebar mode will render or omit that title

#### Scenario: Top-level destination does not own platform titlebar branching
- **WHEN** a feature page represents a top-level drawer destination on desktop
- **THEN** it SHALL NOT decide Windows versus macOS titlebar, toolbar, or shell tree selection locally
- **AND** it SHALL route those decisions through the desktop shell or equivalent platform adapter seam

#### Scenario: Dismissal controls are semantic rather than title content
- **WHEN** a top-level destination has a valid back, close, done, or dismissal affordance
- **THEN** the feature page SHALL express that affordance as semantic shell intent
- **AND** it SHALL NOT hide the affordance inside a title widget that the shell treats as page title content

#### Scenario: Shell policy is tested
- **WHEN** titlebar visibility policy, navigation mode selection, macOS window chrome handling, or unified desktop destination shell behavior changes
- **THEN** focused tests, layout tests, smoke checklist entries, or architecture guardrails SHALL verify expanded-sidebar suppression, secondary-route native close dispatch, at least one title-visible fallback mode, and migrated top-level pages avoiding page-local shell splits
