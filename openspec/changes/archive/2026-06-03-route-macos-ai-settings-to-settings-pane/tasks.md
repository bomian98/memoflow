## 1. 准备和边界确认

- [x] 1.1 复查 `app.dart` 中 `macosMenuCommandAiSettings`、`macosMenuCommandOpenSettingsWindow` 的当前路径，确认 fallback 可见性需求。
- [x] 1.2 复查 `DesktopSettingsWindowApp` 的 `_DesktopSettingsPane.ai`、`desktopSettingsRefreshSessionMethod` 和 settings window focus/ping 生命周期。
- [x] 1.3 确认本 change 不修改 AI settings provider、repository、API、数据库 schema 或商业/private overlay 行为。

## 2. 目标化 Settings Window 路由

- [x] 2.1 在 desktop settings window seam 中新增 `DesktopSettingsWindowTarget` 或等价目标表达，至少包含 AI 设置目标。
- [x] 2.2 扩展 `openDesktopSettingsWindow(...)`，支持传入目标并在 settings window 打开/聚焦后发送目标请求。
- [x] 2.3 让 `DesktopSettingsWindowApp` 接收 initial / runtime target request，并选中 AI pane，保留已有 session refresh 和 workspace reload 行为。
- [x] 2.4 确保目标路由 seam 不引入 `application -> features` 或 `core -> features` 新依赖。

## 3. macOS AI Settings 菜单接入

- [x] 3.1 将 `macosMenuCommandAiSettings` 主路径改为打开目标化 settings window 的 AI pane。
- [x] 3.2 保留 settings window unsupported / failed 时的 `AiSettingsScreen` fallback，确保始终有可见界面。
- [x] 3.3 保持 `AI Summary`、`AI Reports`、`Quick Prompts`、`AI Provider` 等其他 AI 菜单项不在本 change 中迁移。

## 4. Guardrails And Tests

- [x] 4.1 增加 focused test，覆盖 `AI Settings` 菜单打开 settings window AI pane。
- [x] 4.2 增加或更新 settings window test，覆盖已有窗口接收 AI target 后切换 pane。
- [x] 4.3 增加 guardrail，防止 `macosMenuCommandAiSettings` 主路径直接 `_pushMacosMenuRoute(const AiSettingsScreen())`。
- [x] 4.4 检查 touched public files 不包含商业、订阅、付费、StoreKit、entitlement、private overlay 或 `AccessDecision.source` 业务分支。

## 5. 验证

- [x] 5.1 运行相关 macOS menu / settings window focused tests。
- [x] 5.2 运行相关 architecture guardrail tests。
- [x] 5.3 从 `memos_flutter_app` 运行 `flutter analyze`。
- [x] 5.4 运行 `openspec validate route-macos-ai-settings-to-settings-pane --strict`。
- [x] 5.5 在 macOS 手动验证 AI 菜单打开 AI 设置时进入桌面设置窗口 AI pane；失败 fallback 仍可见。
