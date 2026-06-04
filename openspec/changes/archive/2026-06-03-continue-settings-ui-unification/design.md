## Context

已有 `unify-settings-ui-platform-experience` 批次完成了 `SettingsPage`、`SettingsSection`、`SettingsNavigationRow`、`SettingsValueRow`、`SettingsToggleRow`、`SettingsFeatureModule` 和 `SettingsAction` 等 settings-owned UI seam，并把 `PreferencesSettingsScreen`、`ComponentsSettingsScreen`、`DesktopSettingsScreen`、`DesktopShortcutsSettingsScreen` 加入 migrated coverage。

剩余问题集中在用户最容易连续看到的路径：

```text
SettingsScreen
  └─ ComponentsSettingsScreen
       ├─ ImageBedSettingsScreen
       └─ ImageCompressionSettingsScreen
```

`SettingsScreen` 虽然已经使用 `PlatformBoundedContent` / `PlatformListSection`，但仍直接解析 `MemoFlowPalette` 并维护 `_ProfileCard`、`_ShortcutTile`、`_CardGroup`、`_SettingRow`。`ImageBedSettingsScreen` 和 `ImageCompressionSettingsScreen` 仍使用 page-local `Scaffold`、透明 `AppBar`、背景/card/text token、`_ToggleCard`、`_Group`、`_SwitchRow`、`_SelectRow`、`_StepperRow`、裸 `Switch` 和私有输入行。

依赖方向现状：

```text
features/settings screens
  ├─ state/settings providers
  ├─ platform widgets
  ├─ core route/chrome helpers
  └─ screen-local UI widgets

settings_ui.dart
  └─ platform widgets + platform experience + core visual tokens
```

本变更后的方向保持不向 `state`、`application`、`core` 添加新的 `features/*` 依赖。settings screens 继续作为 feature UI composition point 读取既有 providers；共享设置页视觉和 controls 收敛到 `settings_ui.dart` 或 platform widgets。该结构改善对应 `evolve_modularity` 阶段的 scoped modularity improvement：减少 screen-local reusable UI 逻辑，并收紧 settings UI drift guardrail。

## Goals / Non-Goals

**Goals:**

- 让 `SettingsScreen`、`ImageBedSettingsScreen`、`ImageCompressionSettingsScreen` 与 `PreferencesSettingsScreen` / `ComponentsSettingsScreen` 在页面 chrome、背景、section、row、toggle、action 和桌面宽度规则上使用同一套 settings semantic seam。
- 保留现有业务行为：设置首页导航、private extension entry、donation entry、图床 provider/输入/重试/保存、图片压缩 mode/output/lossless/resize/quality/size 行为都不改变。
- 扩展 `settings_ui.dart` 时只抽取本批迁移真实重复的 UI 语义，例如 input row、select/menu row、stepper row、warning/info row；不提前抽象 WebDAV 或 AI 的复杂页面形态。
- 将完成迁移的文件从 `settings_ui_drift_guardrail_test.dart` legacy allowlist 移到 migrated coverage。
- 补 focused widget tests 和 architecture guardrail verification，证明行为不变、视觉 seam 收敛、public settings shell 不引入商业/private 逻辑。

**Non-Goals:**

- 不迁移 `WebDavSyncScreen`。该文件包含 WebDAV 主设置、连接页、备份页、日志页、冲突 dialog、加密备份等多个流程，后续应单独拆批。
- 不迁移 `AiSettingsScreen`、`PasswordLockScreen`、`DesktopSettingsWindowApp` 或所有 remaining settings pages。
- 不改变 provider owner、model、repository、API route、持久化 schema、localization key 范围或桌面设置窗口 target routing。
- 不把 Components 的 `SettingsFeatureModule` 视觉套到所有设置详情页。功能管理页使用复合开关列表；普通详情页使用 section + row + input/action。

## Decisions

### 1. 首批后续迁移只覆盖三个高感知页面

本 change 迁移 `SettingsScreen`、`ImageBedSettingsScreen` 和 `ImageCompressionSettingsScreen`。这三页覆盖设置入口、功能组件列表后的直接详情页，以及常见 controls（导航、输入、选择、开关、stepper、warning、actions）。

Alternative considered: 一次迁移所有 settings 页面。拒绝，因为 allowlist 中仍有 WebDAV、AI、安全、导入导出、迁移等复杂页面，批量迁移会把视觉 cleanup 和业务风险混在一起，难以验证。

Alternative considered: 先迁移 `WebDavSyncScreen`。拒绝，因为它是 4000+ 行的复合流程文件，应该先由单独 change 分析页面拆分和任务表面，再做 UI seam 统一。

### 2. `SettingsScreen` 作为首页导航，不承载功能开关

设置首页继续只负责帮助用户找到分类入口。实现时应保留 existing profile entry、shortcut entries、extension entries、version footer 和 close/navigation semantics，但把可复用的入口 row/tile/profile 视觉收敛成 settings-owned semantic widgets 或通过现有 `SettingsNavigationRow` / `SettingsSection` 组合表达。

首页入口 icon 默认使用中性色；不为每个入口保留独立 card/shadow/radius 系统。Donation entry 和 private extension bundle seam 继续公开存在，不引入 capability、subscription 或 private runtime checks。

Alternative considered: 直接把所有首页入口改成普通 `SettingsNavigationRow`。可行但可能损失 profile 和快捷入口的现有信息层级；实现时可以保留语义差异，但视觉 token 必须来自 settings seam。

### 3. 图床和图片压缩详情页迁移为 section + row + form controls

