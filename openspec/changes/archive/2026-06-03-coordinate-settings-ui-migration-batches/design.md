## Context

`continue-settings-ui-unification` 已完成 Preferences、Components、Settings home、图床、图片压缩等第一批 settings UI 统一工作，`settings_ui_drift_guardrail_test.dart` 也开始用 migrated files 与 legacy allowlist 区分已迁移页面和待迁移页面。剩余 settings 页面复杂度差异很大：`FeedbackScreen`、`AboutUsScreen`、`UserGeneralSettingsScreen` 更适合做低风险视觉批次；`AccountSecurityScreen`、`ServerSettingsScreen` 涉及账户和服务配置；`PasswordLockScreen`、`VaultSecurityStatusScreen` 涉及安全体验；`WebDavSyncScreen` 体量大且有同步行为风险；AI 与 desktop settings routing 还与现有 active changes 交叠。

本 change 是总控规则，不直接修改 `memos_flutter_app/lib/features/settings` 运行时代码。它的输出是后续子 change 的分批、顺序、验证、暂停和最终验收规则。运行时代码迁移必须落在后续子 change 中，并由各自的 `proposal.md`、`design.md`、delta spec 和 `tasks.md` 承担。

当前架构阶段为 `evolve_modularity`。本 change 本身不改变 Dart dependency direction；后续子 change 如果触碰 `features/settings`、settings seam、platform seam、desktop shell 或 provider 边界，必须保持或改善 touched area 的模块化状态，不能新增 `state -> features`、`application -> features`、`core -> higher-layer` 依赖，也不能把可复用 settings/domain 逻辑继续藏进 screen-local widgets。

## Goals / Non-Goals

**Goals:**

- 建立 settings UI 后续迁移的总控批次矩阵，先探索、再拆子 change、再按顺序 apply。
- 让每个子 change 有清晰且尽量不重叠的页面范围、风险边界、验证命令和暂停条件。
- 支持“自动顺序 apply”：前一批通过 OpenSpec 校验、focused tests、settings drift guardrail、modularity guardrail 和必要 analyze 后，才继续下一批。
- 记录每个子 change 的肉眼可见变化和验证结果，最后汇总为一次性验收清单。
- 将 WebDAV、AI、desktop routing 这类高风险或交叠范围从普通视觉批次中隔离出来。

**Non-Goals:**

- 不在本 change 中迁移任何 settings 页面 UI。
- 不在本 change 中新增脚本、CLI command、Flutter dependency 或 runtime orchestration code。
- 不修改 API files、`memos_flutter_app/lib/data/api`、`memos_flutter_app/test/data/api` 或 public/private extension seams。
- 不把 AI settings、desktop settings routing、WebDAV 同步行为与低风险 settings visual cleanup 混在一个子 change。
- 不承诺无条件连续 apply；任何门禁失败或范围膨胀都必须暂停。

## Decisions

### Decision 1: 总控 change 只记录编排规则

本 change 只维护批次矩阵、顺序规则、验证门禁、暂停条件和最终验收策略。运行时代码迁移由子 change 执行。

Rationale: 总控规则与 UI 代码迁移分离后，可以让用户一次性安排后续工作，同时避免一个超大 change 同时承担规则、视觉迁移、行为回归和验收职责。

Alternatives considered:

- 单个大 change 迁移所有剩余 settings 页面。拒绝，因为 `WebDavSyncScreen`、AI、desktop routing 与普通页面风险级别不同，会扩大回归面。
- 每个页面一个 change。暂不采用，因为低风险支持页面可以共享同一套 settings seam 迁移策略，过细会增加 OpenSpec 管理成本。

### Decision 2: 子 change 按行为风险分批，而不是只按文件数量分批

建议批次为：

- `migrate-settings-support-pages`: `FeedbackScreen`、`AboutUsScreen`、`UserGeneralSettingsScreen`。
- `migrate-settings-account-server-pages`: `AccountSecurityScreen`、`ServerSettingsScreen`。
- `migrate-settings-security-pages`: `PasswordLockScreen`、`VaultSecurityStatusScreen`。
- `migrate-settings-webdav-page`: `WebDavSyncScreen` 单独探索和迁移。
- AI / desktop settings routing: 等 `route-macos-ai-settings-to-settings-pane`、`add-macos-close-to-menu-bar-setting`、`verify-desktop-platform-smoke-gaps` 等 active changes 收敛后再纳入。

Rationale: settings 页面真正的风险来自行为所有权、平台入口、同步/安全流程和现有 active changes 交叠，而不是代码行数本身。按风险分批可以让验证命令更聚焦，也让失败时的回滚和暂停边界更明确。

Alternatives considered:

- 按 settings sidebar 顺序迁移。拒绝，因为导航顺序不能反映 WebDAV、账户、安全和 desktop routing 的行为风险。
- 按文件大小迁移。部分参考，但不是主规则；`WebDavSyncScreen` 体量大需要单独处理，其他文件仍要看行为风险。

### Decision 3: 自动 apply 是有门禁的顺序队列

总控 tasks SHALL 定义子 change apply 顺序。自动继续只在以下条件都满足时发生：

