## 1. 准备与边界

- [x] 1.1 读取当前 `LocationSettingsScreen`、location settings provider surface、focused test availability 和 drift guardrail，确认本批只覆盖 UI layer。
- [x] 1.2 运行 `openspec validate migrate-settings-location-page --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 将 `LocationSettingsScreen` root 迁移到 `SettingsPage` / `SettingsSection`。
- [x] 2.2 将 enable toggle、provider picker、API key input rows 和 precision selector 迁移到 settings semantic seams / settings tokens。
- [x] 2.3 删除 `_Group`、`_ToggleCard` 和 direct `MemoFlowPalette` 使用，保留 provider writes、controllers 和 `_dirty` subscription behavior。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`，将 `location_settings_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- [x] 3.2 增加 focused widget tests，覆盖 enabled toggle、provider switching/input fields 和 precision selection。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-location-page --strict`。
- [x] 4.2 运行 focused location settings widget test。
- [x] 4.3 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.4 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter analyze`。
- [x] 4.6 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
