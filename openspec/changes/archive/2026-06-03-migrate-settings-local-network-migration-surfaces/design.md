## Context

Local network migration surfaces are currently split across:

- `LocalNetworkMigrationScreen`: entry hub for MemoFlow Migration and Connect Obsidian.
- `MemoFlowBridgeScreen`: Obsidian/MemoFlow bridge pairing and discovery form.
- `MemoFlowMigrationRoleScreen`: sender/receiver role selection.
- `MemoFlowMigrationSenderScreen`: sender content selection and package build entry.
- `MemoFlowMigrationSendMethodScreen`: scan/manual send method, status, result navigation.
- `MemoFlowMigrationReceiverScreen`: receiver session, QR display, proposal review, progress and result navigation.
- `MemoFlowMigrationResultScreen`: migration result summary.

These files still own user-facing settings presentation, but migration business behavior lives in existing application/state classes and must stay there. This batch converts page chrome and grouped visual surfaces to established settings seams while preserving the behavior owners.

当前架构阶段为 `evolve_modularity`。本 change 只触碰 `features/settings` UI 与 guardrail，不新增 `state -> features`、`application -> features` 或 `core -> higher-layer` dependency。

## Goals / Non-Goals

**Goals:**

- Replace direct settings page `Scaffold`/page-local `AppBar` usage with `SettingsPage`.
- Use `SettingsSection`, `SettingsNavigationRow`, `SettingsInfoRow`, `SettingsToggleRow`, `SettingsAction`, `SettingsInputRow`, theme/platform controls, or equivalent settings seams for main migration surfaces.
- Remove direct `MemoFlowPalette` and bare `SwitchListTile` from migrated runtime files.
- Preserve route targets, haptics, provider reads/writes, controller calls, pairing/discovery/health check methods, package build/connect flow, receiver QR/proposal flow, result labels and dialog behavior.
- Move migrated files from `legacyAllowlist` to `migratedFiles` and keep focused tests green.

**Non-Goals:**

- No migration protocol, package builder, controller/state/model, mDNS/Dio/QR scanner, DB/local-library persistence, API or platform plugin changes.
- No WebDAV, AI, desktop routing, shortcut editor, memo toolbar, private hook or commercial boundary work.
- No broad decomposition of migration business logic in this batch. If implementation shows behavior extraction is required, pause and update artifacts instead of guessing.

## Decisions

### Decision 1: Use `SettingsPage` for migrated page chrome

Every in-scope settings surface SHALL use `SettingsPage` for page chrome and bounded content. This removes duplicated background, dark gradient, app bar leading and direct palette handling from individual screens.

Alternative considered: leave migration screens allowlisted because they are flows. Rejected for hub/role/bridge/sender/receiver/result surfaces because their visible UI can use existing settings seams without changing behavior.

### Decision 2: Keep migration behavior methods and controller ownership intact

`MemoFlowBridgeScreen` pairing/discovery/health methods and sender/receiver controller calls SHALL remain behavior-equivalent. This batch may change only how actions and state are presented.

Alternative considered: extract bridge pairing and migration screen logic into services during the UI migration. Rejected for this batch because it would expand behavior risk; any such refactor needs a separate design.

### Decision 3: Prefer existing settings seams over new local card widgets

Hub targets, roles, status blocks, result rows, toggles and forms SHOULD use `SettingsSection` and semantic rows/actions. If a complex flow-specific widget remains necessary, it must not use direct `MemoFlowPalette`, bare switches or local page chrome drift.

Alternative considered: create a migration-specific card system. Rejected unless implementation proves `settings_ui.dart` lacks a needed primitive, because the goal is to reduce local visual systems.

### Decision 4: Guardrail migration happens with runtime migration

After runtime migration, every in-scope file SHALL move from `legacyAllowlist` to `migratedFiles`. If a file cannot be migrated within scope, implementation must pause and explain why.

Alternative considered: keep files allowlisted until all migration behavior is refactored. Rejected because UI drift guardrail should reflect completed presentation migration, not business decomposition status.

## Risks / Trade-offs

- [Risk] Bridge page has real network/mDNS/QR behavior near UI code. Mitigation: only change build composition and not pairing/discovery/health implementations.
- [Risk] Receiver screen QR/proposal/progress states are more complex than normal settings pages. Mitigation: preserve state branches and only swap page/section/action wrappers.
- [Risk] Focused widget tests may need minor seam assertions while avoiding network/QR execution. Mitigation: tests cover render/navigation/toggle/manual dialog labels, not real network pairing.
- [Risk] Some flow-specific `Card` or `SegmentedButton` usage may remain for complex inner state. Mitigation: root/page chrome and main sections still use settings seams, and drift guardrail blocks the highest-risk patterns.
