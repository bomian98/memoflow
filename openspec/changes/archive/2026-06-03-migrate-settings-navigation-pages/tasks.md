## 1. 准备与边界

- [x] 1.1 读取总控状态、当前 settings UI seam、目标四页、focused tests 和 drift guardrail，确认本批只覆盖 navigation / home customization settings。
- [x] 1.2 运行 `openspec validate migrate-settings-navigation-pages --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 将 `NavigationModeScreen` 迁移到 `SettingsPage` / `SettingsSection` / semantic rows，保留模式选择、bottom settings 独立入口和 test keys。
- [x] 2.2 将 `BottomNavigationModeSettingsScreen` 迁移到 settings page/section seam，保留 preview、slot picker、center fixed action 和 destination availability/disabled rules。
- [x] 2.3 将 `CustomizeDrawerScreen` 迁移到 `SettingsPage` / `SettingsSection` / `SettingsToggleRow`，保留 drawer visibility setters。
- [x] 2.4 将 `CustomizeHomeShortcutsScreen` 迁移到 settings page/section seam，保留 slot picker、candidate filtering、used action disabled state 和 provider writes。
- [x] 2.5 如需要，窄范围扩展 `settings_ui.dart`；若现有 seam 足够，则不修改 shared seam。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`，将本批四页从 `legacyAllowlist` 移入 `migratedFiles`。
- [x] 3.2 更新 focused tests 中因 semantic rows 改变而失效的 finder，保持行为断言不降低。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-navigation-pages --strict`。
- [x] 4.2 运行 `flutter test test/features/settings/navigation_mode_screen_test.dart --reporter expanded`。
- [x] 4.3 运行 `flutter test test/features/settings/settings_screen_test.dart --reporter expanded`。
- [x] 4.4 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.6 运行 `flutter analyze`，或记录明确环境 blocker。
- [x] 4.7 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
