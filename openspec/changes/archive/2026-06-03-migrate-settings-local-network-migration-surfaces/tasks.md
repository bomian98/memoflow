## 1. 准备与边界

- [x] 1.1 读取 local network migration hub、MemoFlow Bridge、migration sender/receiver/result screens、settings UI seam、focused tests、drift guardrail 和 modularity guardrail，确认本批只覆盖 local migration UI layer。
- [x] 1.2 运行 `openspec validate migrate-settings-local-network-migration-surfaces --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 将 `LocalNetworkMigrationScreen` root 迁移到 `SettingsPage`，用 settings sections/navigation/info rows 承载 MemoFlow Migration、Connect Obsidian 和说明文字，并保留 haptics、asset icons、route targets 和 labels。
- [x] 2.2 将 `MemoFlowMigrationRoleScreen` root 迁移到 `SettingsPage`，用 settings rows 承载 sender/receiver 角色选择，保留 local library gating、haptics、foreground notice 和 route targets。
- [x] 2.3 将 `MemoFlowBridgeScreen` root 和主要 grouped surfaces 迁移到 settings seams，删除 direct `Scaffold`、page-local `AppBar`、direct `MemoFlowPalette` 和 `SwitchListTile`，保留 pairing/discovery/health/QR/provider/toast/input validation 行为。
- [x] 2.4 将 `MemoFlowMigrationSenderScreen`、`MemoFlowMigrationSendMethodScreen`、`MemoFlowMigrationReceiverScreen`、`MemoFlowMigrationResultScreen` 的 page chrome 和 grouped visible surfaces 迁移到 settings seams，保留 controller calls、manual dialog、QR/proposal/progress/result behavior 和 labels。
- [x] 2.5 验证 in-scope runtime files 不再命中 direct `Scaffold`、direct `MemoFlowPalette`、page-local `styleFrom`、bare `Switch` / `Switch.adaptive`、private `_ToggleCard` drift patterns。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`，将 `local_network_migration_screen.dart`、`memoflow_bridge_screen.dart` 和 in-scope `migration/memoflow_migration_*.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- [x] 3.2 更新 focused local network migration widget tests，覆盖 `SettingsPage`/settings sections、hub navigation、role screen labels、bridge settings toggle/input surface。
- [x] 3.3 更新 focused sender/send-method tests，覆盖 settings seams、package ready/manual dialog labels 和 auto-connect behavior。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-local-network-migration-surfaces --strict`。
- [x] 4.2 运行 focused local migration widget tests。
- [x] 4.3 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.4 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter analyze`。
- [x] 4.6 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
