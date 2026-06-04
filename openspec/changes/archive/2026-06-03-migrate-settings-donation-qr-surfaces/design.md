## Context

`DonationDialog` 是从 settings home 打开的 public donation surface，包含 QR asset、保存到相册、permission handling、success animation 和 confetti。它不是普通 settings page，但仍属于 `features/settings`，当前直接读取 `MemoFlowPalette` 并在本地用 `ElevatedButton.styleFrom` 定义 primary action；这会被 settings UI drift guardrail 视作未迁移。

`quick_qr_action.dart` 只负责 QR payload classification 与启动现有 bridge/migration route，不渲染 settings page，也没有 direct `Scaffold`、`MemoFlowPalette`、`styleFrom`、bare `Switch` 等视觉漂移。它继续留在 `legacyAllowlist` 会制造错误的剩余迁移信号。

本 change 位于 `evolve_modularity` 阶段，触碰的是 settings feature UI 和 guardrail，不涉及 `state`、`application`、`core` 依赖方向变化。

## Goals / Non-Goals

**Goals:**

- 将 `DonationDialog` 的 primary colors/action buttons 收敛到 settings/platform seam。
- 保留 donation QR image、long-press save、gallery permission、snackbar/top toast、success step、confetti 和 close/cancel 行为。
- 将 `donation_dialog.dart` 移入 `migratedFiles`，并将 `quick_qr_action.dart` 从 `legacyAllowlist` 移除。
- 增加 focused donation widget test，验证 request/success UI 与主要 action seam。
- 继续运行 quick QR classifier test，确认 payload classification 未变化。

**Non-Goals:**

- 不改变 donation business meaning、文案、QR asset、gallery save implementation 或 permission policy。
- 不修改 `quick_qr_action.dart` 的 classifier、routing、bridge pairing、migration sender 行为。
- 不迁移 `shortcut_editor_screen.dart`、`shortcuts_settings_screen.dart`、`memo_toolbar_settings_screen.dart`、`export_memos_screen.dart`、`import_export_shared_widgets.dart`、`memoflow_bridge_screen.dart` 或 `migration/*`。
- 不修改 API files、data API tests、private hooks、commercial/private overlay 或任何 paid-feature logic。

## Decisions

### Decision 1: Donation dialog 使用 settings tokens，而不是继续直接读 `MemoFlowPalette`

`DonationDialog` SHALL import `settings_ui.dart` and use `settingsPageTokens(context)` plus `Theme.of(context).colorScheme` for text/background/accent decisions. This keeps the local visual decisions inside the settings UI seam and allows `donation_dialog.dart` to enter `migratedFiles` without direct palette allowances.

Alternative considered: 在 guardrail 中给 `donation_dialog.dart` 添加 palette allowance。拒绝，因为该文件只是轻量 UI surface，使用现有 token seam 足够，allowance 会削弱迁移信号。

### Decision 2: Donation primary buttons 使用 `SettingsAction`

Request confirm 和 success close buttons SHALL use `SettingsAction` instead of page-local `ElevatedButton.styleFrom`。按钮仍可放在 `SizedBox(width: double.infinity)` 内保持原有宽度体验；icon、label 和 callbacks 保持不变。

Alternative considered: 新增 dialog-specific button component。拒绝，因为两处 primary action 不构成新抽象，`SettingsAction` 已覆盖平台 primary action 行为。

### Decision 3: Quick QR action 进入 migrated scan，但不做 runtime 修改

`quick_qr_action.dart` has no page-level visual drift, but the guardrail requires every `features/settings` Dart file to be either migrated or explicitly allowlisted. This batch SHALL move it from `legacyAllowlist` to `migratedFiles` without runtime edits, so future direct `Scaffold`、`MemoFlowPalette`、`styleFrom`、bare `Switch` 等漂移会被扫描阻止。Existing classifier tests continue to protect its non-UI behavior.

Alternative considered: 仅从 `legacyAllowlist` 移除但不加入 `migratedFiles`。拒绝，因为 uncovered files check 会失败，且让该文件脱离 guardrail tracking 不利于后续维护。

## Risks / Trade-offs

- [Risk] `SettingsAction` 视觉可能与旧 donation button 的 rounded/elevated style 略有差异。Mitigation: 保持 full-width placement、icon/label/callback，并用 focused widget test 验证 request/success action 可用。
- [Risk] Donation dialog 仍有 bespoke illustration containers，这是品牌/QR 弹窗的一部分，不是 settings page section。Mitigation: 本批只收敛 guardrail 关注的 palette/styleFrom 漂移，不强制把 dialog 改成 settings page。
- [Risk] Quick QR allowlist removal 可能暴露 future UI drift if file later adds UI. Mitigation: uncovered files check will fail if new settings file patterns appear outside allowlist/migrated set；后续新增 UI 时必须明确迁移或 allowlist。
