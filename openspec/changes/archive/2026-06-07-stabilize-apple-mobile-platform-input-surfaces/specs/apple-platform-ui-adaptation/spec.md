## ADDED Requirements

### Requirement: Apple mobile text input SHALL be Apple-safe inside Cupertino page content

Apple mobile UI adaptation SHALL render text input controls inside iPhone and iPadOS platform pages without depending on accidental Material ancestors from feature pages.

#### Scenario: iPhone local library name input renders

- **WHEN** the user selects local mode during first-run onboarding on iPhone and the local library name screen opens
- **THEN** the repository-name input SHALL render without `No Material widget found` or equivalent Flutter framework errors
- **AND** the input behavior SHALL be provided through `PlatformTextField`, `SettingsInputRow`, or an equivalent approved platform/settings seam

#### Scenario: iPadOS local library name input renders

- **WHEN** the same local library name screen opens on iPadOS
- **THEN** it SHALL use the same shared Apple mobile input behavior
- **AND** implementation MUST NOT create an iPad-only setup page tree

#### Scenario: Apple mobile input accepts editing

- **WHEN** the local library name input is rendered on iPhone or iPadOS
- **THEN** the user SHALL be able to edit the initial name and submit the trimmed value
- **AND** existing local library creation semantics SHALL remain unchanged

### Requirement: Apple mobile local setup feedback SHALL avoid Scaffold-only SnackBar dependency

Apple mobile local setup SHALL present lightweight validation feedback without requiring `ScaffoldMessenger` or `SnackBar` availability inside the current page body.

#### Scenario: Empty local library name is submitted on iPhone

- **WHEN** the user clears the local library name and confirms on iPhone
- **THEN** the screen SHALL show a validation message through a platform-safe feedback surface
- **AND** the route SHALL remain open without Flutter framework errors

#### Scenario: Empty local library name is submitted on iPadOS

- **WHEN** the user clears the local library name and confirms on iPadOS
- **THEN** the same shared validation behavior SHALL be used
- **AND** implementation MUST NOT introduce a separate iPad-only validation path

### Requirement: Apple mobile local setup SHALL use platform route presentation

Apple mobile local setup SHALL be opened through a platform route abstraction so route transition and back behavior match Apple mobile presentation semantics.

#### Scenario: Onboarding opens local setup on iPhone

- **WHEN** onboarding opens `LocalModeSetupScreen` on iPhone
- **THEN** the screen SHALL be pushed through `buildPlatformPageRoute` or an equivalent platform route seam
- **AND** onboarding MUST NOT directly choose a Material-only route for this setup subflow

#### Scenario: Account settings opens local setup on Apple mobile

- **WHEN** account/security settings open add-local-library or rename-local-library setup on iPhone or iPadOS
- **THEN** the same platform route seam SHALL be used
- **AND** add, rename, cancel, and submit results SHALL remain shared with non-Apple platforms

### Requirement: Apple mobile input surface adaptation SHALL remain public-shell safe

Apple mobile input, validation feedback, settings row, and route adaptation SHALL remain limited to public presentation behavior and SHALL preserve modularity boundaries.

#### Scenario: Apple input adapter code is added or changed

- **WHEN** code for `PlatformTextField`, `SettingsInputRow`, local setup feedback, local setup route presentation, or related Apple mobile input tests is added or changed
- **THEN** it MUST NOT include subscription, billing, entitlement, receipt, paywall, StoreKit, product ID, price, private overlay, or `AccessDecision.source` business branching logic

#### Scenario: Platform adapter remains layer-safe

- **WHEN** files under `memos_flutter_app/lib/platform` are added or changed for Apple mobile input adaptation
- **THEN** they MUST NOT import `features/*`, `state/*`, `application/*`, or `data/*`
- **AND** any required exception MUST be explicitly documented in OpenSpec and guarded by tests before implementation
