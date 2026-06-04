## 1. 准备与边界

- [x] 1.1 读取总控规则、前两批 implementation notes、当前 settings UI seam、`PasswordLockScreen`、`VaultSecurityStatusScreen`、focused tests 和 drift guardrail，确认本批只覆盖 security 页面。
- [x] 1.2 运行 `openspec validate migrate-settings-security-pages --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 将 `PasswordLockScreen` 迁移到 `SettingsPage` / `SettingsSection` / semantic rows，保留 enable app lock、password dialog、auto-lock picker 和 toast 行为。
- [x] 2.2 将 `VaultSecurityStatusScreen` 迁移到 settings semantic UI seam，保留 status loading、cleanup reminders、recovery code、backup test、clear plaintext 和 provider/service 调用路径。
- [x] 2.3 如需要，窄范围处理 part file 所需 import 或共享 presentation seam，避免在目标页面内复制 card/row/button styling。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`，将 `password_lock_screen.dart` 和 `vault_security_status_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- [x] 3.2 增加或更新 focused settings widget tests，覆盖 password lock 与 Vault status 页面 semantic seams 和关键安全 controls/actions。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-security-pages --strict`。
- [x] 4.2 运行 `flutter test test/features/settings/settings_screen_test.dart --reporter expanded`。
- [x] 4.3 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.4 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter analyze`，或记录明确环境 blocker。
- [x] 4.6 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
