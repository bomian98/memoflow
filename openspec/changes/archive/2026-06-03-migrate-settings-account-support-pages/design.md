## Context

`coordinate-settings-ui-migration-batches` 将第一批 runtime migration 定义为 support/general 页面。当前三个目标页面都保留了 legacy settings 样式：

- `FeedbackScreen` 直接构造 `Scaffold`、`AppBar`、本地 `_CardGroup` 和 `_ActionRow`。
- `AboutUsContent` 直接解析 `MemoFlowPalette`、本地 `_CardGroup` 和 `_AboutEntryRow`。
- `UserGeneralSettingsScreen` 直接解析 `MemoFlowPalette`、本地 `_Group` 和 `_SelectRow`。

`continue-settings-ui-unification` 已经提供 `settings_ui.dart` seam，包括 `SettingsPage`、`SettingsSection`、`SettingsNavigationRow`、`SettingsValueRow`、`SettingsInfoRow` 和 `SettingsAction`。本批应优先复用这些 seam，只在确有共享表达能力缺口时小幅扩展。

## Goals / Non-Goals

**Goals:**

- 让 `FeedbackScreen`、`AboutUsScreen`、`UserGeneralSettingsScreen` 成为 migrated settings files。
- 消除这三页的 direct `MemoFlowPalette` token、page-local grouped card geometry 和 direct `Scaffold` / app bar construction。
- 保留现有导航、外部链接、debug tap、provider/API update、haptics、错误提示和重试行为。
- 更新 drift guardrail 和 focused tests，证明本批页面已进入 settings semantic UI seam。

**Non-Goals:**

- 不迁移 account/server、安全、WebDAV、AI 或 desktop routing 页面。
- 不改 API data layer 或 API compatibility tests。
- 不把 user general 的业务写入逻辑移入 `settings_ui.dart` 或 lower-level platform seam。

## Decisions

### Decision 1: 使用现有 settings semantic seam 迁移页面 chrome 和 rows

三个页面 SHALL use `SettingsPage` for page chrome and bounded content. Row-like actions SHALL use `SettingsNavigationRow` or `SettingsValueRow`; footer/help copy SHALL use `SettingsSection.footer` or `SettingsInfoRow`.

Rationale: 这让 settings 页面之间的 page chrome、section geometry、row density 和 desktop width behavior 统一由 `settings_ui.dart` / platform seams 控制。

### Decision 2: About header 保留为 page-specific visual content

`AboutUsContent` 的 app logo、app name、version text 和 debug tap behavior 是 about page 的特定内容，可以保留在页面内，但它 MUST use `settingsPageTokens(context)` / theme-derived styling instead of direct `MemoFlowPalette` access.

Rationale: settings seam 负责通用 settings 行和页面结构；关于页 logo header 不是通用 settings row，不需要过度抽象。

### Decision 3: `UserGeneralSettingsScreen` 只做 visual/seam migration

本批不改变 locale / visibility 的 provider/API 更新流程。`UserGeneralSettingsScreen` 仍通过 existing `userGeneralSettingProvider`、`memosApiProvider` 和 `appSessionProvider` 工作；本 change 不编辑 API adapter、models 或 tests under `test/data/api`。

Rationale: 总控规则允许 support/general 页面迁移，但明确要求 API 文件触碰时暂停。视觉 seam migration 不需要改 data/API contract。

### Decision 4: Guardrail shrink 是完成条件

实现完成后，`feedback_screen.dart`、`about_us_screen.dart`、`user_general_settings_screen.dart` SHALL be removed from `legacyAllowlist` and added to `migratedFiles` in `settings_ui_drift_guardrail_test.dart`.

Rationale: 如果 guardrail 不同步缩小，本批无法防止后续页面重新引入 direct palette、page-local row styling 或 direct scaffold。

## Risks / Mitigations

- [Risk] `UserGeneralSettingsScreen` 迁移时误改 user settings 保存行为。Mitigation: 保持 provider/API 调用路径不变，并运行 existing focused settings tests。
- [Risk] About/Feedback 外部链接或 nested route 行为被改变。Mitigation: 只替换 row presentation，保留原 onTap target 和 `buildPlatformPageRoute` / `launchUrl` behavior。
- [Risk] Shared settings seam 为单页需求膨胀。Mitigation: 只添加本批三页共同需要的通用参数，例如 trailing icon 或 disabled value row。
- [Risk] 与 account/server 后续批次重叠。Mitigation: 本 change 明确不修改 `AccountSecurityScreen` 和 `ServerSettingsScreen`。

## Verification Plan

- `openspec validate migrate-settings-account-support-pages --strict`
- `flutter test test/features/settings/settings_screen_test.dart --reporter expanded`
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`
- `flutter analyze`
