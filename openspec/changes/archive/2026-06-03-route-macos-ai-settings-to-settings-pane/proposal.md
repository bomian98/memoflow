## Why

macOS 顶部菜单中的 `AI Settings` 当前直接通过 `_pushMacosMenuRoute(const AiSettingsScreen())` 打开普通主窗口 route。这个入口绕过了 `DesktopSettingsWindowApp`，因此 AI 设置根页面在 macOS 上使用普通 `Scaffold + AppBar` 外壳，而不是桌面设置窗口外壳，导致它和 Windows / 独立桌面设置窗口里的 AI 设置视觉与窗口 chrome 行为不一致。

近期已完成的桌面二级任务表面迁移解决的是 AI 服务新增和详情页的任务型子流程，不解决 AI 设置根页面入口外壳差异。本 change 先建立最小的目标化 settings window 路由能力，并只把 macOS `AI Settings` 菜单接入 AI 设置 pane，避免一次性迁移所有设置类菜单入口。

项目当前处于 `evolve_modularity` 阶段。本变更触及 `app.dart`、desktop settings window 和 macOS menu 导航热点，主要影响模块化清单中的 5（composition root 控制导航分发）、6（通过边界/路由 seam 协作而非直接页面 push）、8（guardrail 防止设置入口回退）和 10（触及区域保持结构不变或更好）。本 change 的结构改善是把“打开设置窗口并选中 AI pane”收敛到目标化 settings window seam，而不是在 macOS 菜单 handler 中继续直接构造设置页面。

## What Changes

- 为桌面设置窗口引入目标化打开语义，例如 `DesktopSettingsWindowTarget.ai` 或等价结构。
- 让 `openDesktopSettingsWindow(...)` 能接受目标 pane，并在打开/聚焦 settings window 后选中 AI pane。
- 让 `DesktopSettingsWindowApp` 能响应初始目标和后续目标请求，渲染 `AiSettingsScreen(showBackButton: false)` 所在 pane。
- 将 macOS `AI Settings` 菜单从直接 push `AiSettingsScreen` 改为请求目标化 settings window；失败时保留可见 fallback。
- 增加 focused tests / guardrail，防止 `macosMenuCommandAiSettings` 再直接 push `AiSettingsScreen`。

## Capabilities

### Modified Capabilities

- `macos-app-menu`: 补充 `AI Settings` 这类设置类菜单命令应路由到目标化 settings window。
- `macos-settings-window`: 补充 settings window 支持目标 pane 打开、聚焦和 fallback。

## Impact

- Affected app files: `memos_flutter_app/lib/app.dart`, `memos_flutter_app/lib/application/desktop/desktop_settings_window.dart`, `memos_flutter_app/lib/features/settings/desktop_settings_window_app.dart`, `memos_flutter_app/lib/core/desktop_quick_input_channel.dart` or equivalent command constants.
- Affected tests/guardrails: macOS menu command tests/guardrails, desktop settings window app tests, architecture guardrail preventing direct `AiSettingsScreen` push for `macosMenuCommandAiSettings`.
- Public/private boundary: 不引入订阅、付费、StoreKit、entitlement、receipt、paywall、private overlay 或 `AccessDecision.source` 业务分支。
- Out of scope: 不迁移 `AI Provider`、快捷键、模板、图床、位置等其他设置类菜单；它们由后续 `unify-macos-settings-menu-target-routing` change 扫描和迁移。
