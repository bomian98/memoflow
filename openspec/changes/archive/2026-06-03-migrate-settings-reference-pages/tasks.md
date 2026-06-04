## 1. 准备与边界

- [x] 1.1 读取总控 change、当前 settings UI seam、目标三页和 drift guardrail，确认本批只覆盖 reference / entry pages。
- [x] 1.2 运行 `openspec validate migrate-settings-reference-pages --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 将 `LaboratoryScreen` 迁移到 `SettingsPage` / `SettingsSection` / semantic rows，保留入口跳转、版本展示和 `showBackButton` 行为。
- [x] 2.2 将 `UserGuideScreen` 迁移到 settings semantic UI seam，保留 usememos docs 外链、说明弹层、haptics 和 snackbar 行为。
- [x] 2.3 将 `SettingsPlaceholderScreen` 迁移到 settings page/section seam，保留 dynamic i18n title/message lookup 和返回行为。
- [x] 2.4 如需要，窄范围扩展 `settings_ui.dart`；若现有 seam 足够，则不修改 shared seam。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`，将本批三页从 `legacyAllowlist` 移入 `migratedFiles`。
- [x] 3.2 增加 focused settings widget tests，覆盖本批页面的关键入口、说明弹层触发点和 placeholder 文案渲染。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-reference-pages --strict`。
- [x] 4.2 运行 focused settings widget tests。
- [x] 4.3 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.4 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter analyze`，或记录明确环境 blocker。
- [x] 4.6 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
