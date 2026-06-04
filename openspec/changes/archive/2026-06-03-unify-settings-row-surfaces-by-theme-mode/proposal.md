## Why

当前设置 UI 已经完成大面积 seam 化，但设置页面右侧的分组、设置行、右侧值区域、hover/pressed/selected 状态仍然可能来自不同页面的局部背景色、透明度和边框处理。用户期望按照亮色/暗色模式统一这些“设置行/设置单元格”的背景视觉，例如 `语言`、`字号`、`行高`、`字体`、`启动动作`、`主题色` 等设置项所在的行，而不是修改真正的 app 按钮颜色。

真正的按钮颜色仍然需要保持可自定义或按现有主题色策略解析，本 change 不应把登录、继续、保存、重试等按钮改成固定背景色。

## What Changes

- 统一设置页面右侧 `SettingsSection`、设置行、值区域、分割线、hover、pressed、selected、disabled 等 row/cell surface tokens。
- 按 `Brightness.light` / `Brightness.dark` 分别定义设置行背景、分组背景、边框、分割线和交互态，贴近用户提供的亮色/暗色效果图。
- 收敛设置页面里 page-local row/card/background styling，让设置项背景优先来自 `settings_ui.dart`、settings token、`ThemeData` 或 approved platform/settings seam。
- 保留真正按钮的颜色自定义能力：`FilledButton`、`ElevatedButton`、`OutlinedButton`、`TextButton` 和 `PlatformPrimaryAction` 的普通按钮色不作为本 change 的目标。
- 保留语义例外：危险/错误操作、主题色 swatch、颜色选择预览、媒体/图片预览 overlay、系统文件/图片选择器、系统窗口控制按钮不纳入设置行背景统一。
- 增加或更新 settings UI drift guardrail，防止已迁移设置页面重新引入局部 row/card 背景硬编码。

## Capabilities

### New Capabilities
- 无。

### Modified Capabilities
- `platform-adaptive-ui-system`: 增加设置页面 row/cell/section surface 必须按明暗模式统一解析的要求，并明确真正按钮颜色自定义、危险/错误、颜色预览、媒体 overlay、系统选择器和窗口控制等例外范围。

## Impact

- 主要影响 `memos_flutter_app/lib/features/settings/settings_ui.dart`、设置页面 token/seam、以及仍有局部设置行/分组背景样式的 settings feature 页面。
- 不改变全 app 普通按钮主题，不固定用户可自定义的按钮/主题色策略。
- 不改变 API、数据模型、数据库、WebDAV 同步、商业/订阅能力或 private hooks。
- 当前架构阶段为 `evolve_modularity`。本变更触及 settings UI 这一耦合热点，实施时需要通过集中 settings row surface tokens 和 guardrail 来满足模块化清单第 `7`、`8`、`9`、`10` 项，并避免新增 `state -> features`、`application -> features` 或 `core -> features` 反向依赖。
