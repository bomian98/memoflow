## Why

`LocalModeSetupScreen` 仍在 `settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 中，并持有 direct `Scaffold`、page-local `AppBar`、manual bounded content 和 card/form layout。该页面只是本地模式创建/重命名时的轻量输入 surface，实际调用方负责接收 `LocalModeSetupResult` 并执行业务。

本 change 只迁移本地模式设置页的 settings UI surface，让它使用 `SettingsPage` / `SettingsSection` / settings rows/actions，并保持本地库名称输入、空名称提示、提交返回和取消行为不变。

## What Changes

- 将 `LocalModeSetupScreen` root 迁移到 `SettingsPage`。
- 用 `SettingsInfoRow` / `SettingsInputRow` / `SettingsAction` 或等价 settings seam 承载 subtitle、storage info、repository name 输入、confirm/cancel actions。
- 保留 `LocalModeSetupScreen.show` route、`LocalModeSetupResult`、trimmed name、empty-name snackbar、debug logging 和 existing labels。
- 更新 `settings_ui_drift_guardrail_test.dart`：将 `local_mode_setup_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- 更新 focused widget tests，覆盖 settings seam、storage info visibility、rename flow result 和 empty-name validation。

## Out of Scope

- 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters 或 version compatibility logic。
- 不修改 local library repositories、database、file paths、sync、WebDAV、local network migration、calling flows、`LogManager` behavior 或平台插件逻辑。
- 不修改 AI settings、desktop routing/window、desktop shortcut overview、shortcut editor、memo toolbar、quick QR、donation dialog、import/export flows 或 commercial/private hooks。
- 不引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、private overlay 或 `AccessDecision.source` business branching。

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `platform-adaptive-ui-system`: local mode setup settings page SHALL use settings semantic UI seams and SHALL be tracked as migrated by the settings UI drift guardrail.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/local_mode_setup_screen.dart`
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - `memos_flutter_app/test/features/settings/local_mode_setup_screen_test.dart`
- Public/private/API boundary: this is a UI-only page migration and must not edit API files, local library persistence, sync, WebDAV, private hooks, or commercial logic.
- Architecture phase: `evolve_modularity`; this change touches settings feature UI and guardrails. It must preserve existing result/caller ownership and shrink UI drift allowlists without adding lower-layer imports.
