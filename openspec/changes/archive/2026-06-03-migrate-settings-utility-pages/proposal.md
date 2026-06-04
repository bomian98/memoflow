## Why

`ExportLogsScreen` 和 `SelfRepairScreen` 仍在 `settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 中，并各自持有本地 `Scaffold`、dark gradient、rounded card/group、direct `MemoFlowPalette`、page-local action row 和 bare `Switch` styling。两个页面的行为 owner 已在日志 providers、device preferences 和 self repair mutation service 中，本 change 只迁移 settings UI seam，不修改日志导出、维护服务、数据库、WebDAV、API 或路径解析逻辑。

继续迁移 utility/support settings 页面可以缩小 settings legacy allowlist，同时保持日志报告生成/导出/清理、network logging toggle、自助修复确认和 mutation 调用行为不变。

## What Changes

- 将 `SelfRepairScreen` root 迁移到 `SettingsPage` / `SettingsSection`，并用 settings semantic rows/tokens 承载 repair actions、running/disabled 状态和 local-only note。
- 将 `ExportLogsScreen` root 迁移到 `SettingsPage` / `SettingsSection`，并用 settings semantic rows/tokens 承载 include toggles、network logging toggle、note input、actions、last exported path 和 helper notes。
- 删除两个页面的本地 `_CardGroup`、bare `Switch`、direct `MemoFlowPalette` 和 page-local scaffold/card visual drift。
- 保留 confirmation dialogs、snackbar/toast、clipboard copy、haptic gate、path resolution、file writing、log bundle export、log clearing 和 service calls 的现有 owner。
- 更新 `settings_ui_drift_guardrail_test.dart`：将 `export_logs_screen.dart` 和 `self_repair_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- 增加或更新 focused widget tests，覆盖两个页面使用 settings seam、toggle/action UI 可交互、确认 dialog 可打开，且不会触发真实导出或修复操作。

## Out of Scope

- 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters 或 version compatibility logic。
- 不修改 `logReportGeneratorProvider`、`logBundleExporterProvider`、`debugLogStoreProvider`、`webDavLogStoreProvider`、`networkLogStoreProvider`、`selfRepairMutationServiceProvider`、数据库 repair service、文件路径解析、日志 sanitization 或 WebDAV sync behavior。
- 不修改 AI settings、desktop routing/window、desktop shortcut overview、import/export、migration、shortcut editor、memo toolbar、quick QR、donation dialog 或 commercial/private hooks。
- 不引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、private overlay 或 `AccessDecision.source` business branching。

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `platform-adaptive-ui-system`: utility/support settings pages SHALL use settings semantic UI seams and SHALL be tracked as migrated by the settings UI drift guardrail.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/export_logs_screen.dart`
  - `memos_flutter_app/lib/features/settings/self_repair_screen.dart`
  - `memos_flutter_app/lib/features/settings/settings_ui.dart` if a small shared settings row/helper is needed
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - focused settings widget tests for utility/support settings pages
- Public/private/API boundary: this is a UI-only change and must not edit API files, database repair logic, log/report providers, WebDAV behavior, private hooks, or commercial logic.
- Architecture phase: `evolve_modularity`; this change touches settings feature UI and guardrails. `SelfRepairScreen` references a stable mutation service owner and is already protected by modularity guardrails; this batch must preserve that owner and shrink UI drift allowlists without adding lower-layer imports.
