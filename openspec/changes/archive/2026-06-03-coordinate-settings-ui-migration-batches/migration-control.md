## Settings UI Migration Control Record

本文档是 `coordinate-settings-ui-migration-batches` apply 阶段的总控记录。它只记录后续 settings UI migration 的批次、门禁、暂停条件和验收格式，不修改 runtime Dart code。

## 1. 当前状态盘点

### OpenSpec active changes snapshot

基于 `openspec list --json`：

- `coordinate-settings-ui-migration-batches`: 当前总控 change，`0/18` tasks complete 时开始 apply。
- `migrate-settings-account-support-pages`: 只有 `.openspec.yaml` 的空 scaffold，`0/0` tasks；本轮不把它视为可执行子 change，后续需要重新补齐 artifacts 或另建规范命名的 child change。
- `continue-settings-ui-unification`: `33/33` complete，已完成 Preferences、Components、Settings home、图床、图片压缩等先行批次。
- `add-macos-close-to-menu-bar-setting`: `16/17` in-progress；涉及 macOS desktop setting，普通 settings visual 批次不得混入。
- `route-macos-ai-settings-to-settings-pane`: `18/19` in-progress；涉及 AI settings routing，普通 settings visual 批次不得混入。
- `verify-desktop-platform-smoke-gaps`: `5/36` in-progress；涉及 desktop smoke gaps，普通 settings visual 批次不得混入。
- `generalize-desktop-settings-platform-sections`: `19/19` complete，但仍建议等相关 desktop follow-up 收敛后再纳入 AI / desktop routing 迁移。
- `add-ai-summary-history`、RSS 相关 changes 与本轮 settings visual migration 无直接关系，不纳入总控批次。

### Settings UI drift guardrail snapshot

基于 `memos_flutter_app/test/architecture/settings_ui_drift_guardrail_test.dart`：

- 当前 `migratedFiles` 已包含：
  - `components_settings_screen.dart`
  - `desktop_settings_screen.dart`
  - `desktop_shortcuts_settings_screen.dart`
  - `image_bed_settings_screen.dart`
  - `image_compression_settings_screen.dart`
  - `preferences_settings_screen.dart`
  - `settings_screen.dart`
  - `settings_ui.dart`
- 后续批次相关 `legacyAllowlist` 条目包括：
  - support/general: `feedback_screen.dart`、`about_us_screen.dart`、`user_general_settings_screen.dart`
  - account/server: `account_security_screen.dart`、`server_settings_screen.dart`
  - security: `password_lock_screen.dart`、`vault_security_status_screen.dart`
  - dedicated large flow: `webdav_sync_screen.dart`
  - deferred AI/desktop/routing: `ai_settings_screen.dart`、AI provider/route/service/profile files、`desktop_settings_window_app.dart`、desktop shortcuts overview 等
- Drift rules currently block direct `Scaffold`, private `_ToggleCard`, bare `Switch` / `Switch.adaptive`, page-local `styleFrom`, and direct `MemoFlowPalette` usage in migrated files, with narrow allowances only for `settings_ui.dart` and `preferences_settings_screen.dart`.

### Scope verification

- 本总控 apply 的写入范围限制为 `openspec/changes/coordinate-settings-ui-migration-batches/`。
- 当前 worktree 已存在此前 settings UI 迁移留下的 runtime Dart/test modifications；这些不是本总控 change 新增的 runtime edits。
- 本 change 不编辑 `memos_flutter_app/lib/features/settings` runtime pages，不编辑 API files，不编辑 public/private extension seams。

## 2. 批次矩阵与子 change 边界

