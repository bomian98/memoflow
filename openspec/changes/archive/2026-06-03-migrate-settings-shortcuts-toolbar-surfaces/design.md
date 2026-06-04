## Context

本批覆盖 3 个仍在 settings UI drift allowlist 中的普通 settings/editor surfaces：

- `ShortcutsSettingsScreen`: app shortcut 列表、add/edit/delete、local/server shortcut 写入选择、错误/空状态。
- `ShortcutEditorScreen`: shortcut filter editor，包含 title、match mode、tag conditions、created date conditions、visibility conditions、tag picker、date range picker 和 desktop secondary task surface。
- `MemoToolbarSettingsScreen`: memo editor toolbar toolbox、toolbar preview、drag/drop、clear/reset、custom button dialog。

这些页面都在 `features/settings` 内，但行为 owner 已经分别位于 providers、repositories、API seam、toolbar preferences model 或 existing desktop notification channel。本批只迁移 presentation layer，不移动写入逻辑，不改 filter grammar，不改 toolbar preference model。

当前架构阶段为 `evolve_modularity`。本批通过缩小 `settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 并复用 `settings_ui.dart` seam，防止 settings visual drift 回归；不新增 `state -> features`、`application -> features` 或 `core -> higher-layer` dependency。

## Goals / Non-Goals

**Goals:**

- Replace direct settings page `Scaffold`/page-local `AppBar` usage with `SettingsPage` or an approved settings page seam.
- Use `SettingsSection`, settings rows/actions/input components, theme/platform controls, or equivalent settings seams for shortcuts list, editor form groups, toolbar toolbox/preview grouped surfaces and explanatory/status rows.
- Remove direct `MemoFlowPalette`, page-local `styleFrom`, bare `Switch` / `Switch.adaptive`, and local page chrome drift from migrated runtime files where in scope.
- Preserve shortcut CRUD behavior, local/server fallback, provider invalidation, delete confirmation, haptics, toasts/snackbars, editor validation, filter parsing/building, tag/date/visibility picker behavior, toolbar drag/drop/reset/custom-button behavior and desktop preference notification.
- Move the 3 migrated files from `legacyAllowlist` to `migratedFiles` and keep focused tests green.

**Non-Goals:**

- No changes to `desktop_shortcuts_overview_screen.dart`, `desktop_settings_window_app.dart`, desktop shortcut routing/window behavior, AI settings, WebDAV, API files, migration flows or private hooks.
- No shortcut filter grammar rewrite, API route/model change, local shortcuts repository refactor, toolbar preference model change, desktop channel change, or custom icon catalog change.
- No broad decomposition of the large toolbar editor in this batch. If implementation requires behavior extraction, pause and update artifacts instead of guessing.

## Decisions

### Decision 1: Use settings seams for page chrome and high-level groups

`ShortcutsSettingsScreen`, `ShortcutEditorScreen`, and `MemoToolbarSettingsScreen` SHALL use `SettingsPage` for page chrome. Their high-level list/form/editor groups SHOULD use `SettingsSection`, settings rows/actions/input components, `settingsPageTokens`, platform controls, or equivalent seams.

Alternative considered: leave editor-heavy pages allowlisted because they include drag/drop and segmented controls. Rejected for page chrome and high-level groups because those can be migrated without changing flow behavior. Some specialized inner editor widgets may remain if they do not reintroduce blocked drift patterns.

### Decision 2: Keep shortcut and toolbar behavior owners intact

Shortcut save/delete logic, local/server fallback, filter parsing/building, tag/date picker surfaces, toolbar preference mutations, drag/drop operations and desktop preference notification SHALL remain behavior-equivalent. This batch may change how state is presented, not what state means.

Alternative considered: extract editor behavior into new services during UI migration. Rejected because it increases behavior risk and is not required to shrink settings visual drift.

### Decision 3: Defer desktop shortcut overview and desktop settings window

`desktop_shortcuts_overview_screen.dart` and `desktop_settings_window_app.dart` are still tied to desktop routing/window active changes and SHALL remain out of scope. This batch may not remove them from allowlist.

Alternative considered: migrate all shortcut-related pages together. Rejected because total-control rules classify desktop routing/overview as deferred until active desktop changes settle.

### Decision 4: Guardrail migration happens with runtime migration

After runtime migration, the 3 in-scope files SHALL move from `legacyAllowlist` to `migratedFiles`. If one file cannot be migrated within scope, implementation must pause and explain why.

Alternative considered: keep files allowlisted until every inner editor widget is redesigned. Rejected because guardrail migration should reflect the completed presentation-layer migration and block the highest-risk drift patterns.

## Risks / Trade-offs

- [Risk] `ShortcutEditorScreen` has custom segmented/tag/date UI near filter parsing. Mitigation: preserve parsing/building code and only change page/section/form wrappers unless a local widget directly violates migrated-file guardrails.
- [Risk] `MemoToolbarSettingsScreen` is large and drag/drop-heavy. Mitigation: keep drag/drop widgets and model operations intact; migrate root and grouped surfaces first.
- [Risk] Existing tests may assert specific widget geometry. Mitigation: update focused tests to assert settings seams and existing behavior keys/labels rather than old local cards.
- [Risk] Shortcut save/delete touches API seam through existing `memosApiProvider`. Mitigation: do not edit API implementation, models, adapters or tests; only preserve calls from UI.
