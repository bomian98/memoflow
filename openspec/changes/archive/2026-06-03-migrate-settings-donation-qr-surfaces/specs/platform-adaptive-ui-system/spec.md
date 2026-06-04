## ADDED Requirements

### Requirement: Donation and quick QR settings surfaces SHALL not remain legacy UI drift entries

`DonationDialog` SHALL render its public donation request/success UI using settings or platform UI seams for color tokens and primary actions instead of direct palette reads or page-local button styling. `quick_qr_action.dart` SHALL not remain in the settings UI drift legacy allowlist when it does not render a settings page or local visual surface, and SHALL be tracked by the migrated scan so future drift is blocked.

#### Scenario: Donation dialog is migrated to settings seams

- **WHEN** `DonationDialog` renders its request card, QR image area, confirm action, cancel action, success card, close action, snackbar, top toast, or animation state
- **THEN** color and primary action decisions SHALL use `settingsPageTokens`, `SettingsAction`, `Theme.of(context).colorScheme`, or equivalent settings/platform seams
- **AND** donation QR asset, long-press save QR, gallery permission handling, snackbar/top toast behavior, success step, confetti, close/cancel behavior, existing labels, and public donation entry SHALL be preserved
- **AND** the change SHALL NOT introduce subscription, billing, entitlement, receipt, paywall, StoreKit, product ID, private overlay, or `AccessDecision.source` business branching

#### Scenario: Drift guardrail reflects donation and quick QR cleanup

- **WHEN** this batch is implemented
- **THEN** `donation_dialog.dart` SHALL be removed from `legacyAllowlist`
- **AND** `donation_dialog.dart` SHALL be added to `migratedFiles`
- **AND** `quick_qr_action.dart` SHALL be removed from `legacyAllowlist`
- **AND** `quick_qr_action.dart` SHALL be added to `migratedFiles`
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`

#### Scenario: Quick QR behavior is preserved

- **WHEN** `classifyQuickQrPayload` receives a MemoFlow migration QR payload, a bridge pairing QR payload, an empty payload, or unsupported QR data
- **THEN** it SHALL preserve the existing target classification and rejection behavior
- **AND** the batch SHALL NOT modify bridge pairing, migration sender routing, QR scanner support detection, local network migration behavior, API files, request/response models, route adapters, or version compatibility logic
