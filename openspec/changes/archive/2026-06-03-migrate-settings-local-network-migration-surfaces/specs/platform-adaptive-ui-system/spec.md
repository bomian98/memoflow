## ADDED Requirements

### Requirement: Local network migration settings surfaces SHALL use semantic settings UI seams

`LocalNetworkMigrationScreen`, `MemoFlowBridgeScreen`, and MemoFlow migration sender/receiver/result settings surfaces SHALL render page chrome, grouped status blocks, navigation entries, toggles, action rows, manual inputs, receiver QR/proposal sections, progress/status sections, result summaries, and explanatory notes through `SettingsPage`, `SettingsSection`, settings row/action/input components, `settingsPageTokens`, platform controls, theme colors, or equivalent settings/platform seams instead of local scaffold/card/palette/switch implementations.

#### Scenario: Local network migration hub and role screens are migrated

- **WHEN** `LocalNetworkMigrationScreen` renders MemoFlow Migration and Connect Obsidian entries
- **THEN** page chrome and target rows SHALL use settings semantic seams
- **AND** haptic behavior, localized labels, asset icons, route targets, and navigation to `MemoFlowMigrationRoleScreen` and `MemoFlowBridgeScreen` SHALL be preserved
- **WHEN** `MemoFlowMigrationRoleScreen` renders sender and receiver role choices
- **THEN** role choices SHALL use settings semantic rows or equivalent settings seams
- **AND** local library gating, haptics, localized labels, foreground notice, and navigation to sender/receiver screens SHALL be preserved

#### Scenario: MemoFlow bridge settings surface is migrated

- **WHEN** `MemoFlowBridgeScreen` renders pairing status, local mode notice, scan pair action, mDNS discovery action, manual host/port/pair-code inputs, confirm pair action, health check action, enable bridge toggle, clear pairing action, status message, or discovery results
- **THEN** those visible settings surfaces SHALL use settings semantic sections, rows, inputs, toggles, actions, theme/platform controls, or equivalent settings seams
- **AND** pairing, mDNS discovery, health check, QR scanner route, provider writes, toasts, validation labels, status messages, and enabled state SHALL be preserved
- **AND** the change SHALL NOT modify bridge network endpoints, payload parsing, Dio behavior, mDNS behavior, QR scanner behavior, device-name resolution, or bridge settings model/provider semantics

#### Scenario: MemoFlow migration sender, send-method, receiver, and result screens are migrated

- **WHEN** sender, send-method, receiver, or result screens render content selection, settings selection, package ready summary, scan/manual connect actions, auto-connect status, receiver QR/session details, proposal review, receive mode, sensitive config confirmation, progress, error/completion/result sections, bottom cancel action, or result summary rows
- **THEN** page chrome and grouped visible surfaces SHALL use settings semantic seams or equivalent settings/platform seams
- **AND** package build, sender/receiver controller calls, auto-connect, manual connect dialog validation, QR payload handling, proposal accept/reject, receive mode selection, sensitive config selection, progress calculation, result navigation, localized labels, and foreground notices SHALL be preserved
- **AND** the change SHALL NOT modify migration protocol, package format, config transfer, sender/receiver controllers, state models, local library persistence, database behavior, network payloads, API files, WebDAV behavior, AI settings, desktop routing, private hooks, or commercial logic

#### Scenario: Drift guardrail reflects completed local migration UI migration

- **WHEN** this batch is implemented
- **THEN** `local_network_migration_screen.dart`, `memoflow_bridge_screen.dart`, and in-scope `migration/memoflow_migration_*.dart` files SHALL be removed from `legacyAllowlist`
- **AND** those files SHALL be added to `migratedFiles`
- **AND** non-allowlisted migrated files SHALL continue to fail architecture verification if they reintroduce direct `Scaffold`, direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch`, `Switch.adaptive`, or private `_ToggleCard`
