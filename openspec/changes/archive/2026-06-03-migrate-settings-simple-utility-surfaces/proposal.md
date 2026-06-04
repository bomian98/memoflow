## Why

`TemplateSettingsScreen` 和 `WidgetsScreen` 仍在 `settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 中，并各自持有 settings page chrome、direct `MemoFlowPalette`、rounded card/group、bare `Switch` 或 page-local action styling。两个页面的行为 owner 已分别在 `memoTemplateSettingsProvider`、模板数据模型、`HomeWidgetService` 和 package info seam 中，本 change 只迁移 settings UI surface，不修改模板存储、同步、home widget pinning、平台服务或 API 逻辑。

继续迁移这些低风险 settings surfaces 可以缩小 legacy allowlist，让模板与桌面小组件入口和已迁移 settings 页面保持同一套 page/section/row/action 语义。

## What Changes

- 将 `TemplateSettingsScreen` root 迁移到 `SettingsPage` / `SettingsSection`，并用 settings semantic rows/tokens 承载启用开关、模板列表、变量设置入口和变量说明入口。
- 保留模板新增、编辑、删除确认、变量设置 dialog 和变量说明 dialog 的现有行为，不修改 provider、model、sync 或 UID 生成逻辑。
- 将 `WidgetsScreen` root 迁移到 `SettingsPage` / `SettingsSection`，并用 settings semantic action/tokens 承载 home widget preview surfaces、添加按钮和版本 footer。
- 保留 widget preview content、`HomeWidgetService.requestPinWidget` 调用、Android gate、toast 和 package info 读取行为。
- 更新 `settings_ui_drift_guardrail_test.dart`：将 `template_settings_screen.dart` 和 `widgets_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- 增加 focused widget tests，覆盖两个页面使用 settings seam、代表性交互可打开 dialog/toast，且不触发真实 home widget pinning 或模板持久化副作用。

## Out of Scope

- 不修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters 或 version compatibility logic。
- 不修改 `memoTemplateSettingsProvider`、`MemoTemplateSettingsRepository`、`MemoTemplateSettings` model、WebDAV sync request 行为、`HomeWidgetService`、package info plugin seam、平台 pin widget 实现或 app startup widget launch 逻辑。
- 不修改 AI settings、desktop routing/window、desktop shortcut overview、import/export、migration、shortcut editor、memo toolbar、quick QR、donation dialog 或 commercial/private hooks。
- 不引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、private overlay 或 `AccessDecision.source` business branching。

## Capabilities

### New Capabilities

<!-- None. -->

### Modified Capabilities

- `platform-adaptive-ui-system`: simple utility settings surfaces SHALL use settings semantic UI seams and SHALL be tracked as migrated by the settings UI drift guardrail.

## Impact

- Affected runtime files:
  - `memos_flutter_app/lib/features/settings/template_settings_screen.dart`
  - `memos_flutter_app/lib/features/settings/widgets_screen.dart`
  - `memos_flutter_app/lib/features/settings/settings_ui.dart` only if a small shared settings row/helper is necessary
- Affected tests:
  - `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`
  - focused settings widget tests for template/widgets settings pages
- Public/private/API boundary: this is a UI-only change and must not edit API files, template repository/model/provider behavior, WebDAV sync behavior, home widget service behavior, private hooks, or commercial logic.
- Architecture phase: `evolve_modularity`; this change touches settings feature UI and guardrails. It must preserve current service/provider owners and shrink UI drift allowlists without adding lower-layer imports or new reverse dependencies.
