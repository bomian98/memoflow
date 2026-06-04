## Why

local network migration 相关页面仍在 `settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 中，并且混用了 direct `Scaffold`、page-local `AppBar`、direct `MemoFlowPalette`、page-local rounded cards、`SwitchListTile` 和普通 `Card`/button 表达。前置批次已经完成 import/export hub 和 export memos page；本批继续收敛 Local Network Migration、MemoFlow Bridge 与 MemoFlow migration 子流程的 settings UI drift。

本 change 只迁移 presentation layer，不修改迁移协议、package builder、sender/receiver controller、mDNS/Dio/QR scanner 行为、数据库/本地库写入、API 或 public/private/commercial 边界。

## What Changes

- 将 `LocalNetworkMigrationScreen` root 迁移到 `SettingsPage`，使用 settings semantic rows/sections 承载 MemoFlow Migration 与 Connect Obsidian 入口。
- 将 `MemoFlowMigrationRoleScreen` root 迁移到 `SettingsPage`，使用 settings navigation/info rows 承载 sender/receiver 角色选择。
- 将 `MemoFlowBridgeScreen` 的页面 chrome、paired status、manual input、action、enable toggle 和 discovery results 迁移到 settings seams，同时保留 pairing、mDNS discovery、health check、QR scanner 和 bridge settings provider 行为。
- 将 `MemoFlowMigrationSenderScreen`、`MemoFlowMigrationSendMethodScreen`、`MemoFlowMigrationReceiverScreen`、`MemoFlowMigrationResultScreen` 的 page chrome 与主要 grouped surfaces 迁移到 settings seams，保留 controller state、package build、manual connect dialog、receiver QR、proposal review、progress、result navigation 和 labels。
- 更新 `settings_ui_drift_guardrail_test.dart`，将本批迁移文件从 `legacyAllowlist` 移入 `migratedFiles`。
- 更新/补充 focused widget tests，覆盖 local migration hub seam、role navigation、bridge toggle/input surface、sender/send-method seam 和 result/progress labels。

## Out of Scope

- 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters 或 version compatibility logic。
- 不修改 migration protocol、config transfer codec、package builder、sender/receiver state/controller、mDNS/Dio endpoints、QR scanner parsing、database/local library persistence、network payload、file/package format 或 platform plugin behavior。
- 不修改 WebDAV、AI settings、desktop routing/window、shortcut editor、memo toolbar、quick QR action、private hooks 或 commercial logic。
- 不引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、private overlay 或 `AccessDecision.source` business branching。

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `platform-adaptive-ui-system`: local network migration settings surfaces SHALL use settings semantic UI seams and SHALL be tracked as migrated by the settings UI drift guardrail.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/local_network_migration_screen.dart`
  - `memos_flutter_app/lib/features/settings/memoflow_bridge_screen.dart`
  - `memos_flutter_app/lib/features/settings/migration/memoflow_migration_role_screen.dart`
  - `memos_flutter_app/lib/features/settings/migration/memoflow_migration_sender_screen.dart`
  - `memos_flutter_app/lib/features/settings/migration/memoflow_migration_send_method_screen.dart`
  - `memos_flutter_app/lib/features/settings/migration/memoflow_migration_receiver_screen.dart`
  - `memos_flutter_app/lib/features/settings/migration/memoflow_migration_result_screen.dart`
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - `memos_flutter_app/test/features/settings/local_network_migration_screen_test.dart`
  - `memos_flutter_app/test/features/settings/memoflow_migration_sender_screen_test.dart`
- Public/private/API boundary: UI-only migration; must not edit API files, migration protocol/controller/model behavior, private hooks, or commercial logic.
- Architecture phase: `evolve_modularity`; this change touches settings feature UI and guardrails, so it must shrink drift allowlist and preserve existing migration/service owners.
