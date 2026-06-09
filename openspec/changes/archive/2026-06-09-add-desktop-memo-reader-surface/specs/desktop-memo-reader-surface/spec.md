## ADDED Requirements

### Requirement: Desktop wide memo reading SHALL use a reader surface

桌面宽布局中，完整 memo 查看 SHALL resolve through a desktop memo reader intent and SHALL render a unified desktop reader surface rather than directly pushing the legacy full-page detail route.

#### Scenario: Memo card double tap opens reader surface

- **GIVEN** app 运行在支持 desktop preview pane 的宽布局
- **AND** 用户在 memo list 中看到一条 memo
- **WHEN** 用户 double clicks the memo card
- **THEN** the app SHALL open the memo through the desktop memo reader intent
- **AND** the memo SHALL appear in the unified desktop reader surface
- **AND** the app SHALL NOT push a standalone `MemoDetailScreen` route as the desktop wide default.

#### Scenario: Selected memo open shortcut opens reader surface

- **GIVEN** app 运行在 desktop wide memo list
- **AND** a memo is selected or visible in the preview pane
- **WHEN** 用户触发 Enter 或 equivalent open-detail shortcut
- **THEN** the app SHALL open the selected memo through the desktop memo reader intent
- **AND** the reader SHALL use the same desktop reader surface model as memo card double tap.

#### Scenario: Preview pane open action delegates to reader intent

- **GIVEN** app 运行在 desktop wide layout
- **AND** preview pane 正在显示一条 ready memo
- **WHEN** 用户触发 preview pane 的 open/fullscreen/read action
- **THEN** the preview pane SHALL delegate to the desktop memo reader intent
- **AND** it SHALL NOT own a separate fullscreen route policy.

### Requirement: Preview pane SHALL remain quick read while reader surface owns full read

Desktop preview pane SHALL remain a quick read and selection companion, while the full desktop reader surface SHALL own immersive reading.

#### Scenario: Single click keeps preview workflow

- **GIVEN** app 运行在 desktop wide layout
- **WHEN** 用户 single clicks a memo card
- **THEN** the app SHALL select the memo and show or update the preview pane according to desktop preview policy
- **AND** it SHALL NOT open the full reader surface solely from the single click.

#### Scenario: Preview pane renders read-only content

- **GIVEN** preview pane is visible
- **WHEN** a memo is selected
- **THEN** the preview pane SHALL render read-only memo content
- **AND** edit controls in the preview pane SHALL delegate to the desktop memo editor intent
- **AND** full read controls in the preview pane SHALL delegate to the desktop memo reader intent.

#### Scenario: Reader open preserves preview selection

- **GIVEN** a memo is selected in the desktop preview pane
- **WHEN** the user opens the full desktop reader surface
- **THEN** the app SHALL preserve the selected memo identity
- **AND** closing the reader SHOULD return the user to the same home workspace with the preview selection still coherent unless the memo was removed or filtered away.

### Requirement: Desktop reader surface SHALL support centered and fullscreen modes

Desktop memo reader surface SHALL support a centered modal mode and a fullscreen mode using the same reader target and state.

#### Scenario: Centered reader is default full read presentation

- **GIVEN** app 运行在 desktop wide layout
- **WHEN** 用户打开 full memo reader
- **THEN** the reader SHALL open as a home-contained centered modal by default
- **AND** background memo list, preview pane, or drawer content SHALL NOT be interactive while the modal is active
- **AND** the reader SHALL prioritize memo content with minimal reader chrome.

#### Scenario: Fullscreen reader keeps the same memo target

- **GIVEN** a desktop centered reader surface is open for a memo
- **WHEN** 用户 expands the reader to fullscreen
- **THEN** the reader SHALL keep the same memo target
- **AND** it SHALL NOT recreate the reader by pushing a separate route
- **AND** restoring from fullscreen SHALL return to the centered reader surface or close according to the chosen product rule without losing target identity.

#### Scenario: Reader surface reuses document rendering

- **WHEN** the desktop reader surface renders memo content
- **THEN** it SHALL reuse existing memo document rendering components or equivalent shared rendering seams
- **AND** it SHALL NOT duplicate independent markdown, attachment, relation, or engagement rendering logic solely for the new surface.

### Requirement: Reader and editor surfaces SHALL coordinate through explicit intents

Desktop reader surface SHALL coordinate with desktop editor surface through explicit reader/editor intents and SHALL avoid competing modal owners.

#### Scenario: Reader edit delegates to editor intent