- 当前子 change 的 OpenSpec artifacts 已完成并通过 `openspec validate <change> --strict`。
- 当前子 change 的待办任务已完成或明确不适用。
- 运行并记录 focused tests / guardrails，至少包括 settings drift guardrail 与相关 widget/provider tests。
- `flutter analyze` 或项目当时约定的 analyze 替代验证没有失败。
- 没有 API/public-private/commercial boundary 风险，也没有范围膨胀到 WebDAV、AI 或 desktop routing 未批准区域。

Rationale: 这满足用户“最后一起验收”的目标，但保留每批的工程闸门。自动化的对象是顺序和判断规则，不是跳过判断。

Alternatives considered:

- 编写脚本一次性执行所有 `/opsx:apply`。暂不采用，因为 OpenSpec apply 依赖当前会话上下文、用户中断和实现中发现的问题；盲跑脚本不适合含设计判断的 UI 迁移。
- 每批都等用户手动确认。暂不采用为默认，因为用户已表达希望自动顺序推进；只有门禁失败或需求不清时才暂停。

### Decision 4: 强制暂停条件优先于进度

任一子 change 出现以下情况必须暂停：

- 需求或视觉目标不清，不能从现有 Preferences / Components sibling UI 推导。
- 发现子 change artifact 与实际代码结构冲突，需要更新 proposal/design/spec/tasks。
- 需要修改 API files 或 data API tests。
- 可能引入 subscription、billing、entitlement、receipt、paywall、StoreKit、product ID、private overlay 或 `AccessDecision.source` business branching。
- `flutter analyze`、focused tests、architecture guardrails 或 OpenSpec validate 失败，且无法在当前子 change 范围内清晰修复。
- 低风险批次意外扩展到 `WebDavSyncScreen`、AI settings、desktop settings routing 或 active change 正在触碰的文件。

Rationale: settings UI 迁移表面上是视觉统一，但容易触碰账户、安全、同步、平台入口和商业边界。暂停规则比继续推进更重要。

Alternatives considered:

- 仅在编译失败时暂停。拒绝，因为边界泄漏、scope creep 和设计冲突常常早于编译失败出现。

### Decision 5: 每个子 change 都要缩小或明确 legacy allowlist

后续子 change 迁移完成后，应把对应 Dart files 从 `legacyAllowlist` 移入 `migratedFiles`，并为仍需要例外的页面记录原因。若某页尚不能迁移，应继续 allowlist 但必须在子 change 或最终验收清单中说明原因。

Rationale: `settings_ui_drift_guardrail_test.dart` 是当前最直接的 settings UI 漂移保护。迁移没有同步更新 guardrail，就无法防止后续页面重新出现 direct `Scaffold`、page-local button style、raw palette 等漂移。

Alternatives considered:

- 只做人工视觉验收。拒绝，因为 UI 统一需要自动 guardrail 保持后续不回退。

## Risks / Trade-offs

- [Risk] 总控 change 不写 runtime code，用户可能误以为它已完成 UI 改造 → Mitigation: proposal、spec 和 tasks 明确“总控只管规则”，真正迁移发生在 child changes。
- [Risk] 自动顺序 apply 可能掩盖某批次的失败 → Mitigation: 每批必须记录验证结果，失败即暂停，不能继续下一批。
- [Risk] WebDAV、AI、desktop routing 被误纳入普通视觉批次 → Mitigation: spec 与 tasks 将它们设为独立或延后范围，且作为强制暂停条件。
- [Risk] settings seam 迁移诱发 public/private 或商业逻辑泄漏 → Mitigation: 每批都检查 public shell guardrails 和 AGENTS commercial boundary，严禁新增相关 branching。
- [Risk] 子 change 数量变多带来管理成本 → Mitigation: 只为风险边界创建子 change；低风险支持页可以同批，WebDAV 与交叠 active changes 单独处理。

## Migration Plan

1. 用本 change 建立批次矩阵、子 change 顺序、门禁、暂停规则和最终验收格式。
2. 先创建并验证低风险 `migrate-settings-support-pages` artifacts。
3. 通过后继续创建并 apply `migrate-settings-account-server-pages`。
4. 再处理 `migrate-settings-security-pages`。
5. `migrate-settings-webdav-page` 必须先 dedicated exploration，再决定是否 apply。
6. AI / desktop settings routing 等现有 active changes 收敛后，再创建单独 follow-up change。
7. 每个子 change 完成后记录测试、guardrail、肉眼可见变化和剩余 allowlist。
8. 最后汇总统一验收清单，供用户集中验收。

Rollback strategy: 每个子 change 保持独立 runtime 修改范围。若某批失败，只暂停并修正该子 change，不回退已通过且不相关的前置子 change。总控规则如需调整，通过更新本 change artifacts 或创建 follow-up rule change 完成。

## Open Questions

- `UserGeneralSettingsScreen` 是否与 support pages 同批最终取决于实际代码依赖；如果迁移时发现账户状态或 server interaction 风险较高，应移到 account/server 批次。
- WebDAV 是否仅做 settings seam 视觉迁移，还是顺手拆分大文件行为逻辑，需要 dedicated exploration 决定。
- AI / desktop settings routing 何时纳入，取决于现有 active changes 的完成和归档状态。
