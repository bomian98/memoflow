## Why

`PreferencesSettingsScreen`、`ComponentsSettingsScreen` 和桌面设置页已经迁移到 settings semantic UI seam，但设置首页以及 Components 下一级的图床、图片压缩页面仍保留 page-local `Scaffold`、palette、card、row、switch 和按钮样式。用户在“设置 -> 组件 -> 详情页”之间连续操作时会明显感到 UI 系统割裂，需要继续收缩 legacy settings UI drift。

项目当前处于 `evolve_modularity` 阶段。本变更触及 `features/settings` 这一耦合热点，主要影响模块化清单中的 4（共享 UI 逻辑不应继续藏在 screen-local widgets）、6（设置页应通过 settings UI seam 协作）、8（guardrail 防止视觉漂移回归）和 10（触及区域必须保持结构不变或更好）。

## What Changes

- 将 `SettingsScreen` 进一步迁移到现有 `SettingsPage` / `SettingsSection` / settings row seams，使设置首页入口、分组、图标、profile entry 和快捷入口使用统一 settings 语义，而不是继续维护私有 `_CardGroup`、`_SettingRow`、`_ProfileCard`、`_ShortcutTile` 视觉系统。
- 将 `ImageBedSettingsScreen` 迁移到 settings semantic components，保留现有 provider、输入、选择、stepper、重试、保存和 URL normalization 行为。
- 将 `ImageCompressionSettingsScreen` 迁移到 settings semantic components，保留现有压缩模式、输出格式、lossless、metadata、resize、质量、尺寸和 skip 规则行为。
- 必要时小幅扩展 `settings_ui.dart`，补齐本批迁移真实需要的 settings-owned row/action seam，例如 input row、select/menu row、stepper row、warning/info row；避免把图床或图片压缩的私有视觉组件复制到其他页面。
- 收紧 `settings_ui_drift_guardrail_test.dart`，将本批迁移完成的页面移出 legacy allowlist 并加入 migrated coverage。
- 补充 focused widget tests，覆盖设置首页视觉 seam、图床/图片压缩关键行为和 migrated pages 不再引入裸 `Scaffold` / `Switch` / `MemoFlowPalette` 漂移。
- 不在本 change 中迁移 `WebDavSyncScreen`、`AiSettingsScreen`、`PasswordLockScreen` 或所有其他 settings 子页；这些页面复杂度和风险更高，后续单独分批处理。
- 不改变设置项业务语义、provider owner、持久化模型、API 行为、桌面设置窗口路由、AI 菜单路由或 public/private 边界。

## Capabilities

### New Capabilities

- 无。本变更延续现有 settings UI semantic seam，不引入独立的新产品能力。

### Modified Capabilities

- `platform-adaptive-ui-system`: 补充后续 settings UI 迁移批次要求，明确 `SettingsScreen`、`ImageBedSettingsScreen` 和 `ImageCompressionSettingsScreen` 应迁移到 settings semantic components，并通过 guardrail 收缩 legacy allowlist。

## Impact

- Affected app files: `memos_flutter_app/lib/features/settings/settings_screen.dart`、`image_bed_settings_screen.dart`、`image_compression_settings_screen.dart`、`settings_ui.dart`。
- Affected tests/guardrails: `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`、`memos_flutter_app/test/features/settings/platform_adaptive_settings_test.dart`、`settings_screen_test.dart`，以及新增或更新的图床/图片压缩 focused widget tests。
- Affected OpenSpec: `openspec/specs/platform-adaptive-ui-system/spec.md` delta。
- Dependencies: 不新增第三方依赖，不触碰 `memos_flutter_app/lib/data/api` 或 `memos_flutter_app/test/data/api`。
- Public/private boundary: 不引入 subscription、billing、entitlement、StoreKit、receipt、paywall、product ID、private overlay 或 `AccessDecision.source` business branching。
