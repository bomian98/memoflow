## 1. 准备与边界

- [x] 1.1 读取总控 change、当前 settings UI seam、目标三页和 drift guardrail，确认本批只覆盖 support/general 页面。
- [x] 1.2 运行 `openspec validate migrate-settings-account-support-pages --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 将 `FeedbackScreen` 迁移到 `SettingsPage` / `SettingsSection` / semantic rows，保留提交日志、自修复、外部反馈链接和 haptics。
- [x] 2.2 将 `AboutUsScreen` / `AboutUsContent` 迁移到 settings semantic UI seam，保留 logo/version、链接、发布说明、捐赠鸣谢和 debug tap 行为。
- [x] 2.3 将 `UserGeneralSettingsScreen` 迁移到 settings semantic UI seam，保留 locale/default visibility picker、保存状态、错误/重试和 provider/API 调用行为。
- [x] 2.4 如需要，窄范围扩展 `settings_ui.dart` 的共享 row seam，避免在页面内复制 row/card styling。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`，将本批三页从 `legacyAllowlist` 移入 `migratedFiles`。
- [x] 3.2 增加或更新 focused settings widget tests，覆盖 support/about/user general 的关键入口和 server-wide controls 负例。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-account-support-pages --strict`。
- [x] 4.2 运行 `flutter test test/features/settings/settings_screen_test.dart --reporter expanded`。
- [x] 4.3 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.4 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter analyze`，或记录明确环境 blocker。
- [x] 4.6 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
