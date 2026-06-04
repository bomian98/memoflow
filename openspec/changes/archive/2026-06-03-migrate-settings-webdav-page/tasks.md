## 1. 准备与 dedicated exploration

- [x] 1.1 读取总控规则、security implementation notes、当前 `settings_ui.dart` seam、`WebDavSyncScreen` 结构、focused WebDAV tests 和 drift guardrail。
- [x] 1.2 完成 WebDAV dedicated exploration，记录 presentation-only areas、behavior owner areas、existing tests 和 pause conditions。
- [x] 1.3 运行 `openspec validate migrate-settings-webdav-page --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 将 `WebDavSyncScreen` 主页面迁移到 settings semantic UI seam，保留 enable、navigation entries、manual sync、backup/restore、progress 和 error behavior。
- [x] 2.2 将 `_WebDavConnectionScreen` 迁移到 settings semantic UI seam，保留 field controllers、connection test、auth/TLS/root path behavior。
- [x] 2.3 将 `_WebDavBackupSettingsScreen` 迁移到 settings semantic UI seam，保留 backup content、config scope、encryption/password/schedule/retention、exit guard 和 backup error behavior。
- [x] 2.4 将 `WebDavLogsScreen` 移出 direct palette/local card styling，保留 refresh、empty state、log detail dialog 行为。
- [x] 2.5 删除或替换 same-file legacy presentation helpers/patterns：direct `MemoFlowPalette`、`_ToggleCard`、page-local `styleFrom`、direct local card styling where replaced by settings seams。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`，将 `webdav_sync_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- [x] 3.2 增加或更新 focused WebDAV widget tests，覆盖 WebDAV root/subpages semantic seams 和关键 actions/entries。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-webdav-page --strict`。
- [x] 4.2 运行 `flutter test test/features/settings/webdav_conflict_flow_test.dart --reporter expanded`。
- [x] 4.3 运行 `flutter test test/features/settings/settings_screen_test.dart --reporter expanded`，如本批影响 shared settings assertions。
- [x] 4.4 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.6 运行 `flutter analyze`，或记录明确环境 blocker。
- [x] 4.7 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
