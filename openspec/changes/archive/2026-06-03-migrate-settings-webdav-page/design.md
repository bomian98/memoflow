## Context

`WebDavSyncScreen` 是 remaining settings legacy allowlist 中最大的普通 settings flow。它不是单页简单表单，而是一个包含多个 settings surfaces 的同一 Dart library：

- `WebDavSyncScreen`: enable toggle、connection entry、backup settings entry、Vault status entry、logs entry、manual backup/restore actions、progress display、sync error copy。
- `_WebDavConnectionScreen`: server URL、credential、auth mode、TLS/root path、connection test。
- `_WebDavBackupSettingsScreen`: backup content toggles、config scope dropdown、backup mode、password setup、schedule、retention、error copy、exit guard。
- `WebDavLogsScreen`: WebDAV debug log list/detail/refresh。
- `_WebDavConflictDialog`: conflict resolution dialog，主要是 behavior dialog，不是 settings page surface。

由于 `settings_ui_drift_guardrail_test.dart` 以 file 为单位扫描，若要把 `webdav_sync_screen.dart` 移入 `migratedFiles`，必须消除同 file 内所有 direct `MemoFlowPalette`、`_ToggleCard`、page-local `styleFrom` 等 drift patterns。只迁移主页面不足以通过 guardrail。

## Dedicated Exploration Findings

### Presentation-only migration areas

- Page chrome/background/bounded content 可由 `SettingsPage` 和 `settingsPageTokens` 承担。
- Grouped rows 可由 `SettingsSection`、`SettingsToggleRow`、`SettingsNavigationRow`、`SettingsInputRow`、`SettingsInfoRow`、`SettingsAction` 或 same-file presentation helpers that delegate to platform/settings seams 承担。
- Manual backup/restore buttons 可由 `SettingsAction` + `PlatformPrimaryActionVariant` 承担，去除 page-local `styleFrom`。
- Progress/log cards 可以使用 settings tokens/theme tokens 或 settings section rows，不能直接访问 `MemoFlowPalette`。

### Behavior owner areas that must stay in place

- `webDavSettingsProvider` state writes and dirty sync behavior。
- `syncCoordinatorProvider` / `desktopSyncFacadeProvider` manual sync、backup、restore、connection test、conflict resolution。
- Vault setup/recovery/password/repository flow。
- WebDAV backup progress tracker pause/resume。
- Debug log store read/list/detail behavior。
- Dialogs for backup password、existing Vault、recovery code、config restore、conflicts、backup exit guard。

### Existing focused tests

- `test/features/settings/webdav_conflict_flow_test.dart`
  - manual sync conflict flow
  - plaintext backup encrypted-only security hint
  - connection screen test connection button and success message
  - backup settings abandon/confirm close flow
  - plain backup settings close flow
- Broader sync/backup service tests exist under `test/application/sync`, but this batch should not require touching service behavior.

### Pause conditions specific to WebDAV

暂停条件包括：

- 迁移需要编辑 sync/backup/Vault service、repository、data API 或 route adapter。
- connection test、backup restore、conflict resolution、password/Vault setup 或 log detail behavior 测试失败，且修复会超出 presentation scope。
- 需要触碰 AI/desktop routing/private hooks/commercial logic。

## Decisions

### Decision 1: Migrate the whole WebDAV settings library surface in one child change

Because guardrail scans `webdav_sync_screen.dart` as one file, this batch SHALL handle the main page and same-file WebDAV settings subpages together. The migration remains presentation-only; behavior functions stay in the same state classes.

Rationale: Moving only the root `WebDavSyncScreen` would leave direct palette/style drift in the same file and could not be tracked as migrated.

### Decision 2: Keep behavior closures and service calls unchanged

All WebDAV sync/backup/restore/Vault/log provider calls SHALL remain in the existing methods. The build methods and same-file presentation helpers may change; service ownership SHALL NOT move into settings UI seams.

Rationale: WebDAV is high risk. Presentation migration should not alter data flow or side-effect order.

### Decision 3: Prefer existing generic settings seams over new abstractions

Use existing `SettingsPage`, `SettingsSection`, `SettingsToggleRow`, `SettingsNavigationRow`, `SettingsInputRow`, `SettingsInfoRow`, `SettingsAction`, `SettingsRowTitle`, and `SettingsRowDescription` where they fit. New helpers, if needed, must be page-local presentation delegates without provider/service logic.

Rationale: This keeps the touched coupled settings area equal or better structured while avoiding broad rewrites.

### Decision 4: Drift guardrail shrink is required

After migration, `webdav_sync_screen.dart` SHALL move from `legacyAllowlist` to `migratedFiles` with no broad allowances. Any narrow allowance must be documented, but the intended target is zero new allowance.

Rationale: This is the only reliable guardrail against reintroducing local scaffold/palette/button/toggle styling in the largest remaining settings flow.

## Risks / Mitigations

- [Risk] Connection/backup/restore behavior regresses. Mitigation: keep handlers and provider calls in place; run existing `webdav_conflict_flow_test.dart`.
- [Risk] Large build method edits cause layout/test text drift. Mitigation: preserve visible labels and route entry text already asserted by tests.
- [Risk] Shared settings seam grows with WebDAV-specific semantics. Mitigation: only add generic presentation support if needed; otherwise use same-file helpers.
- [Risk] Guardrail fails due to same-file subpages. Mitigation: scan the whole file for banned patterns before moving it to `migratedFiles`.

## Verification Plan

- `openspec validate migrate-settings-webdav-page --strict`
- `flutter test test/features/settings/webdav_conflict_flow_test.dart --reporter expanded`
- `flutter test test/features/settings/settings_screen_test.dart --reporter expanded` if shared settings assertions are affected
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`
- `flutter analyze`
