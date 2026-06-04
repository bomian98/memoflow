## Why

`settings_ui_drift_guardrail_test.dart` 中仍保留 `donation_dialog.dart` 与 `quick_qr_action.dart` 的 legacy allowlist entry。`DonationDialog` 是 public donation entry 的轻量弹窗 surface，但仍直接使用 `MemoFlowPalette` 和 page-local `styleFrom`；`quick_qr_action.dart` 本身没有页面壳或视觉漂移，继续 allowlist 会让剩余范围看起来比实际更大。

本 change 继续按 `coordinate-settings-ui-migration-batches` 的门禁推进下一批，只收敛 donation/QR 小 surface，不触碰 API、AI、desktop routing、migration flow、shortcut editor、memo toolbar 或 import/export 行为。

## What Changes

- 将 `DonationDialog` 的颜色 token 和 primary action 样式迁移到 settings/platform seam，避免直接依赖 `MemoFlowPalette` 与 page-local `ElevatedButton.styleFrom`。
- 保留 donation QR asset、long-press save QR、gallery permission handling、snackbar/top toast、success animation、confetti、close/cancel 行为和 public donation entry。
- 将 `quick_qr_action.dart` 从 `legacyAllowlist` 移入 `migratedFiles`；该文件没有 direct settings page UI drift，但仍应被 guardrail 覆盖，防止后续新增本地视觉漂移。
- 更新 `settings_ui_drift_guardrail_test.dart`，将 `donation_dialog.dart` 与 `quick_qr_action.dart` 移入 `migratedFiles`。
- 增加或更新 focused tests，覆盖 donation dialog 的主要 request/success UI seam，以及 quick QR classifier 仍保持现有行为。

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `platform-adaptive-ui-system`: donation dialog settings surface SHALL use settings/platform UI seams for colors/actions, and quick QR action SHALL not remain allowlisted when it has no page-level visual drift.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/donation_dialog.dart`
  - `memos_flutter_app/lib/features/settings/quick_qr_action.dart` only if implementation finds a small non-behavioral seam cleanup is needed; otherwise no runtime edit is expected.
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - `memos_flutter_app/test/features/settings/quick_qr_action_test.dart`
  - optional focused donation widget test under `memos_flutter_app/test/features/settings/`
- Public/private/API boundary:
  - 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters、version compatibility logic、private hooks 或 commercial/private overlay。
  - Donation entry and QR asset stay public. This change MUST NOT introduce subscription、billing、entitlement、receipt、paywall、StoreKit、product ID 或 `AccessDecision.source` business branching。
- Architecture phase: `evolve_modularity`。本 change 触碰 settings feature UI 和 guardrail，必须通过 drift guardrail 收缩 allowlist，并且不得新增 `state -> features`、`application -> features` 或 `core -> higher-layer` dependency。
