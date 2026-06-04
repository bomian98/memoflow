## 1. 准备与边界

- [x] 1.1 读取 `TemplateSettingsScreen`、`WidgetsScreen`、settings UI seam、focused test harness、drift guardrail 和 modularity guardrail，确认本批只覆盖 UI layer。
- [x] 1.2 运行 `openspec validate migrate-settings-simple-utility-surfaces --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 将 `TemplateSettingsScreen` root 迁移到 `SettingsPage` / `SettingsSection`，并用 settings semantic rows/tokens 承载 enable toggle、template list、empty state、variable settings entry 和 variable docs entry。
- [x] 2.2 删除模板页面 direct `Scaffold`、direct `MemoFlowPalette`、bare `Switch` 和 page-local rounded group/card visual drift；保留 template editor/delete dialogs、variable dialogs、provider calls、UID 和 sync behavior。
- [x] 2.3 将 `WidgetsScreen` root 迁移到 `SettingsPage` / `SettingsSection`，并用 settings semantic action/tokens 承载 widget preview groups、add action 和 version footer。
- [x] 2.4 删除 widgets 页面 direct `MemoFlowPalette` 和 page-local settings card/action visual drift；保留 preview content、Android gate、`HomeWidgetService.requestPinWidget`、toast 和 package info behavior。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`，将 `template_settings_screen.dart` 和 `widgets_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- [x] 3.2 增加 focused widget tests，覆盖 `TemplateSettingsScreen` settings seam usage、template toggle/list rendering 和代表性 dialog trigger。
- [x] 3.3 增加 focused widget tests，覆盖 `WidgetsScreen` settings seam usage、三类 preview/action rendering 和非 Android add toast behavior，不触发真实 Android pin request。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-simple-utility-surfaces --strict`。
- [x] 4.2 运行 focused simple utility settings widget tests。
- [x] 4.3 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.4 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter analyze`。
- [x] 4.6 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