- **GIVEN** a desktop reader surface is open for an editable memo
- **WHEN** 用户触发 edit action in the reader
- **THEN** the reader SHALL delegate to the desktop memo editor intent
- **AND** the app SHALL close or replace the reader according to the chosen rule before showing the editor
- **AND** it SHALL NOT push a separate `MemoEditorScreen` route.

#### Scenario: Editor has priority over reader when both are requested

- **GIVEN** a desktop editor surface is open
- **WHEN** a reader open request is triggered for any memo
- **THEN** the app SHALL apply an explicit conflict rule such as ignoring the reader request, asking the user to close editor, or keeping the editor as the active modal surface
- **AND** it SHALL NOT render reader and editor as two overlapping modal surfaces.

#### Scenario: Reader does not clear unrelated drafts

- **GIVEN** desktop inline compose or desktop editor draft state exists
- **WHEN** the desktop reader surface opens or closes
- **THEN** the app SHALL NOT silently clear unrelated inline compose or editor draft state.

### Requirement: macOS reader and fallback detail SHALL avoid native chrome overlap

macOS desktop reader surfaces and remaining fallback detail routes SHALL account for native titlebar and traffic-light areas.

#### Scenario: macOS centered reader avoids traffic lights

- **GIVEN** app 运行在 macOS desktop wide layout
- **WHEN** the centered desktop reader surface opens
- **THEN** reader controls and memo content SHALL NOT overlap macOS traffic lights or native titlebar hit area
- **AND** the reader SHALL respect the active desktop shell chrome/safe-area policy.

#### Scenario: macOS fullscreen reader avoids traffic lights

- **GIVEN** app 运行在 macOS
- **WHEN** the desktop reader enters fullscreen mode
- **THEN** fullscreen reader controls and content SHALL NOT be placed underneath the native titlebar or traffic lights
- **AND** any content extending into titlebar space SHALL use a shared desktop window chrome safe-area seam.

#### Scenario: Fallback detail route is chrome-safe

- **GIVEN** a remaining mobile, narrow, notification, relation, or fallback path opens `MemoDetailScreen` on macOS desktop
- **WHEN** the detail route is shown
- **THEN** its title, dismissal controls, action buttons, and primary content SHALL avoid native traffic lights and titlebar hit areas
- **AND** it SHALL use shared desktop chrome safe-area policy rather than page-local hardcoded traffic-light padding.

### Requirement: Platform fallback behavior SHALL remain scoped

Unified desktop memo reader surface SHALL NOT force non-desktop or narrow layouts to adopt desktop UI.

#### Scenario: Mobile detail behavior remains unchanged

- **GIVEN** app 运行在 phone layout
- **WHEN** 用户 opens a memo detail
- **THEN** the app SHALL keep the existing mobile detail presentation
- **AND** it SHALL NOT show the desktop centered reader modal.

#### Scenario: Desktop narrow may keep existing fallback

- **GIVEN** app 运行在 desktop platform with a narrow window
- **WHEN** 用户 opens a memo detail
- **THEN** the app MAY keep an existing page or fallback route
- **AND** the fallback SHALL avoid platform chrome overlap where applicable.

#### Scenario: API and commercial boundaries are preserved

- **WHEN** desktop reader surface rules are implemented
- **THEN** implementation SHALL NOT modify Memos server API request/response models, route adapters, or version compatibility logic
- **AND** it SHALL NOT add subscription, billing, entitlement, paywall, StoreKit, private overlay, paid-feature branching, or other commercial logic to public runtime files.

### Requirement: Reader opening policy SHALL preserve architecture boundaries

Desktop memo reader opening policy SHALL be owned by feature-local navigation/presenter seams and SHALL NOT introduce new lower-layer dependencies on UI features.

#### Scenario: Opening logic is centralized

- **WHEN** desktop memo reader opening paths are changed
- **THEN** open/read route decisions SHALL be centralized in a focused intent, route delegate, presenter, or equivalent seam
- **AND** individual entry widgets SHALL delegate reader opening instead of each pushing their own `MemoDetailScreen` route.

#### Scenario: Lower layers do not depend on features

- **WHEN** reader opening policy is implemented
- **THEN** `state`, `application`, and `core` SHALL NOT add new imports from `features/*`
- **AND** shared reader opening rules SHALL NOT be hidden inside a low-level model or persistence service.

#### Scenario: Touched coupled areas improve or preserve modularity

- **WHEN** implementation touches home/memos/navigation coupling hotspots
- **THEN** it SHALL leave the touched area equal or better structured than before
- **AND** it SHALL add or tighten focused tests or guardrails that prevent reader entry points from diverging again.
