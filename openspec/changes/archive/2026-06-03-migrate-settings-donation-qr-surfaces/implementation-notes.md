## 实施记录

本批已完成 public donation / quick QR 小 surface 的 settings UI drift 收敛。

## 肉眼可见变化

- `DonationDialog` 不再直接读取 `MemoFlowPalette`，改用 `settingsPageTokens(context)`、`Theme.of(context).colorScheme` 和 settings/platform seam。
- Donation request/success primary actions 改用 `SettingsAction`，保留 full-width placement、icon、labels 和 callbacks。
- Donation dialog content 增加 `SingleChildScrollView`，避免较小视口下 request card 内容溢出。
- `settings_ui_drift_guardrail_test.dart` 已将 `donation_dialog.dart` 和 `quick_qr_action.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。

## 保留行为

- 保留 `DonationDialog.show` 的 `showGeneralDialog` entry。
- 保留 donation QR asset、long-press save QR、gallery permission handling、snackbar/top toast、success step、confetti 和 cancel/close 行为。
- `quick_qr_action.dart` 没有 runtime 修改；QR classifier、bridge pairing、migration sender routing 和 unsupported QR rejection 行为保持不变。
- 未修改 API files、request/response models、route adapters、version compatibility logic、private hooks 或 commercial/private overlay。

## 验证

- `openspec validate migrate-settings-donation-qr-surfaces --strict`
- `flutter test test/features/settings/donation_dialog_test.dart test/features/settings/quick_qr_action_test.dart --reporter expanded`
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`
- `flutter analyze`

以上均通过。

## 剩余风险

- 本批不迁移 shortcut、memo toolbar、import/export shared widgets、migration flow 或 bridge screen；这些仍留给后续 dedicated batches。
- Donation dialog 仍保留 bespoke QR/animation visual layout，这是 public donation surface 的既有体验，不强制改成普通 settings page section。
