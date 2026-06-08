## ADDED Requirements

### Requirement: Mobile settings home SHALL present layered function hierarchy
手机端设置首页 SHALL 使用 settings-owned UI tokens 或 approved settings/platform seam 表达 profile card、quick shortcut tiles、grouped function sections 和 single-row section 的层级。该层级 SHALL 通过背景、圆角、轻阴影或暗色等价边界、分割线和间距区分功能入口，而不是通过 `settings_screen.dart` 中的 page-local color/shadow/radius 硬编码实现。

#### Scenario: Profile and shortcuts use home card hierarchy
- **WHEN** 手机端设置首页渲染用户 profile 入口和顶部 quick shortcut tiles
- **THEN** profile 入口 SHALL 使用比普通 row 更突出的 home card surface、圆角、间距和 light/dark mode 层级 token
- **AND** quick shortcut tiles SHALL 作为独立功能卡片渲染，彼此通过卡片背景、间距和边界直接区分
- **AND** 这些视觉值 SHALL 来自 settings-owned home hierarchy tokens 或 approved settings/platform seam

#### Scenario: Function rows remain grouped by section
- **WHEN** 手机端设置首页渲染使用指南、账号与安全、偏好设置、AI 设置、应用锁、实验室、功能组件、反馈、充电站、导入/导出、关于或 equivalent function entries
- **THEN** 普通功能入口 SHALL 默认使用 grouped card + row divider 模型表达分组关系
- **AND** 单行分组 MAY 使用 single-row card treatment 保持与其他功能分组一致的层级
- **AND** 每个普通 function row SHALL NOT 被强制拆成独立卡片，除非该入口属于明确的 shortcut tile 或 approved special entry

#### Scenario: Secondary settings pages are not forced into home card treatment
- **WHEN** 用户从设置首页进入二级或三级设置页面
- **THEN** 这些页面 SHALL 继续使用标准 `SettingsPage`、`SettingsSection`、settings row surface tokens 或 approved settings/platform seam
- **AND** 手机端设置首页的重层级卡片、快捷入口布局或 home-only shadow treatment SHALL NOT 自动套用到二级/三级表单页

#### Scenario: Desktop settings keeps dense presentation
- **WHEN** 设置首页运行在 macOS、Windows 或 Linux desktop experience
- **THEN** desktop presentation SHALL preserve bounded, dense, work-focused settings layout
- **AND** it SHALL NOT be forced to use mobile-only large-radius, heavy-shadow, or oversized shortcut-card geometry

#### Scenario: Home hierarchy preserves existing behavior and exceptions
- **WHEN** 设置首页渲染导航入口、private extension entries、头像、真正按钮、danger/error action、theme swatch、custom color preview、media overlay、native picker 或 window controls
- **THEN** 本 requirement SHALL preserve existing navigation, haptics, route targets, private extension ordering, avatar rendering, semantic exception visuals, and true button color customization
- **AND** home hierarchy tokens SHALL NOT override semantic danger/error colors, preview colors, media/native/system surfaces, or app-wide button theme behavior

#### Scenario: Mobile settings home hierarchy is guarded
- **WHEN** 新增或修改设置首页、settings UI seam 或 migrated settings files
- **THEN** verification SHALL cover mobile settings home hierarchy for profile card, shortcut tiles, grouped function sections, row dividers, and light/dark mode token use
- **AND** architecture/style guardrails SHALL fail or require a documented exception if ordinary settings home hierarchy introduces page-local background, border, divider, shadow, radius, or raw palette styling outside the approved settings seam
