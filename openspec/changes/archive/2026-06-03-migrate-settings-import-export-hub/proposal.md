## Why

`ImportExportScreen` 仍在 `settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 中，并持有 settings page chrome、direct `MemoFlowPalette`、dark gradient、page-local section heading 和 import/export card-group styling。它只是 Settings -> Import / Export 的入口 hub，实际导出、导入和本地网络迁移行为分别由 `ExportMemosScreen`、`ImportSourceScreen` 和 `LocalNetworkMigrationScreen` 拥有。

本 change 只迁移入口 hub 的 settings UI surface，让它与已迁移 settings 页面保持同一套 `SettingsPage` / `SettingsSection` / semantic row 语义，同时不修改导入、导出、迁移、文件、API 或平台插件逻辑。

## What Changes

- 将 `ImportExportScreen` root 迁移到 `SettingsPage` / `SettingsSection`。
- 用 settings semantic rows/tokens 承载 Export、Import file 和 Local Network Migration 三个入口。
- 保留 haptic gate、`buildPlatformPageRoute` navigation、目标页面和现有 localized labels/value。
- 更新 `settings_ui_drift_guardrail_test.dart`：将 `import_export_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- 更新 focused widget tests，覆盖 hub 使用 settings seam 和现有导航行为。

## Out of Scope

- 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters 或 version compatibility logic。
- 不修改 `ExportMemosScreen`、`ImportSourceScreen`、`LocalNetworkMigrationScreen`、`import_export_shared_widgets.dart`、导入/导出文件处理、zip/markdown/html 转换、local network migration、WebDAV、路径、平台插件或业务服务逻辑。
- 不修改 AI settings、desktop routing/window、desktop shortcut overview、shortcut editor、memo toolbar、quick QR、donation dialog 或 commercial/private hooks。
- 不引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、private overlay 或 `AccessDecision.source` business branching。

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `platform-adaptive-ui-system`: import/export settings hub SHALL use settings semantic UI seams and SHALL be tracked as migrated by the settings UI drift guardrail.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/import_export_screen.dart`
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - `memos_flutter_app/test/features/settings/import_export_screen_test.dart`
- Public/private/API boundary: this is a UI-only hub migration and must not edit API files, import/export flow implementation, local network migration behavior, private hooks, or commercial logic.
- Architecture phase: `evolve_modularity`; this change touches settings feature UI and guardrails. It must preserve existing flow owners and shrink UI drift allowlists without adding lower-layer imports.
