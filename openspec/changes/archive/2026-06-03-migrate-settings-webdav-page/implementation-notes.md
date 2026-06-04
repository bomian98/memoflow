## Implementation Notes

本批按 `coordinate-settings-ui-migration-batches` 的第四批 WebDAV 规则执行。runtime 范围覆盖同一 file 内的 WebDAV settings surfaces：

- `WebDavSyncScreen`
- `_WebDavConnectionScreen`
- `_WebDavBackupSettingsScreen`
- `WebDavLogsScreen`

## Visible Changes

- `WebDavSyncScreen` root page 改为 `SettingsPage` + `SettingsSection`，enable WebDAV sync 使用 `SettingsToggleRow`，connection / backup / Vault status / logs entries 使用 `SettingsNavigationRow`。
- root page 的 start backup / restore actions 改为 `SettingsAction`，移除 page-local `ElevatedButton.styleFrom` 和 `OutlinedButton.styleFrom`。
- `_WebDavConnectionScreen` 改为 `SettingsPage` + `SettingsSection`，保留 existing `_InputRow` / picker / password visibility composition，但 section/page chrome 使用 settings seam。
- `_WebDavBackupSettingsScreen` 的 page tokens 改为 settings tokens，分组 `_Group` 委托 `SettingsSection`，保留 existing backup rows/pickers/exit guard。
- `WebDavLogsScreen` 改用 settings tokens，移除 direct palette background/card/text access，保留 refresh/list/detail dialog。
- 删除 `_ToggleCard`，并从 `webdav_sync_screen.dart` 移除 direct `MemoFlowPalette` 使用。

## Preserved Behavior

- 保留 `webDavSettingsProvider` writes、dirty state、connection test、manual sync、backup now、restore backup、progress pause/resume、conflict resolution、Vault setup/recovery/password flow、backup settings exit guard、log refresh 和 log detail dialog。
- 保留所有 sync/backup/Vault provider/service/repository 调用路径；本批未移动 WebDAV 业务 owner。
- 本批未修改 API files、data API tests、request/response models、route adapters、private hooks、commercial logic、AI settings、desktop routing 或 desktop settings window。

## Guardrail State

- `webdav_sync_screen.dart` 已从 `legacyAllowlist` 移入 `migratedFiles`。
- 本批没有新增 `settings_ui_drift_guardrail_test.dart` allowance。

## Verification Results

- `openspec validate migrate-settings-webdav-page --strict`: passed。
- `flutter test test/features/settings/webdav_conflict_flow_test.dart --reporter expanded`: passed，`5/5` tests passed。
- `flutter test test/features/settings/settings_screen_test.dart --reporter expanded`: passed，`22/22` tests passed。
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`: passed，`1/1` test passed。
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`: passed，`32/32` tests passed。
- `flutter analyze`: passed，`No issues found`。

## Remaining Risks / Follow-up

- AI settings and desktop routing remain deferred per total-control rule because related active changes still own those areas.
- Some WebDAV-specific row helpers remain same-file presentation helpers, but direct palette/local toggle card/button style drift has been removed and the group helper now delegates to `SettingsSection`.
