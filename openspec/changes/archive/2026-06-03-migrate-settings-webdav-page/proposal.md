## Why

`coordinate-settings-ui-migration-batches` 的第四批 WebDAV 页面迁移覆盖 `WebDavSyncScreen`。该 file 仍在 `settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 中，并且同一 file 内包含主 WebDAV 页、连接设置页、备份设置页、日志页、冲突 dialog 与 shared local row/card helpers。当前仍存在 direct `MemoFlowPalette`、page-local `_ToggleCard`、local card geometry 和 page-local `styleFrom`。

本 change 先完成 dedicated exploration，再按受控范围迁移 WebDAV settings presentation。同步、备份、恢复、连接测试、Vault、日志读取、冲突处理和 provider/service owner 必须保持原有调用路径。

## What Changes

- 将 `WebDavSyncScreen` 主页面迁移到 `SettingsPage`、`SettingsSection`、semantic settings rows/actions 或等价 settings/platform seams。
- 将同 file 内的 `_WebDavConnectionScreen`、`_WebDavBackupSettingsScreen` 和 `WebDavLogsScreen` 移出 direct palette/local card/button styling。
- 复用或窄范围调整现有 settings semantic seams，避免在 WebDAV 页面继续复制 toggle/nav/group/action styling。
- 保留 dialogs、pickers、connection test、backup/restore/progress、conflict resolution、logs detail 和 provider/service 调用行为。
- 更新 `settings_ui_drift_guardrail_test.dart`，把 `webdav_sync_screen.dart` 从 `legacyAllowlist` 移到 `migratedFiles`。
- 增加或更新 focused WebDAV widget tests，覆盖页面仍渲染关键 entries/actions，并继续运行既有 WebDAV flow tests。
- 记录验证结果：OpenSpec validate、focused WebDAV tests、settings drift guardrail、modularity guardrail 和 `flutter analyze`。

## Out of Scope

- 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters 或 version compatibility logic。
- 不改 WebDAV sync/backup/import/export/Vault crypto/service/repository 业务逻辑。
- 不迁移 AI settings、desktop routing、desktop settings window、shortcut overview 或 active-change-owned files。
- 不引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、private overlay 或 `AccessDecision.source` business branching。

## Capabilities

### Modified Capabilities

- `platform-adaptive-ui-system`: WebDAV settings page and same-file WebDAV settings subpages SHALL use settings semantic UI seams and SHALL be tracked as migrated by the settings UI drift guardrail.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/webdav_sync_screen.dart`
  - `memos_flutter_app/lib/features/settings/settings_ui.dart` only if a narrow shared WebDAV-independent presentation seam is required
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - `memos_flutter_app/test/features/settings/webdav_conflict_flow_test.dart`
  - `memos_flutter_app/test/features/settings/settings_screen_test.dart` only if shared focused settings assertions need adjustment
- Public/private boundary: must remain commercial-free and must not alter private extension hooks.
