## Context

`AccountSecurityScreen` 当前将账户 summary、操作列表、账户列表、本地文库列表和 warning copy 都放在 page-local cards/rows 中，并直接解析 `MemoFlowPalette`。该页面的风险在于账户切换、删除账户、本地文库扫描/重命名/删除和导航入口较多；本批只替换 presentation，不移动这些行为。

`ServerSettingsScreen` 当前使用 `PlatformPage` + page-local `_LimitSection` card。它直接使用 `MemoFlowPalette`，但 provider/API 行为已经在 `serverSettingsProvider` 和 data layer 中。由于 AGENTS 明确要求 API 相关代码需审批，本批不得编辑 API files，也不得把 version routing、response parsing、permission classification 或 merge-before-update logic 移入 UI。

## Goals / Non-Goals

**Goals:**

- 让 `AccountSecurityScreen` 和 `ServerSettingsScreen` 成为 migrated settings files。
- 消除两页的 direct `MemoFlowPalette`、direct `Scaffold`、page-local card geometry 和 duplicated row styling。
- 保留账户、本地文库、server settings provider、route target、dialog 和 snackbar 行为。
- 通过 focused tests 和 settings drift guardrail 证明迁移完成。

**Non-Goals:**

- 不改 API adapter/model/test files。
- 不迁移 security/WebDAV/AI/desktop routing 页面。
- 不重构 account/session/local library/server provider 业务逻辑。

## Decisions

### Decision 1: 账户页保留行为闭包，只迁移 presentation

`AccountSecurityScreen` 内的 `addLocalLibrary`、`renameLocalLibrary`、`removeLocalLibrary`、`removeAccountAndClearCache`、`maybeScanLocalLibrary` 和 conflict dialog flow 保持原位置和调用路径。UI 输出改用 `SettingsPage`、`SettingsSection`、`SettingsNavigationRow` 与共享 selectable row seam。

Rationale: 本批目标是 settings UI seam migration；账户和本地文库行为存在外部副作用，移动 owner 会扩大风险。

### Decision 2: Server settings 只替换 form surface，不触碰 provider/API

`ServerSettingsScreen` SHALL keep `serverSettingsProvider` reads/saves, controller sync, focus blur restore, input validation and refresh action. `_LimitSection` 可以改为 settings section composition，但不能改 provider state shape 或 API calls。

Rationale: server settings 已有 focused tests covering unavailable fields, hints, blur restore, local validation, account switch scoping and local library mode. UI seam migration 应让这些 tests 继续通过。

### Decision 3: Shared seam extensions must stay generic

如果需要扩展 `settings_ui.dart`，只添加 settings UI 通用能力，例如 input row focus/formatter 支持、profile summary、selectable item row、row actions。不得把 Account/Server-specific provider or labels 放入 shared seam。

Rationale: 当前处于 `evolve_modularity`，触碰 settings hotspot 时应改善 seam，而不是把业务逻辑藏进 shared widgets。

### Decision 4: Drift guardrail shrink is required

完成后 `account_security_screen.dart` 和 `server_settings_screen.dart` SHALL move from `legacyAllowlist` to `migratedFiles` with no new broad allowances.

Rationale: 这是防止后续 account/server pages 回退到 local scaffold/palette/card styling 的直接 guardrail。

## Risks / Mitigations

- [Risk] 账户删除/切换、本地文库扫描行为回归。Mitigation: 不改变行为闭包和 provider calls，只替换 rendering widgets。
- [Risk] Server settings form 测试对 `TextField`、hint、enabled 状态敏感。Mitigation: 保留 `PlatformTextField`/`TextField` behavior and focused widget tests。
- [Risk] API scope creep。Mitigation: 若需要编辑 `lib/data/api` 或 `test/data/api`，立即暂停。
- [Risk] Shared settings seam 过度膨胀。Mitigation: 只添加两页复用或 settings-domain通用的 presentation parameters/components。

## Verification Plan

- `openspec validate migrate-settings-account-server-pages --strict`
- `flutter test test/features/settings/settings_screen_test.dart --reporter expanded`
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`
- `flutter analyze`
