## ADDED Requirements

### Requirement: Desktop task window roots SHALL consume shared chrome safe area

Desktop task window roots SHALL use a shared desktop window chrome safe-area rule before rendering top-level title, navigation, toolbar, status, or top-leading content near platform-owned window controls.

#### Scenario: macOS task window root renders a title
- **WHEN** a desktop task window root is rendered on macOS with native traffic lights visible
- **THEN** the root title, leading navigation affordance if present, toolbar, status text, and first top-leading interactive controls SHALL be laid out outside the native traffic-light reserved area
- **AND** the implementation SHALL use the shared desktop chrome safe-area seam or an equivalent shell-level wrapper
- **AND** the implementation SHALL NOT rely on feature-page-local magic padding to avoid the traffic lights.

#### Scenario: Share task window root uses native close semantics
- **WHEN** the share task window root consumes desktop chrome safe-area spacing
- **THEN** the spacing SHALL only reserve layout space for native platform controls
- **AND** it SHALL NOT introduce an App-owned generic close button
- **AND** it SHALL NOT introduce an App-owned generic cancel button
- **AND** native close SHALL remain the cancellation mechanism for the current share task.

#### Scenario: Non-macOS task window root is rendered
- **WHEN** a desktop task window root is rendered on Windows or Linux
- **THEN** it SHALL use the shared desktop chrome safe-area policy for that platform if native or custom caption controls can overlap Flutter content
- **AND** it SHALL NOT apply macOS traffic-light leading inset unless the platform chrome mode explicitly requires equivalent leading reserved space.

### Requirement: Feature roots SHALL delegate window-control avoidance to desktop shell seams

Feature roots participating in a desktop shell or desktop task window SHALL express semantic title, navigation, task-root state, actions, and body content while delegating platform window-control geometry to a shared desktop chrome seam.

#### Scenario: Feature page provides top-level chrome content
- **WHEN** a feature page or task root provides a title, Back affordance, command bar, status block, or top-leading action
- **THEN** it SHALL pass that content through an approved desktop chrome shell, frame, adapter, or policy when the content can appear near native window controls
- **AND** it SHALL NOT encode macOS traffic-light coordinates, Windows caption-control widths, or Linux window-control assumptions in feature-specific layout code.

#### Scenario: Existing settings window remains stable
- **WHEN** this change standardizes desktop task window chrome safe-area participation
- **THEN** it SHALL NOT redesign settings page/window behavior solely for this rule
- **AND** future settings-window chrome changes SHALL continue to reuse the shared desktop chrome safe-area seam or explicitly document why the native frame makes the seam unnecessary.

### Requirement: Desktop chrome safe-area participation SHALL be guarded

The system SHALL include focused verification or guardrails that make desktop task window chrome safe-area participation discoverable and prevent regressions toward page-local titlebar padding.

#### Scenario: Task window chrome path is changed
- **WHEN** a desktop task window root, shell, or chrome wrapper is added or changed
- **THEN** focused widget tests, layout tests, smoke checklist entries, or architecture guardrails SHALL verify that macOS top-leading content remains outside the native traffic-light reserved area
- **AND** at least one non-macOS behavior SHALL be verified or explicitly documented as unchanged.

#### Scenario: Shared chrome seam is changed
- **WHEN** the shared desktop chrome safe-area helper, shell, adapter, or policy is changed
- **THEN** tests or guardrails SHALL verify that the seam remains lower-layer safe
- **AND** the seam SHALL NOT import `features/*`, `application/*`, `state/*`, or `data/*`.
