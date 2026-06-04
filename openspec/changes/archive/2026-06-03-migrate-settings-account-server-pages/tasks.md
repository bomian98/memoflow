## 1. 准备与边界

- [x] 1.1 读取总控规则、第一批 implementation notes、当前 settings UI seam、`AccountSecurityScreen`、`ServerSettingsScreen`、focused tests 和 drift guardrail，确认本批只覆盖 account/server 页面。
- [x] 1.2 运行 `openspec validate migrate-settings-account-server-pages --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 窄范围扩展 `settings_ui.dart` 的共享 seam，用于 account/server 通用 presentation，避免 page-local cards/rows。
- [x] 2.2 将 `AccountSecurityScreen` 迁移到 settings semantic UI seam，保留账户、本地文库、导航、dialog、snackbar 和 haptics 行为。
- [x] 2.3 将 `ServerSettingsScreen` 迁移到 settings semantic UI seam，保留 refresh、controller sync、focus blur restore、input validation、save status 和 provider/API 调用路径。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`，将 `account_security_screen.dart` 和 `server_settings_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- [x] 3.2 增加或更新 focused settings widget tests，覆盖 account/server 页面 semantic seam 和 server field 行为。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-account-server-pages --strict`。
- [x] 4.2 运行 `flutter test test/features/settings/settings_screen_test.dart --reporter expanded`。
- [x] 4.3 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.4 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter analyze`，或记录明确环境 blocker。
- [x] 4.6 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
