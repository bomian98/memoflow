## Context

上一轮 `unify-settings-row-surfaces-by-theme-mode` 已经把 settings row/section 的背景、边框、分割线和交互态集中到 `settingsPageTokens` 与 `PlatformListSectionStyle`。这解决了“颜色来源不统一”的问题，但没有专门处理手机端设置首页的信息层级。

用户提供的手机端效果图表达的是另一层需求：设置首页应先呈现 profile 大卡片，再呈现三个独立快捷功能卡片，然后通过 grouped section 区分普通功能入口。视觉层次来自更明显的卡片背景、圆角、轻阴影、分组间距和行分割线，而不是每个页面各自手写颜色。

当前相关结构：

- `SettingsScreen` 组装设置首页内容。
- `SettingsHomeProfileEntry`、`SettingsHomeShortcutTile`、`SettingsSection`、`SettingsNavigationRow` 定义首页入口和分组语义。
- `settingsPageTokens` 已经是 settings-owned token seam。
- `PlatformListSection` 是跨平台 list/section presentation seam。

依赖方向：

- Before: `settings_screen.dart` 直接组合 settings UI widgets，视觉层级部分由各 widget 当前默认样式决定。
- After: `settings_screen.dart` 仍只表达设置首页结构和导航语义；手机端 home hierarchy 的颜色、圆角、阴影、间距和 section treatment 由 `settings_ui.dart` 或 approved settings/platform seam 集中提供。

本 change 不触碰 API、数据模型、数据库、同步、AI provider 业务、private hooks 或商业逻辑。当前架构阶段是 `evolve_modularity`，settings UI 是耦合热点，因此本 change 需要通过新增 settings-owned home hierarchy seam/token 和 guardrail，让 touched area 更集中而不是更分散。

## Goals / Non-Goals

**Goals:**

- 让手机端设置首页 profile、shortcut tiles、function sections、single-row section 有清晰层级：卡片背景、圆角、轻阴影、分割线和间距符合用户参考图方向。
- 保持普通功能入口使用 grouped card + row divider 模型，避免把每个 row 都拆成独立卡片导致页面碎片化。
- 将 home hierarchy style 放在 `settings_ui.dart`、`settingsPageTokens` 或 approved settings/platform seam，避免 `settings_screen.dart` 产生 page-local color/shadow/radius 硬编码。
- 保持桌面端设置窗口克制、密集、工作型的布局，不强制套用手机端重阴影卡片视觉。
- 保持二级/三级设置页的 settings row/section 统一 surface，不因首页视觉增强而整体变重。
- 增加 focused widget tests 和 guardrail，覆盖手机端设置首页层级样式和真正按钮主题不被改动。

**Non-Goals:**

- 不修改 `FilledButton`、`ElevatedButton`、`OutlinedButton`、`TextButton`、`PlatformPrimaryAction` 的全 app 颜色策略。
- 不调整设置首页的信息架构、入口顺序、导航目标、业务 provider、private extension entry 行为或本地库/account 逻辑。
- 不重做二级/三级页面的卡片层级，不把所有 settings row 都变成移动端大卡片。
- 不修改头像图片、主题色 swatch、颜色预览、危险/错误操作、系统 picker、媒体 overlay 或窗口控制的语义视觉。
- 不引入新依赖或新图片资源。

## Decisions

1. **新增或扩展 settings-owned home hierarchy tokens，而不是在 `settings_screen.dart` 局部写样式。**

   - 方案：在 `settingsPageTokens` 或相邻 settings UI seam 中增加 home-specific tokens，例如 home card background、home card border、home shadow、home card radius、home section spacing、shortcut tile height/spacing、mobile-only divider strength。
   - 理由：设置首页属于 settings feature 的 presentation，但样式 owner 应集中在 `settings_ui.dart`，后续调明暗模式或平台差异只改一个地方。
   - Alternative considered: 直接在 `SettingsScreen` 中给每个 `Material` / `Container` 写 `BoxDecoration`。这会绕过刚建立的 settings surface seam，后续容易再次漂移。

2. **把手机端首页层级做成 home variant/seam，不改 `SettingsSection` 全局默认。**

   - 方案：通过 `SettingsHomeSection`、`SettingsSectionVariant.home`、或等价 settings-owned wrapper 表达“首页分组卡片”。默认 `SettingsSection` 继续服务二级/三级设置页。
   - 理由：参考图的圆角和阴影更适合手机端设置首页。如果直接改 `SettingsSection` 或 `PlatformListSection` 默认值，所有二级/三级页也会变成更重的卡片，降低信息密度。
   - Alternative considered: 全局提高 `PlatformListSection` radius/shadow。该方案影响面过大，也会改变桌面与表单页的既有密度。

3. **快捷入口保持独立卡片，普通功能入口保持 grouped section。**

   - 方案：`SettingsHomeShortcutTile` 使用独立 card surface；`SettingsNavigationRow` 在首页普通功能区仍放在 grouped section 内，通过 divider 分隔。
   - 理由：用户参考图中的三个快捷入口是独立卡片，而普通功能项是分组列表。这个模型层次清晰且滚动负担较小。
   - Alternative considered: 所有功能行都变成独立卡片。该方案层次强但会显得碎、长、重复，并削弱“同一组设置”的关系。

4. **平台差异由 settings/platform seam 判断，而不是页面局部判断。**

   - 方案：手机端使用更大 radius、轻阴影和更松间距；桌面端保留较小 radius、弱边框、少阴影或无阴影。判断逻辑应在 settings UI seam 或 approved platform experience helper 中完成。
   - 理由：避免 `settings_screen.dart` 增加散落的 `TargetPlatform` / width 分支。
   - Alternative considered: 在首页 build 方法中按平台写不同 decoration。该方案短期直接，但会增加 settings 首页的 presentation 分支复杂度。

5. **测试和 guardrail 跟随 home hierarchy seam。**

   - 方案：添加 widget test 覆盖手机端 `SettingsScreen` 的 profile、shortcut tile、function section 使用 home tokens/semantics；更新 drift guardrail，允许 settings UI seam 拥有 home hierarchy tokens，但阻止 migrated settings screen 引入 page-local color/shadow/radius 漂移。
   - 理由：这个需求本质是视觉一致性，缺少测试会让后续页面迁移重新写局部卡片样式。
   - Alternative considered: 只做人工截图检查。截图检查有价值，但不能防止后续回归。

## Risks / Trade-offs

- [Risk] 手机端阴影和大圆角过强，可能让设置页看起来过于营销化 → Mitigation: 使用轻阴影、克制的 elevation，并只在设置首页使用，不扩散到二级/三级表单页。
- [Risk] 首页 section variant 增加一个 settings UI seam → Mitigation: 保持 API 小而语义明确，只服务 home hierarchy，不引入通用但模糊的 card builder。
- [Risk] iOS/Android 默认 list 语义与自定义 card hierarchy 冲突 → Mitigation: settings seam 只接管视觉 surface，不改变 navigation row、haptic、route、accessibility label 和 tap target 行为。
- [Risk] guardrail 误伤合法的头像、主题色、预览或系统 picker 视觉 → Mitigation: allowlist 继续明确 semantic preview/native/system/danger 例外，并只约束普通 settings home hierarchy。
- [Risk] 暗色模式层次不够或阴影不可见 → Mitigation: 为 dark mode 使用 subtle border/overlay，而不是依赖纯 shadow；实施后需要 light/dark 手机截图检查。
