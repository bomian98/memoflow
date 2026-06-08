## ADDED Requirements

### Requirement: Adaptive form controls SHALL render safely inside platform page chrome

The platform adaptive UI system SHALL provide form-control seams that can render text input and related form controls inside platform page chrome without requiring feature pages to add local Material or Cupertino workarounds.

#### Scenario: Text input renders inside Apple mobile PlatformPage

- **WHEN** a migrated flow renders a text input through `PlatformTextField` inside an iPhone or iPadOS `PlatformPage`
- **THEN** the input SHALL render without requiring an implicit `Material` ancestor from the feature page
- **AND** the Apple mobile behavior SHALL be provided by `platform/` or an approved settings/platform seam

#### Scenario: Text input preserves non-Apple behavior

- **WHEN** the same `PlatformTextField` is rendered on Android, Windows, macOS, Linux, or web
- **THEN** the existing Material-compatible `TextField` behavior SHALL remain available
- **AND** the change MUST NOT force Apple mobile control geometry onto non-Apple targets

#### Scenario: Material-only fallback stays inside platform seam

- **WHEN** a compatibility fallback is needed for a Material-only form control during migration
- **THEN** that fallback MUST be implemented inside `platform/` or an approved adaptive seam
- **AND** feature pages MUST NOT wrap individual controls in page-local `Material` solely to satisfy Apple mobile rendering

### Requirement: Settings input rows SHALL express input intent through semantic seams

Settings pages SHALL render text input rows through settings-owned semantic components and shared platform form-control seams rather than directly branching between Material and Cupertino widgets in each screen.

#### Scenario: Grouped settings input renders on iPhone

- **WHEN** a settings or onboarding setup page renders `SettingsInputRow` inside an Apple mobile grouped list
- **THEN** the row SHALL delegate platform-specific text input behavior to `PlatformTextField` or an equivalent shared seam
- **AND** the row MUST render without Flutter framework errors caused by missing Material ancestors

#### Scenario: Settings input remains shared across feature screens

- **WHEN** settings pages such as local library setup, server settings, location settings, shortcut editor, or profile settings need editable text
- **THEN** they SHALL use `SettingsInputRow`, `PlatformTextField`, or an approved settings/platform seam
- **AND** they MUST NOT create separate iOS-only page trees for the same settings behavior

### Requirement: Validation feedback SHALL avoid page-local Material-only dependencies

Adaptive flows that can run inside Apple mobile `PlatformPage` content SHALL present lightweight validation feedback through platform-safe feedback surfaces instead of relying on page-local `ScaffoldMessenger` availability.

#### Scenario: Validation feedback runs without Scaffold

- **WHEN** an Apple mobile setup or settings flow validates user input inside a `CupertinoPageScaffold`
- **THEN** validation feedback SHALL be shown through `showTopToast`, a platform feedback seam, a platform dialog, or an equivalent overlay-safe surface
- **AND** the flow MUST NOT require the current page body to be wrapped in a `Scaffold`

#### Scenario: Lightweight validation stays lightweight

- **WHEN** the validation issue is a simple missing or invalid text value
- **THEN** the feedback SHOULD use a lightweight toast or equivalent non-blocking surface where project conventions allow
- **AND** it MUST NOT introduce new business state or persistence behavior

### Requirement: Setup subflows SHALL use platform route seams

Reusable setup subflows that render through `PlatformPage` SHALL use a platform route abstraction when pushed from migrated mobile, desktop, or Apple flows.

#### Scenario: Local setup route runs on Apple mobile

- **WHEN** a migrated flow opens local library setup on iPhone or iPadOS
- **THEN** it SHALL push the setup screen through `buildPlatformPageRoute` or an equivalent platform route seam
- **AND** the implementation MUST NOT require the caller to choose `CupertinoPageRoute` directly

#### Scenario: Existing route behavior remains available elsewhere

- **WHEN** the same setup subflow runs on Android, Windows, macOS, Linux, or web
- **THEN** the platform route seam SHALL preserve existing route behavior appropriate to that target
- **AND** the setup result and validation behavior SHALL remain shared

### Requirement: Adaptive input surface changes SHALL include focused guardrails

Changes to platform input controls, settings input rows, Apple mobile validation feedback, or setup route presentation SHALL include focused automated verification and boundary checks.

#### Scenario: Apple mobile input path is verified

- **WHEN** focused widget tests run for Apple mobile setup or settings input
- **THEN** they SHALL verify render without Flutter framework exceptions
- **AND** they SHALL verify editing, validation feedback, and successful submission where the flow supports those behaviors

#### Scenario: Platform adapter dependency direction is verified

- **WHEN** platform input or feedback adapters are added or changed
- **THEN** architecture tests or repo scans SHALL prevent new `platform -> features`, `platform -> state`, `platform -> application`, and `platform -> data` dependencies unless an explicit OpenSpec-approved exception exists

#### Scenario: Public shell boundary is verified

- **WHEN** platform/settings/onboarding input surface code is added or changed in the public repository
- **THEN** verification or review SHALL confirm it does not add subscription, billing, entitlement, receipt, paywall, StoreKit, product ID, price, private overlay, or `AccessDecision.source` business branching logic
