## Why

`coordinate-settings-ui-migration-batches` 的默认四个 runtime 批次已经完成，但 `settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 里仍有不属于 AI、desktop routing、API、导入导出或 WebDAV 的 settings 页面。`LaboratoryScreen`、`UserGuideScreen` 和 `SettingsPlaceholderScreen` 主要承担入口、说明和占位展示职责，仍各自持有 `Scaffold`、page chrome、card geometry 和 `MemoFlowPalette` token。

本 change 继续缩小 settings legacy allowlist，同时避开当前仍 in-progress 的 AI / desktop active changes。它只迁移 reference / entry pages 的视觉 seam，不改变页面跳转、外链、haptics、package info 或弹层行为。

## What Changes

- 将 `LaboratoryScreen` 迁移到 `SettingsPage` / `SettingsSection` / `SettingsNavigationRow`，保留实验入口跳转、底部版本展示和 `showBackButton` 行为。
- 将 `UserGuideScreen` 迁移到 settings semantic UI seam，保留 usememos docs 外链、说明弹层、haptics 和 snackbar 行为。
- 将 `SettingsPlaceholderScreen` 迁移到 settings page/section seam，保留 dynamic i18n title/message lookup 和返回行为。
- 更新 `settings_ui_drift_guardrail_test.dart`：将本批三页从 `legacyAllowlist` 移到 `migratedFiles`。
- 增加 focused widget tests，覆盖本批页面的关键入口、外链/说明弹层触发点和 placeholder 文案渲染。
- 记录验证结果：`openspec validate`、focused tests、settings drift guardrail、相关 architecture guardrail 和 `flutter analyze`。

## Out of Scope

- 不修改 AI settings files、`AiSettingsScreen`、`DesktopSettingsWindowApp`、desktop routing / shortcut overview files，等待相关 active changes 收敛后另建 follow-up。
- 不修改 API files、`memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters 或 version compatibility logic。
- 不修改 import/export、local migration、WebDAV、account/server/security、大型 customization editor 或 shortcut editor flows。
- 不引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、private overlay 或 `AccessDecision.source` business branching。

## Capabilities

### Modified Capabilities

- `platform-adaptive-ui-system`: reference / entry settings pages SHALL use settings semantic UI seams and SHALL be tracked as migrated by the settings UI drift guardrail.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/laboratory_screen.dart`
  - `memos_flutter_app/lib/features/settings/user_guide_screen.dart`
  - `memos_flutter_app/lib/features/settings/placeholder_settings_screen.dart`
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - focused settings widget test file for reference pages
- Public/private boundary: this change must remain commercial-free and must not alter private extension hooks.
