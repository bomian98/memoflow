## Context

前四个 settings UI migration child changes 已把 support/general、account/server、security 和 WebDAV 批次迁入 settings semantic seam。guardrail 仍保留一批 legacy settings files，其中 AI / desktop routing 受 active changes 保护，import/export、migration、shortcut editor 和 toolbar customization 等页面行为更重，不适合作为紧随 WebDAV 后的低风险批次。

`LaboratoryScreen`、`UserGuideScreen` 和 `SettingsPlaceholderScreen` 是下一批较小、ownership 清晰的页面：它们不写 API 层、不持有 private hooks，不需要改变 provider ownership，只需要把 page chrome、section/card 和 row geometry 交给 `settings_ui.dart`。

## Decisions

- 本批只迁移三个 reference / entry pages，命名为 `migrate-settings-reference-pages`，不扩展到实验室入口指向的子页面。
- `LaboratoryScreen` 使用 `SettingsPage` 和单个 `SettingsSection` 表达入口列表，保留 `PackageInfo.fromPlatform()` future 和底部版本展示。
- `UserGuideScreen` 使用 `SettingsPage`、`SettingsSection`、`SettingsNavigationRow` 和 `settingsPageTokens`，保留 `_openBackendDocs`、`_showInfo`、haptics 和原 snackbar 文案。
- `SettingsPlaceholderScreen` 使用 `SettingsPage` + `SettingsSection` / semantic row 表达占位说明，保留 legacy string key lookup。
- 如果三页只需要现有 settings seam，则不修改 `settings_ui.dart`；避免为一次性视觉细节扩展 shared seam。

## Risks

- `UserGuideScreen` 依赖 bottom sheet / Windows adaptive surface；迁移时必须只替换 page/list row chrome，不改 `_showInfo` 的 surface 选择。
- `LaboratoryScreen` 底部版本展示不是普通 row；需要使用 settings tokens 但可保留 page-local identity block，因为它是页面内容而非重复 settings seam。
- `SettingsPlaceholderScreen` 使用 dynamic i18n map lookup；测试需要选用现有 key，不能新增文案或猜测缺失 key。

## Alternatives

- 直接迁移 AI / desktop：被总控 deferred rule 阻止，因为 `route-macos-ai-settings-to-settings-pane`、`add-macos-close-to-menu-bar-setting` 和 `verify-desktop-platform-smoke-gaps` 仍未完全收敛。
- 迁移 import/export 或 shortcut editor：这些页面行为和文件体量更大，适合作为后续 dedicated batch，而不是在 WebDAV 之后立即混入。
