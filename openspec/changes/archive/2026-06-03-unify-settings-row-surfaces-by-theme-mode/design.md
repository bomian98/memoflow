## Context

用户提供的亮色/暗色效果图关注的是设置页右侧的设置项背景：例如 `语言`、`字号`、`行高`、`字体`、`启动动作`、`主题色` 等行所在的分组 surface、row surface、分割线和交互态。这里的“按钮”并不是 Material button，而是设置 UI 中可点击的 row/cell。

设置 UI 已经有 `memos_flutter_app/lib/features/settings/settings_ui.dart` 这样的 settings-owned seam，以及 `SettingsPage`、`SettingsSection`、settings rows/actions 等语义组件。正确方向是把设置行背景继续收敛到 settings seam，而不是改全 app 的 `FilledButton`、`ElevatedButton`、`OutlinedButton`、`TextButton` 或 `PlatformPrimaryAction`。

依赖方向现状：

- Before: 部分 settings 页面仍可能用局部 `Container`、`Card`、`DecoratedBox`、`BorderSide`、`MemoFlowPalette`、透明度或直接 `colorScheme` 组合来表达设置行/分组背景。
- After: 设置页面 row/cell/section 的背景、边框、分割线和交互态由 `settings_ui.dart` 或同层 settings token/seam 统一解析；各 settings 页面只表达设置项语义、内容和值。

本 change 不触碰 API、数据模型、同步协议、数据库、商业/订阅逻辑或 private hooks。当前架构阶段是 `evolve_modularity`，本 change 触及 settings UI 热点，需要通过设置 row surface token 集中化和 guardrail 让 touched area 至少不变差。

## Goals / Non-Goals

**Goals:**

- 为设置页面右侧分组、设置行、值区域、分割线、hover、pressed、selected、disabled 状态定义按 `Brightness.light` / `Brightness.dark` 解析的统一 surface tokens。
- 让 `SettingsSection`、settings row 组件、settings action/value/toggle/navigation rows 默认使用同一套设置 row/cell 背景视觉。
- 清理已迁移 settings 页面中绕过 settings seam 的普通设置行/分组背景硬编码。
- 保持真正按钮颜色可自定义，避免把 app 普通按钮背景改成固定颜色。
- 明确例外：危险/错误操作、主题色 swatch、颜色选择预览、媒体/图片预览 overlay、系统 picker、窗口控制按钮和 OS native surface。
- 增加或更新 guardrail，防止 settings 页面重新引入局部 row/card 背景漂移。

**Non-Goals:**

- 不统一全 app Material buttons 的背景色，不修改登录、继续、保存、重试等真正按钮的主题策略。
- 不修改用户主题色系统，不移除按钮颜色自定义能力。
- 不重做 settings 信息架构、页面顺序、文案、业务逻辑或 provider 行为。
- 不修改 Switch、SegmentedButton、Chip、IconButton、媒体 overlay、系统 picker、window controls，除非它们作为设置行的一部分需要对齐 row surface 外围背景。
- 不引入新依赖、不增加商业功能、不改 API 或数据层。

## Decisions

1. **以 settings-owned surface tokens 作为设置行背景 source of truth。**

   - 方案：在 `settings_ui.dart` 或同层 settings token 文件中定义 light/dark 的 section background、row background、row hover、row pressed、row selected、divider、border、value area foreground/background 等 token。
   - 理由：设置行背景属于 settings UI 语义，不应该散落到每个 settings 页面，也不应该放到全 app button theme。
   - Alternative considered: 修改全局 `CardTheme` 或 `ButtonTheme`。该方案会影响 settings 以外的卡片/按钮，不符合用户目标。

2. **设置页面消费语义 row/seam，而不是自行画背景。**

   - 方案：已迁移 settings 页面继续使用 `SettingsSection`、`SettingsNavigationRow`、`SettingsValueRow`、`SettingsToggleRow`、`SettingsAction` 或等价 seam；局部只传内容和值，不直接决定 row/cell 背景。
   - 理由：这能把“设置项长相”统一到一个地方，后续改亮色/暗色效果只需改 token。
   - Alternative considered: 每个页面按截图手动调色。该方案短期快，但会让后续 AI、桌面、偏好等页面再次分裂。

3. **真正按钮颜色明确排除。**

   - 方案：本 change 不修改 `FilledButtonThemeData`、`ElevatedButtonThemeData`、`OutlinedButtonThemeData`、`TextButtonThemeData` 的 app-wide 普通按钮色，也不移除按钮对当前主题色/自定义色的依赖。
   - 理由：用户希望按钮颜色仍可自定义，实际诉求是设置 row/cell background 统一。
   - Alternative considered: 顺手统一按钮和设置行。该方案会扩大范围，并造成用户不希望的按钮颜色变化。

4. **用 allowlist 表达合法例外。**

   - 方案：对危险/错误操作、主题色 swatch、颜色预览、媒体 overlay、native picker、window controls 等不适合 settings row surface token 的场景保留局部或系统视觉，并在 guardrail allowlist 中说明原因。
   - 理由：设置页面里主题色圆点、危险重置、系统选择器入口和媒体相关 UI 需要不同语义。
   - Alternative considered: 所有 setting-related UI 都强制同一背景。该方案会削弱语义和可读性。

5. **模块化边界保持在 settings/platform seam 内。**

   - 方案：settings surface token 放在 settings-owned UI seam 或 approved platform/settings seam；不得为了背景统一让 `core`、`platform`、`state` 或 `application` 导入 settings feature 页面。
   - 理由：符合 `evolve_modularity`，并把 touched settings UI 的视觉 owner 收敛到明确 seam。
   - Alternative considered: 在某个具体 settings 页面提取 helper 给其他页面复用。该方案会产生 settings 页面之间的隐性耦合。

## Risks / Trade-offs

- [Risk] 设置 row surface 统一后，某些页面的局部强调感下降 → Mitigation: 保留 selected/danger/value/swatch 等语义 token，不把所有行做成完全同色。
- [Risk] guardrail 误伤合法的主题色 swatch 或颜色预览 → Mitigation: allowlist 记录颜色预览/编辑 UI 例外，并只阻止普通设置行/分组背景硬编码。
- [Risk] 只改 settings seam 不能影响尚未迁移的遗留设置页面 → Mitigation: tasks 要求 audit 仍有局部 row/card 背景的 settings 页面，并迁移或明确 allowlist。
- [Risk] 亮色/暗色截图效果需要细调 → Mitigation: 先定义 token 和集中入口，再通过人工/截图检查微调 token，而不是在页面局部改色。