| Order | Child change | Allowed pages | Risk | Must stay out of scope | Continue gate |
| --- | --- | --- | --- | --- | --- |
| 1 | `migrate-settings-support-pages` | `FeedbackScreen` (`feedback_screen.dart`, 284 lines), `AboutUsScreen` (`about_us_screen.dart`, 387 lines), `UserGeneralSettingsScreen` (`user_general_settings_screen.dart`, 424 lines) | Low to medium. 主要是 visual/seam migration，`UserGeneralSettingsScreen` 如发现账户状态写入风险则移出本批 | WebDAV、AI settings、desktop routing、API files、commercial/private hooks | OpenSpec artifacts 完整；focused widget tests；`settings_ui_drift_guardrail_test.dart`；relevant architecture guardrail；`flutter analyze` |
| 2 | `migrate-settings-account-server-pages` | `AccountSecurityScreen` (`account_security_screen.dart`, 866 lines), `ServerSettingsScreen` (`server_settings_screen.dart`, 521 lines) | Medium. 涉及账户安全、server config、可能有 provider/route 行为 | API adapter/model/test files，付费或 private capability checks，WebDAV sync behavior | OpenSpec artifacts 完整；账户/server focused tests；settings drift guardrail；modularity guardrail；`flutter analyze` |
| 3 | `migrate-settings-security-pages` | `PasswordLockScreen` (`password_lock_screen.dart`, 472 lines), `VaultSecurityStatusScreen` (`vault_security_status_screen.dart`, 798 lines) | Medium to high. 涉及安全状态、锁定体验、危险操作确认 | 账户/server 批次未批准范围，WebDAV sync behavior，public/private commercial logic | OpenSpec artifacts 完整；security focused tests；settings drift guardrail；modularity guardrail；`flutter analyze` |
| 4 | `migrate-settings-webdav-page` | `WebDavSyncScreen` (`webdav_sync_screen.dart`, 4056 lines) | High. 大文件、同步流程、导入/备份行为、错误状态和连接验证风险 | 普通 visual cleanup 批次、AI/desktop routing、API changes unless explicitly approved | Dedicated exploration 完成；决定是否先拆 seam 或行为 owner；focused WebDAV tests；settings drift guardrail；`flutter analyze` |
| Deferred | AI / desktop settings routing follow-up | AI provider/route/service/profile settings files, `AiSettingsScreen`, `DesktopSettingsWindowApp`, desktop shortcut overview/routing files | High or actively changing. 当前与 existing active changes 交叠 | 本轮 support/account/security/WebDAV child changes | 等 `route-macos-ai-settings-to-settings-pane`、`add-macos-close-to-menu-bar-setting`、`verify-desktop-platform-smoke-gaps` 等收敛后另建 follow-up |

### Child change naming note

已有 `migrate-settings-account-support-pages` 目前只有 `.openspec.yaml`，没有 `proposal.md`、`design.md`、delta spec 或 `tasks.md`。后续不直接 apply 这个空 scaffold；应按矩阵补齐为明确范围的 child change，或用更清晰的 `migrate-settings-support-pages` / `migrate-settings-account-server-pages` 拆分替代。

### Dedicated exploration requirement for WebDAV

`WebDavSyncScreen` 必须先探索再建 implementation tasks。探索至少回答：

- 哪些 UI 片段只是 settings seam 迁移，哪些逻辑应留在现有 provider/service owner。
- 是否需要先抽出 presentation-only helpers，避免把同步/导入/备份行为进一步塞进 screen-local widgets。
- 哪些 focused tests 已存在，哪些需要补。
- 哪些失败必须暂停，例如连接验证、备份导入、错误提示、权限/路径处理或同步状态回归。

### AI / desktop deferred rule

AI settings 与 desktop settings routing 只有在相关 active changes 完成或明确暂停后才纳入下一批。任何普通 visual child change 如果需要触碰 AI provider/route/service files、`DesktopSettingsWindowApp`、desktop routing 或 platform smoke gaps，必须暂停并更新 artifacts。

## 3. 自动顺序 apply 规则

### Default queue

默认执行队列：

```text
1. explore + propose + apply migrate-settings-support-pages
2. explore + propose + apply migrate-settings-account-server-pages
3. explore + propose + apply migrate-settings-security-pages
4. explore + propose + apply migrate-settings-webdav-page
5. propose/apply AI or desktop routing follow-up only after active changes settle
```

总控 change 不并行 apply child changes。只有当前 child change 完成并通过门禁，才进入下一项。

### Per-child continue gate

每个 child change 进入下一批前必须满足：

- `openspec validate <child> --strict` 通过。
- `openspec status --change "<child>"` 显示 tasks complete，或明确记录不适用的 task。
- 已读取 child change 的 apply `contextFiles`。
- 已运行并记录 relevant focused tests。
- 已运行并记录 `flutter test test/architecture/settings_ui_drift_guardrail_test.dart`。
- 触碰 dependency boundary、settings seam、desktop shell、provider 或 lower-layer 文件时，已运行并记录 relevant architecture guardrails，至少考虑 `modularity_dependency_guardrail_test.dart`。
- 已运行 `flutter analyze`；若环境 blocker 导致无法运行，必须记录 blocker、影响和下一步。
- 已检查没有 API files、public/private extension seams、commercial logic 或 `AccessDecision.source` business branching。
- 已记录肉眼可见变化、保留行为和剩余风险。

### Mandatory pause conditions

以下情况必须暂停，不得进入下一 child change：

- 需求、视觉目标或与 Preferences / Components sibling UI 的对应关系不清。
- 发现 child artifacts 与代码实际结构冲突，需要更新 `proposal.md`、`design.md`、delta spec 或 `tasks.md`。
- 需要修改 `memos_flutter_app/lib/data/api` 或 `memos_flutter_app/test/data/api`。
- 可能引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、private overlay、private release automation 或 `AccessDecision.source` business branching。
- `openspec validate`、focused tests、settings drift guardrail、architecture guardrail 或 `flutter analyze` 失败，且无法在当前 child scope 内清晰修复。
- 当前 child change 需要触碰未授权的 WebDAV、AI、desktop routing 或 active-change-owned files。
- 两个 child changes 需要同时改同一 settings seam、route、provider、shared widget、guardrail allowlist entry 或 runtime page。

