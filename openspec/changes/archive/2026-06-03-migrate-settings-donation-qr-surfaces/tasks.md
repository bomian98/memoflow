## 1. 准备与边界

- [x] 1.1 读取 `DonationDialog`、`quick_qr_action.dart`、settings UI seam、focused tests、drift guardrail 和 modularity guardrail，确认本批只覆盖 public donation/QR 小 surface。
- [x] 1.2 运行 `openspec validate migrate-settings-donation-qr-surfaces --strict`，确认 child artifacts 可 apply。

## 2. Runtime migration

- [x] 2.1 将 `DonationDialog` 的 direct `MemoFlowPalette` 颜色读取迁移到 `settingsPageTokens`、`Theme.of(context).colorScheme` 或等价 settings/platform seam。
- [x] 2.2 将 donation request/success primary buttons 从 page-local `ElevatedButton.styleFrom` 迁移到 `SettingsAction`，保留 icon、labels、callbacks、full-width placement 和 success flow。
- [x] 2.3 确认 `quick_qr_action.dart` 不需要 runtime 修改；若发现必要 cleanup，只允许非行为性 UI seam 调整，不修改 classifier 或 routing。

## 3. Guardrails and tests

- [x] 3.1 更新 `settings_ui_drift_guardrail_test.dart`：移除 `quick_qr_action.dart` legacy allowlist，移除 `donation_dialog.dart` legacy allowlist，并将 `donation_dialog.dart` 与 `quick_qr_action.dart` 加入 `migratedFiles`。
- [x] 3.2 增加 focused donation dialog widget tests，覆盖 request UI、`SettingsAction` seam、confirm 后 success UI 和 close/cancel 行为。
- [x] 3.3 继续运行并保留 `quick_qr_action_test.dart` 覆盖，确认 QR classifier 行为未变化。

## 4. 验证与记录

- [x] 4.1 运行 `openspec validate migrate-settings-donation-qr-surfaces --strict`。
- [x] 4.2 运行 focused donation/quick QR widget tests。
- [x] 4.3 运行 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`。
- [x] 4.4 运行 `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`。
- [x] 4.5 运行 `flutter analyze`。
- [x] 4.6 记录本批肉眼可见变化、保留行为、验证结果和剩余风险。