`ImageBedSettingsScreen` 和 `ImageCompressionSettingsScreen` 不是功能管理列表，不应使用 `SettingsFeatureModule`。它们应使用：

- `SettingsPage` 承载标题、back、背景、desktop bounded content。
- `SettingsSection` 承载 provider、basics、resize、limits、advanced 等分组。
- `SettingsToggleRow` / `SettingsToggleCard` 表达开关。
- settings-owned input/select/stepper/warning/action seam 表达输入框、短选项、数值调整、提示和保存/测试操作。

如果现有 `settings_ui.dart` 不足以表达这些 controls，可以新增小型通用组件，但必须从真实重复语义出发。比如 `SettingsInputRow` 可以封装 `PlatformTextField` 和 row density；`SettingsStepperRow` 可以封装减/加按钮与数值显示；`SettingsWarningRow` / `SettingsInfoRow` 可以表达 section 内提示。

Alternative considered: 在每个页面保留私有 `_InputRow`、`_StepperRow`，只换外层 `SettingsPage`。拒绝，因为这会让可复用设置表单逻辑继续藏在 screen-local widgets，不满足本 change 的模块化改善目标。

### 4. Guardrail 作为迁移完成标准

迁移完成后，`settings_ui_drift_guardrail_test.dart` 应：

- 从 legacy allowlist 移除 `settings_screen.dart`、`image_bed_settings_screen.dart`、`image_compression_settings_screen.dart`。
- 将这些文件加入 migratedFiles。
- 对 migrated files 继续阻止 direct `Scaffold`、bare `Switch` / `Switch.adaptive`、page-local `styleFrom`、private `_ToggleCard` 和 direct `MemoFlowPalette`，除非有极窄且注释清楚的 page-specific preview/editor allowance。

Alternative considered: 只做人工 review。拒绝，因为 settings UI drift 是持续迁移问题，guardrail 是后续批次保持方向一致的低成本保护。

### 5. 测试按行为风险分层

本 change 不需要 broad golden 测试。更合适的是 focused widget/source tests：

- `SettingsScreen`：bounded content、入口存在、private extension entries、desktop settings gate、donation entry/public boundary 仍通过。
- `ImageBedSettingsScreen`：enabled toggle、provider selection、base URL normalization、关键输入持久化或 provider notifier 调用不变。
- `ImageCompressionSettingsScreen`：enabled toggle、mode/output selection、resize controls、warning visibility、数值 stepper 行为不变。
- Architecture guardrail：migrated files 不再使用 legacy visual primitives。

如果实际实现发现 widget tests 难以稳定覆盖某个控件，应优先补 source/guardrail coverage 和少量 provider-focused test，而不是扩大到 fragile screenshot expectations。

## Risks / Trade-offs

- [Risk] `SettingsScreen` 既是 settings 首页又参与桌面 destination shell，迁移外层 `SettingsPage` 可能破坏 close/drawer/embedded presentation 行为。→ Mitigation: 迁移首页内容和入口组件优先，保留现有 `PlatformPage` / `DesktopDestinationShell` composition，只有在能保持语义一致时才替换外层。
- [Risk] 图床和图片压缩页面的私有 rows 承载了输入、stepper、enable/disable 和 dirty state 等行为，视觉迁移可能误改业务逻辑。→ Mitigation: 先抽 UI seam，再把现有 callback/state wiring 原样接入，补 focused tests 覆盖关键交互。
- [Risk] 新增太多 settings_ui 组件会把页面特定概念过早通用化。→ Mitigation: 只抽取通用 setting control 语义；provider-specific copy、validation、domain labels 保留在页面内。
- [Risk] 收紧 guardrail 暴露 additional legacy violations。→ Mitigation: 本 change 只要求三个 migrated files 通过；其他 settings 文件继续留在 legacy allowlist，后续逐步缩小。
- [Risk] 视觉“统一”被误解成所有页面必须采用 Components 复合开关样式。→ Mitigation: design 和 spec 明确首页、功能管理页、详情设置页承担不同职责，但共享 settings semantic seam。

## Migration Plan

1. 扩展或复用 `settings_ui.dart` 的 settings-owned row/action seam，先覆盖本批图床和图片压缩真实 controls。
2. 迁移 `SettingsScreen` 内容区入口组件，保留 shell/navigation/close/private extension/donation 行为。
3. 迁移 `ImageBedSettingsScreen` 页面 chrome、sections、toggle、select、input、stepper 和 actions。
4. 迁移 `ImageCompressionSettingsScreen` 页面 chrome、sections、toggle、select/menu、stepper、warning 和 actions。
5. 更新 focused tests 和 `settings_ui_drift_guardrail_test.dart` migrated coverage。
6. 运行 focused settings tests、architecture guardrail、`flutter analyze`，再按需要运行 broader `flutter test`。

Rollback strategy: 如果某个详情页迁移产生高风险回归，可以先保留已抽取的 settings seam 和 `SettingsScreen` 迁移，只将该详情页暂时留在 legacy allowlist；但已完成迁移的文件不应回退到 page-local visual primitives。

## Open Questions

- `SettingsScreen` 的 profile entry 是否应抽成正式 `SettingsProfileEntry` 语义组件，还是先保留 settings-screen-local composition 但使用 `settingsPageTokens` / `SettingsSection`？实现时可根据重复性决定。
- `SettingsStepperRow` 是否足够通用到 `settings_ui.dart`，还是只在图床和图片压缩之间提取 feature-local helper？如果只有本批两页使用，仍可放在 settings UI seam，但 API 应保持窄。
