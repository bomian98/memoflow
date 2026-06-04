## ADDED Requirements

### Requirement: Settings migration batches SHALL be coordinated by a control change
Settings UI 后续迁移 SHALL 先通过总控 change 记录批次矩阵、子 change 边界、顺序、验证门禁和暂停条件，再开始对应页面的 runtime implementation。

#### Scenario: Batch matrix is prepared before child implementation
- **WHEN** settings UI 后续迁移进入新的页面批次
- **THEN** 总控 change SHALL 先记录该批次的目标页面、风险级别、预期子 change 名称、验证命令和是否允许自动继续
- **AND** 子 change SHALL NOT 开始 runtime implementation，直到其边界和门禁在 OpenSpec artifacts 中清楚记录

#### Scenario: Control change does not implement settings UI runtime code
- **WHEN** 总控 change 被 apply
- **THEN** implementation SHALL 只更新 OpenSpec 编排、规则、验证记录或验收清单
- **AND** it MUST NOT 修改 `memos_flutter_app/lib/features/settings` runtime page code

#### Scenario: Child scopes are explicit
- **WHEN** 创建 settings UI migration child change
- **THEN** child proposal/design/tasks SHALL 明确列出允许触碰的 settings pages、guardrails、focused tests 和 out-of-scope pages
- **AND** WebDAV、AI、desktop settings routing SHALL NOT 被隐式纳入普通视觉批次

### Requirement: Settings migration child changes SHALL apply sequentially with validation gates
Settings UI migration child changes SHALL 按总控规则中的顺序执行；只有当前批次完成并通过验证后，才允许自动进入下一批。

#### Scenario: Automatic continuation is gated
- **WHEN** 一个 child change 完成 implementation tasks
- **THEN** 自动继续下一批 SHALL require successful OpenSpec validation, relevant focused tests, `settings_ui_drift_guardrail_test.dart`, relevant architecture guardrails, and `flutter analyze` or a documented blocker
- **AND** 验证结果 SHALL 记录在当前 child change 或总控验收记录中

#### Scenario: Apply pauses on blockers
- **WHEN** implementation reveals unclear requirements, design conflict, API file edits, public/private boundary risk, commercial leakage risk, test failure, analyze failure, guardrail failure, or unapproved scope growth
- **THEN** the apply workflow MUST pause before starting another child change
- **AND** it SHALL report the blocker, affected scope, completed tasks, and options for resolving the issue

#### Scenario: Child changes do not overlap silently
- **WHEN** two child changes might touch the same settings page, shared settings seam, provider, route, or guardrail allowlist entry
- **THEN** the total-control rules SHALL define a deterministic order or require artifact updates before either child change is applied
- **AND** overlapping runtime edits MUST NOT proceed as independent parallel implementation

### Requirement: Settings migration acceptance SHALL support final unified review
Settings UI migration SHALL collect per-batch visible changes and verification results so the user can perform a final consolidated acceptance pass after ordered child changes complete.

#### Scenario: Visible changes are recorded per child change
- **WHEN** a settings UI migration child change completes
- **THEN** it SHALL record the pages changed, user-visible UI differences, preserved behaviors, verification commands, and any pages intentionally left on the legacy allowlist

#### Scenario: Final review checklist is produced
- **WHEN** all planned child changes in the current migration wave are complete or intentionally deferred
- **THEN** the total-control workflow SHALL produce a final checklist grouped by settings area, platform/form factor risk, verification result, and remaining follow-up work
- **AND** the checklist SHALL distinguish completed pages from deferred WebDAV, AI, desktop routing, or other active-change-dependent pages

#### Scenario: Guardrail state is reviewable
- **WHEN** a migrated page is moved from legacy settings styling to the settings semantic UI seam
- **THEN** `settings_ui_drift_guardrail_test.dart` SHALL reflect the page as migrated or document an explicit temporary exception
- **AND** remaining allowlist entries SHALL stay reviewable for the next migration batch
