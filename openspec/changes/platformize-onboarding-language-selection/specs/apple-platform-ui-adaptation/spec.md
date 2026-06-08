## ADDED Requirements

### Requirement: Apple onboarding language picker SHALL avoid Material-only inline dropdowns

Apple 平台 onboarding 语言选择 SHALL 使用平台 picker abstraction 呈现 enum selection，并 SHALL avoid 在 `CupertinoPageScaffold` body 中直接内嵌需要 `Material` ancestor 的 `DropdownButton` 作为主要交互控件。

#### Scenario: iPhone first setup renders language selector

- **WHEN** 用户首次在 iPhone 上进入 MemoFlow onboarding 语言选择页
- **THEN** 页面 SHALL render 当前语言 selector without Flutter framework errors
- **AND** selector SHALL be tappable to present the language options through a centered, bounded, scrollable platform picker abstraction

#### Scenario: iPadOS first setup uses same behavior

- **WHEN** 用户首次在 iPadOS 宽度下进入 MemoFlow onboarding 语言选择页
- **THEN** 页面 SHALL use the same shared onboarding language selector behavior
- **AND** implementation MUST NOT create a separate iPad-only onboarding page tree

#### Scenario: Apple adaptation remains public-shell safe

- **WHEN** Apple onboarding language picker behavior is implemented in the public repository
- **THEN** it MUST NOT add StoreKit, subscription, entitlement, receipt, product ID, price, paywall, private overlay, or `AccessDecision.source` business branching logic
- **AND** platform adapter files MUST NOT import `features/*`, `state/*`, `application/*`, or `data/*`