### Overlap handling

若发现 child changes 之间有文件或行为重叠：

1. 停止当前自动队列。
2. 更新总控记录和受影响 child artifacts，明确 owner 和顺序。
3. 优先让 earlier child 提供 seam 或 guardrail，再让 later child 使用该 seam。
4. 不做并行 runtime edits；不在一个 child 中顺手完成另一个 child 的页面迁移。

## 4. 验收与 guardrail 记录

### Final acceptance checklist template

每个 child change 完成后追加一条验收记录，最终集中验收按下列格式汇总：

| Area | Pages | Visible changes | Preserved behavior | Platforms / form factors to spot-check | Verification | Result | Follow-up |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Support / General | `FeedbackScreen`, `AboutUsScreen`, `UserGeneralSettingsScreen` | 使用 settings semantic rows/sections/page chrome；与 Preferences / Components 视觉成为 sibling | 反馈入口、关于页信息、用户通用设置读写不变 | iPhone/narrow, tablet, macOS/Windows desktop width | child focused tests, settings drift guardrail, analyze | TBD | 若 `UserGeneralSettingsScreen` 行为风险升高则移到 account/server |
| Account / Server | `AccountSecurityScreen`, `ServerSettingsScreen` | 账户和服务配置表单使用统一 settings UI seam | 登录/安全操作、server URL/config 行为不变 | mobile + desktop regular window | focused account/server tests, guardrails, analyze | TBD | API files 需要修改时暂停 |
| Security | `PasswordLockScreen`, `VaultSecurityStatusScreen` | 安全状态、危险操作、开关/行/按钮视觉统一 | 密码锁、vault 状态、确认/危险操作语义不变 | mobile + desktop, dark mode | focused security tests, guardrails, analyze | TBD | 如触碰 auth/security owner 则补 design |
| WebDAV | `WebDavSyncScreen` | 仅在 dedicated exploration 后决定迁移粒度 | 同步、备份、导入、连接验证、错误状态不变 | mobile + desktop, slow/error states | WebDAV focused tests, guardrails, analyze | Deferred | 单独 child change |
| AI / Desktop routing | AI settings files, `DesktopSettingsWindowApp`, routing files | 暂不纳入本轮普通 visual cleanup | 现有 active changes 收敛前不改 | desktop/macOS specific | follow-up validate/tests | Deferred | 单独 follow-up |

### Guardrail update rule

每个 child change 完成时必须处理 `settings_ui_drift_guardrail_test.dart`：

- 已完成 settings seam migration 的 files 从 `legacyAllowlist` 移到 `migratedFiles`。
- 如果某个已迁移 file 仍需要 direct palette、page-local button style 或类似例外，必须在 `_allowancesFor` 中记录窄范围 allowance，并在 child change 验收记录说明原因。
- 如果页面无法迁移，保留在 `legacyAllowlist`，但必须在 child change 或最终验收清单写明 blocker 和 follow-up change。
- 新增 settings Dart file 必须立即进入 `migratedFiles` 或 `legacyAllowlist`，不能让 uncovered files 靠失败测试才发现。

### Remaining/deferred record

最终集中验收必须分三类列出页面：

- Completed: 已迁移并进入 `migratedFiles`，验证已记录。
- Deferred: WebDAV、AI、desktop routing 或 active-change-dependent pages，已有 follow-up 规则。
- Blocked: 因需求、测试、API/public-private boundary、商业边界、设计冲突或环境问题暂停的页面。

当前 deferred baseline：

- `WebDavSyncScreen`: dedicated exploration 后再 apply。
- AI provider/route/service/profile settings files and `AiSettingsScreen`: 等 AI routing active change 收敛。
- `DesktopSettingsWindowApp` and desktop routing/shortcut overview files: 等 desktop settings / platform smoke gaps active changes 收敛。

## 5. 验证记录

- `openspec validate coordinate-settings-ui-migration-batches --strict`: passed，输出 `Change 'coordinate-settings-ui-migration-batches' is valid`。
- `openspec status --change "coordinate-settings-ui-migration-batches"`: passed，输出 `Progress: 4/4 artifacts complete`，`proposal`、`design`、`specs`、`tasks` 均 complete。
- Flutter tests: not run for this total-control apply，因为本 change 只新增/更新 OpenSpec orchestration artifacts，没有修改 runtime Dart code。后续 child changes 如果修改 settings runtime code，必须按各自门禁运行 focused tests、settings drift guardrail、relevant architecture guardrails 和 `flutter analyze`。
