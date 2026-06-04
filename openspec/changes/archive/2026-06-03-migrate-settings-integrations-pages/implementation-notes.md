## 实现摘要

- `ApiPluginsScreen` 已迁移到 `SettingsPage` / `SettingsSection`，token 创建表单、expiration row、existing token 状态、empty/loading/error/footer helper text 通过 settings seam 和 theme tokens 渲染。
- `WebhooksSettingsScreen` 已迁移到 `SettingsPage` / `SettingsSection`，webhook loaded/empty/loading/error rows 和 edit/delete actions 通过 settings seam 渲染。
- `SettingsPage` 新增可选 `onRefresh`，用于让 settings 页面在 shared page seam 内保留 pull-to-refresh 行为。
- `settings_ui_drift_guardrail_test.dart` 已将 `api_plugins_screen.dart` 和 `webhooks_settings_screen.dart` 从 `legacyAllowlist` 移入 `migratedFiles`。
- 新增 `test/features/settings/integrations_settings_pages_test.dart`，覆盖 API plugins seam/unsigned guard、webhooks loaded rows、empty row 和 error row。

## 保留行为

- Personal access token 的 list/create/save/read/copy、one-time token sheet、form validation、current-account guard、toast/snackbar 和 refresh 行为仍由现有 screen/provider/API/repository path 执行。
- Webhook 的 add/edit/delete dialog、API calls、`userWebhooksProvider` invalidation、haptic gate、toast/snackbar 和 unsupported-server error mapping 保持原 owner 和行为。
- 未修改 `memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api`、request/response models、route adapters、version compatibility logic、repositories、providers、private hooks 或 commercial logic。

## 验证

- `openspec validate migrate-settings-integrations-pages --strict`
- `flutter test test/features/settings/integrations_settings_pages_test.dart --reporter expanded`
- `flutter test test/architecture/settings_ui_drift_guardrail_test.dart --reporter expanded`
- `flutter test test/architecture/modularity_dependency_guardrail_test.dart --reporter expanded`
- `flutter analyze`

## 剩余风险

- 本批只做 integrations settings UI seam migration；AI settings、desktop routing/window、import/export、migration、shortcut editor 和 memo toolbar 仍在后续批次范围。
- API plugins 的 focused test 覆盖未登录 guard 和 UI seam，不 mock concrete `MemosApi` 的 token API 成功路径，以避免为了测试改动 API owner。
