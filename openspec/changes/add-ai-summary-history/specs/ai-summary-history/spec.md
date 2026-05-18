## ADDED Requirements

### Requirement: AI summary history persistence
系统 SHALL 将已完成的 AI summary 或 AI insight 结果保存为本地 AI summary history records。

#### Scenario: Successful summary is saved
- **WHEN** 用户成功完成一次 AI summary 或 insight run
- **THEN** 系统 SHALL 创建一条 history record，并保存生成出的结果内容
- **AND** 该记录 SHALL 包含足够的展示元数据，用于识别 template、source scope、created time 和 summary preview

#### Scenario: Failed or cancelled summary is not saved as completed history
- **WHEN** AI summary run 失败、被取消，或没有产生可用结果
- **THEN** 系统 SHALL NOT 创建 completed summary history record

#### Scenario: Template metadata changes after history creation
- **WHEN** history record 创建后，custom 或 built-in template 被重命名、编辑、隐藏或删除
- **THEN** history record SHALL 继续使用生成时保存的 snapshot metadata 保持可读

### Requirement: AI summary history browsing
系统 SHALL 提供面向用户的历史体验，用于浏览已保存的 AI summary results。

#### Scenario: User opens history list
- **WHEN** 用户从 AI summary surface 打开 AI summary history
- **THEN** 系统 SHALL 按 created time 倒序展示已保存的 history records
- **AND** 每一行 SHALL 展示 created time、template title 或 fallback label、source scope 或 fallback label，以及 result preview

#### Scenario: User opens history detail
- **WHEN** 用户选择一条 history record
- **THEN** 系统 SHALL 展示保存的 result content 和 captured metadata
- **AND** 用户 SHALL 能删除该记录

#### Scenario: Empty history
- **WHEN** 不存在已保存的 AI summary history records
- **THEN** history surface SHALL 展示 empty state
- **AND** empty state SHALL NOT 暗示 subscription、product price、StoreKit、receipt 或 entitlement details

### Requirement: AI summary history capability gating
系统 SHALL 通过 `AppCapability.aiSummaryHistory` 控制 AI summary history 的保留额度和受限操作。

#### Scenario: Public default capability
- **WHEN** public repository 在没有 private overlay 的情况下运行
- **THEN** AI summary history 行为 SHALL 使用 Free/default baseline allowance
- **AND** public code SHALL NOT 查询 subscription plan、product ID、StoreKit transaction、receipt、price、Family Sharing、buyout state 或 raw entitlement state

#### Scenario: Enabled capability
- **WHEN** `AppCapability.aiSummaryHistory` enabled
- **THEN** 用户 SHALL 获得产品规则定义的 enabled history allowance 和 enabled history actions

#### Scenario: Capability disabled after records exist
- **WHEN** 用户已经保存 AI summary history records
- **AND** `AppCapability.aiSummaryHistory` 变为 disabled
- **THEN** 系统 SHALL NOT 自动删除这些 records
- **AND** 超出 active allowance 的 records SHALL 按产品规则应用 downgrade action restrictions
- **AND** 删除用户自有 records SHALL 保持可用

#### Scenario: Capability restored
- **WHEN** `AppCapability.aiSummaryHistory` 重新 enabled
- **THEN** previously restricted records SHALL 按产品规则恢复 enabled history actions

### Requirement: Commercial boundary for AI summary history
系统 SHALL 保持 public AI summary history runtime code 不包含商业实现细节。

#### Scenario: Public history code checks product capability only
- **WHEN** AI summary history code 需要判断 expanded history behavior 是否可用
- **THEN** 它 SHALL 使用 `AppCapability.aiSummaryHistory` 这样的 product-level capability decision
- **AND** 它 SHALL NOT 基于 `AccessDecision.source` 做业务分支
- **AND** 它 SHALL NOT import private StoreKit、purchase、restore、receipt、product、price、subscription、buyout 或 entitlement implementation details

#### Scenario: Public history records store product data only
- **WHEN** AI summary history records 被持久化
- **THEN** records SHALL 只保存 summary/history metadata 和 result content
- **AND** records SHALL NOT 保存 subscription state、buyout state、Family Sharing state、Apple receipt state、product IDs、prices 或 paid-feature persistence state

### Requirement: AI summary history ownership boundaries
系统 SHALL 将 AI summary history 的持久化和访问逻辑放在 screen-local implementation details 之外。

#### Scenario: History persistence is owned by a repository or service
- **WHEN** app 保存、列表、读取或删除 AI summary history
- **THEN** 这些操作 SHALL 由 focused repository、provider、service 或等价稳定 seam 负责
- **AND** screen/widget code SHALL NOT 直接持有 AI summary history 的 database schema、raw SQL 或 migration logic

#### Scenario: Dependency directions remain stable
- **WHEN** AI summary history 被实现
- **THEN** 它 SHALL NOT 引入 `state -> features`、`application -> features` 或 `core -> state|application|features` reverse dependencies
