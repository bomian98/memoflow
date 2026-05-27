## 后续设置页迁移清单

本批次只迁移 `PreferencesSettingsScreen` 与 `ComponentsSettingsScreen`，其余设置页保留在 `settings_ui_drift_guardrail_test.dart` 的 legacy allowlist 中。后续每迁移一个页面，应同步移出 allowlist，并优先把页面级颜色、按钮、开关、卡片、`Scaffold` 和平台判断收敛到 settings UI seam。

## 优先级

1. `SettingsScreen`
   - 入口页影响最大，决定用户对设置系统统一性的第一印象。
   - 优先收敛页面 chrome、分组、导航行和入口图标/颜色。

2. `ImageBedSettingsScreen`
   - 与 `ComponentsSettingsScreen` 直接相连，用户会连续进入。
   - 优先复用 `SettingsPage`、`SettingsSection`、`SettingsToggleRow` 和 settings action variants。

3. `ImageCompressionSettingsScreen`
   - 同样是 Components 的下一级页面，应与 image bed 保持同一行密度、分组和操作按钮语义。

4. `WebDavSyncScreen`
   - 同步设置通常包含状态、操作和危险动作，适合验证 `SettingsAction` 是否覆盖 primary/secondary/danger。

5. `AiSettingsScreen`
   - 页面复杂度较高，适合在基础 seam 稳定后迁移，避免把 AI 特定布局过早抽象成通用 settings API。

6. `PasswordLockScreen`
   - 涉及安全状态、开关和动作反馈，迁移时需要重点确认行为不变。

7. `DesktopSettingsWindowApp`
   - 用来检验桌面窗口 shell 与 settings UI seam 的组合方式，迁移时应避免把桌面专用逻辑散回普通 settings screen。

## 本批次决策

- `SettingsToggleCard` 暂时保留为语义组件，但当前渲染收敛到 `SettingsToggleRow`。这样 Components 可以表达“较重的功能开关”语义，同时不再拥有独立卡片视觉系统；后续如果没有真实差异，可以在下一批迁移中折叠为 `SettingsToggleRow`。
- `PlatformExperience` 暂时作为 `PlatformTarget` 之上的 richer layer 并存，不在本批次替换所有 `PlatformTarget` caller。后续迁移应优先让新的平台判断询问 `formFactor`、`inputModel`、`windowModel`、`visualFamily` 或 `navigationModel`，而不是新增散落的 `TargetPlatform` / `isApple` / `isDesktop` 分支。
- 手动视觉验收仍需要在真实或等价运行环境中完成：phone width、iPad/tablet width、macOS desktop width，以及可用时的 Windows desktop width。
