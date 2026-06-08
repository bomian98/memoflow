## ADDED Requirements

### Requirement: Onboarding enum selection SHALL use platform picker seams

迁移后的 onboarding flow 在呈现语言、模式、单选项或其他 enum/single-option 选择时 SHALL 通过平台 picker、popover、sheet、dialog 或等效 adaptive seam 表达选择意图，而不是在平台 page 内容中硬编码 Material-only dropdown 作为所有平台的交互。

#### Scenario: Onboarding language selection runs on Apple mobile page chrome

- **WHEN** 首次 setup 的语言选择运行在 iPhone 或 iPadOS 的 `PlatformPage` 内容中
- **THEN** 语言选择 SHALL 通过平台 picker seam 打开居中、宽高受限、内部可滚动的选项 surface
- **AND** 页面 MUST NOT 依赖 `CupertinoPageScaffold` 下存在隐式 `Material` ancestor 才能渲染语言选择控件

#### Scenario: Onboarding language selection runs on desktop

- **WHEN** 首次 setup 的语言选择运行在 macOS、Windows 或 Linux 桌面窗口中
- **THEN** 语言选择 SHALL 使用 bounded desktop picker/dialog 或等效平台 transient surface
- **AND** primary action 的桌面宽度约束和 onboarding 模式选择行为 MUST remain unchanged

#### Scenario: Onboarding state remains shared

- **WHEN** 用户在 onboarding 语言 picker 中选择新的 `AppLanguage`
- **THEN** 系统 SHALL 复用现有 device preferences mutation path 更新语言
- **AND** 平台 picker implementation MUST NOT introduce duplicate language state, platform-specific language models, or feature-specific copies of `AppLanguage`
