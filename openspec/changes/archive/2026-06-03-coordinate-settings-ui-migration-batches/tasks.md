## 1. 当前状态盘点

- [x] 1.1 重新运行 `openspec list --json`，记录 settings UI migration 相关 active changes，确认 AI、desktop routing、平台 smoke gaps 不与本轮普通 settings visual 批次混用。
- [x] 1.2 检查 `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`，记录当前 `legacyAllowlist` 与 `migratedFiles` 中和 settings UI 后续迁移相关的页面。
- [x] 1.3 核对本总控 change 的 git diff，确认只修改 `openspec/changes/coordinate-settings-ui-migration-batches/` 下的 OpenSpec artifacts，不修改 runtime Dart code。

## 2. 批次矩阵与子 change 边界

- [x] 2.1 为 `migrate-settings-support-pages` 记录允许范围、风险、门禁和 out-of-scope pages，默认覆盖 `FeedbackScreen`、`AboutUsScreen`、`UserGeneralSettingsScreen`。
- [x] 2.2 为 `migrate-settings-account-server-pages` 记录允许范围、风险、门禁和 out-of-scope pages，默认覆盖 `AccountSecurityScreen`、`ServerSettingsScreen`。
- [x] 2.3 为 `migrate-settings-security-pages` 记录允许范围、风险、门禁和 out-of-scope pages，默认覆盖 `PasswordLockScreen`、`VaultSecurityStatusScreen`。
- [x] 2.4 为 `migrate-settings-webdav-page` 记录 dedicated exploration 要求，确认 `WebDavSyncScreen` 不进入普通视觉批次。
- [x] 2.5 记录 AI / desktop settings routing deferred 规则，等待 `route-macos-ai-settings-to-settings-pane`、`add-macos-close-to-menu-bar-setting`、`verify-desktop-platform-smoke-gaps` 等相关 active changes 收敛后再创建 follow-up。

## 3. 自动顺序 apply 规则

- [x] 3.1 固化默认顺序：support pages → account/server pages → security pages → WebDAV dedicated page；AI / desktop routing 单独 follow-up。
- [x] 3.2 为每个 child change 定义继续下一批前必须通过的门禁：`openspec validate <child> --strict`、focused tests、`settings_ui_drift_guardrail_test.dart`、relevant architecture guardrails、`flutter analyze` 或记录明确 blocker。
- [x] 3.3 定义强制暂停条件：需求不清、设计冲突、API 文件触碰、public/private boundary 风险、commercial leakage 风险、test/analyze/guardrail 失败、scope creep、child runtime edit overlap。
- [x] 3.4 明确自动 apply 不允许并行修改重叠 runtime files；若两个 child changes 需要同一 settings seam、route、provider 或 guardrail allowlist entry，必须先更新 artifacts 再继续。

## 4. 验收与 guardrail 记录

- [x] 4.1 准备最终统一验收清单格式，按 settings area 记录页面、肉眼可见变化、保留行为、平台/窗口风险、验证命令和结果。
- [x] 4.2 定义每个 child change 完成后如何更新或解释 `settings_ui_drift_guardrail_test.dart` 的 `legacyAllowlist` 与 `migratedFiles`。
- [x] 4.3 记录剩余 legacy pages、deferred pages 和 follow-up changes，确保最后集中验收时能区分已完成、延期和阻塞项。

## 5. 验证

- [x] 5.1 运行 `openspec validate coordinate-settings-ui-migration-batches --strict`。
- [x] 5.2 运行 `openspec status --change "coordinate-settings-ui-migration-batches"`，确认 artifacts 完整且 apply-ready。
- [x] 5.3 记录本 change 未修改 runtime code，因此不要求运行 Flutter tests；若 apply 阶段创建了 child changes，则分别运行对应 `openspec validate <child> --strict`。
