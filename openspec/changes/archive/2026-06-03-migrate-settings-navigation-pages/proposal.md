## Why

前序 settings UI migration 批次已经完成 support/general、account/server、security、WebDAV 和 reference / entry pages。`settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 里仍有一组 navigation / home customization settings 页面：`NavigationModeScreen`、`BottomNavigationModeSettingsScreen`、`CustomizeDrawerScreen` 和 `CustomizeHomeShortcutsScreen`。这些页面仍各自持有 `Scaffold`、page chrome、section/card geometry、`MemoFlowPalette` token 和局部 switch/radio styling。

这组页面 ownership 清晰，行为主要是读写 `currentWorkspacePreferencesProvider` 和 session availability，不涉及 API adapters、private hooks、AI routing 或 desktop window ownership。将它们迁移到 settings semantic UI seam 可以继续缩小 legacy allowlist，同时保持导航模式、底部导航 slot、drawer 可见项和首页快捷入口行为不变。

## What Changes

- 将 `NavigationModeScreen` 迁移到 `SettingsPage` / `SettingsSection` / semantic rows，保留 classic/bottom bar 选择、bottom settings 独立入口和现有 test keys。
- 将 `BottomNavigationModeSettingsScreen` 迁移到 settings page/section seam，保留 preview、slot picker dialog、center action fixed row、unavailable destination filtering 和 duplicate destination disabling。
- 将 `CustomizeDrawerScreen` 迁移到 `SettingsPage` / `SettingsSection` / `SettingsToggleRow`，保留每个 drawer visibility setter。
- 将 `CustomizeHomeShortcutsScreen` 迁移到 settings page/section seam，保留三个 slot、picker dialog、local-only / signed-in options、used action disabled state 和 provider writes。
- 更新 `settings_ui_drift_guardrail_test.dart`：将本批四页从 `legacyAllowlist` 移到 `migratedFiles`，不新增宽泛 allowance。
- 运行并记录 focused navigation / settings tests、settings drift guardrail、modularity guardrail 和 `flutter analyze`。

## Out of Scope

- 不修改 AI settings files、`AiSettingsScreen`、`DesktopSettingsWindowApp`、desktop routing / shortcut overview files。
- 不修改 API files、`memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters 或 version compatibility logic。
- 不修改 import/export、migration、WebDAV、account/server/security、self-repair、webhooks/API plugins、shortcut editor 或 memo toolbar customization flows。
- 不引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、private overlay 或 `AccessDecision.source` business branching。

## Capabilities

### Modified Capabilities

- `platform-adaptive-ui-system`: navigation and home customization settings pages SHALL use settings semantic UI seams and SHALL be tracked as migrated by the settings UI drift guardrail.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/navigation_mode_screen.dart`
  - `memos_flutter_app/lib/features/settings/bottom_navigation_mode_settings_screen.dart`
  - `memos_flutter_app/lib/features/settings/customize_drawer_screen.dart`
  - `memos_flutter_app/lib/features/settings/customize_home_shortcuts_screen.dart`
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - `memos_flutter_app/test/features/settings/navigation_mode_screen_test.dart`
  - `memos_flutter_app/test/features/settings/settings_screen_test.dart`
- Public/private boundary: this change must remain commercial-free and must not alter private extension hooks.
