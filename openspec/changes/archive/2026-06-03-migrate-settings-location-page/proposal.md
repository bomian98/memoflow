## Why

`LocationSettingsScreen` 仍在 `settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 中，并持有本地 `PlatformPage`、dark gradient、rounded card/group、`_ToggleCard`、direct `MemoFlowPalette` 和 page-local input/menu/chip styling。该页面的业务 owner 已在 `locationSettingsProvider` 和 `LocationSettings` model 中，本 change 只迁移 UI seam，不修改 provider、repository、data model、location adapter 或 API 相关代码。

继续迁移该单页可以缩小 settings legacy allowlist，同时保持 location provider selection、API key inputs、precision selection 和 enabled toggle 的写入行为不变。

## What Changes

- 将 `LocationSettingsScreen` root 迁移到 `SettingsPage` / `SettingsSection`。
- 将 enable location UI 迁移到 `SettingsToggleRow`。
- 将 provider picker、API key inputs 和 precision selector 改为 settings semantic rows / settings tokens。
- 删除本地 `_Group` 和 `_ToggleCard`，移除 direct `MemoFlowPalette` 使用。
- 更新 `settings_ui_drift_guardrail_test.dart`：将 `location_settings_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- 增加或更新 focused widget tests，覆盖 enabled toggle、provider switch/input rows 和 precision write 行为。

## Out of Scope

- 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters 或 version compatibility logic。
- 不修改 `locationSettingsProvider`、`LocationSettings` model、repository、location adapters、permission logic、geocoder behavior 或 WebDAV sync/backup config transfer。
- 不修改 AI settings、desktop routing、import/export、migration、shortcut editor、memo toolbar 或 commercial/private hooks。
- 不引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、private overlay 或 `AccessDecision.source` business branching。

## Capabilities

### Modified Capabilities

- `platform-adaptive-ui-system`: location settings page SHALL use settings semantic UI seams and SHALL be tracked as migrated by the settings UI drift guardrail.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/location_settings_screen.dart`
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - focused settings widget test for `LocationSettingsScreen`
- Public/private/API boundary: this is a UI-only change and must not edit API files, location data models, repositories, provider behavior, private hooks, or commercial logic.
