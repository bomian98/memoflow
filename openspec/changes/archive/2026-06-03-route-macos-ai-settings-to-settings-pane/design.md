## Context

当前 macOS 菜单命令 handler 中，标准 Settings / Open Settings Window 已经通过 `openDesktopSettingsWindow(...)` 打开或聚焦独立设置窗口；但 `AI Settings` 作为 AI 菜单下的业务设置命令仍直接 push `AiSettingsScreen`。`DesktopSettingsWindowApp` 已经有 `_DesktopSettingsPane.ai`，并渲染 `AiSettingsScreen(showBackButton: false)`，说明目标 UI composition 已存在，缺口是“从菜单命令定位到指定 pane”的路由能力。

当前 `application/desktop/desktop_settings_window.dart` 还有一个未充分使用的 `DesktopSettingsWindowRouteIntent` seam。这个方向可以扩展为目标化 settings window 路由，而不是让 `core` 或 `application` 直接依赖 `features/settings` 页面。

## Goals / Non-Goals

**Goals:**

- macOS `AI Settings` 菜单打开或聚焦桌面设置窗口，并选中 AI 设置 pane。
- settings window 打开失败或不支持时，保留主窗口 fallback，确保用户始终看到可见设置界面。
- 建立可复用的 settings window target seam，但本 change 只接入 AI 设置。
- 保持 `AiSettingsScreen` 内容和已完成的 AI 服务任务表面迁移不变。
- 增加防回退检查，避免 `macosMenuCommandAiSettings` 回到直接 push 根页面。

**Non-Goals:**

- 不迁移 `AI Provider`、快捷键、模板、图床、位置、图片压缩等其他菜单项。
- 不重构 `AiSettingsScreen` 页面布局，不增加 macOS traffic-light padding。
- 不把 `AI Summary`、`AI Reports`、`Quick Prompts` 等非设置类 AI 功能塞入 settings window。
- 不改变 native macOS menu label、快捷键或菜单结构。
- 不引入任何商业/private overlay 行为。

## Decisions

### 1. 使用目标化 settings window seam，而不是页面级 padding

修复目标不是让普通 route 避开 traffic lights，而是让 macOS 菜单和桌面设置窗口使用同一个外壳。因此 `AI Settings` 菜单应调用类似：

```text
openDesktopSettingsWindow(target: DesktopSettingsWindowTarget.ai)
```

如果打开成功，settings window 内部选中 AI pane；如果失败，再 fallback 到主窗口 `AiSettingsScreen`。

### 2. target 是 settings window 的应用层路由语义

target 应定义在 `application/desktop/desktop_settings_window.dart` 或同等 desktop settings window seam 中，例如 enum / value object。它不能依赖 `features/settings/*` 页面类，也不能让 `core` 下层知道 feature 页面。`DesktopSettingsWindowApp` 作为 UI composition point 负责把 target 映射到 `_DesktopSettingsPane.ai`。

依赖方向保持为：

```text
app.dart / UI composition
    -> application/desktop settings window seam
        -> desktop_multi_window command constants

features/settings/desktop_settings_window_app.dart
    -> interprets target and renders feature screens
```

### 3. 目标请求需要覆盖“新窗口”和“已有窗口”

如果 settings window 还不存在，创建窗口时可通过 launch payload 或初始化请求记录目标；如果 settings window 已存在，应通过 `DesktopMultiWindow.invokeMethod` 发送目标请求，并聚焦窗口。

建议语义：

```text
openDesktopSettingsWindow(target: ai)
  ├─ ensure window exists
  ├─ show + focus
  ├─ send route target to settings sub-window
  └─ verify responsive / report failed
```

实现时可根据现有多窗口生命周期选择先 show/focus 再 route，或创建时携带 target 并在 ready 后再次 route；无论选择哪种，测试应覆盖已有窗口目标切换。

### 4. fallback 保持可见但不是主路径

当目标化 settings window 不支持或失败时，`app.dart` 可以继续 fallback 到 `AiSettingsScreen` 普通 route。fallback 是可见性保障，不是默认体验。guardrail 应允许 fallback 构造，但禁止 `macosMenuCommandAiSettings` 主路径直接 `_pushMacosMenuRoute(const AiSettingsScreen())` 后返回。

### 5. 与后续批量迁移解耦

本 change 只提供 `ai` target 和菜单接入。后续 change 可以复用同一 seam 增加 `desktopShortcuts`、`templates`、`imageBed` 等目标，不需要重新设计 settings window 打开结果、fallback 或 pane selection 机制。

## Risks / Trade-offs

- [Risk] settings window 创建早于目标消息处理，导致首次打开停留在默认 pane。Mitigation: 创建 payload 携带 initial target，或在 ping/refresh 后再次发送 target；测试覆盖首次打开目标 pane。
- [Risk] `DesktopSettingsWindowApp` 的 `_settingsRootResetToken` 当前会重置到 account pane，可能覆盖目标选择。Mitigation: target request 应在 session refresh 后生效，或 refresh 时保留 pending target。
- [Risk] guardrail 过强导致 fallback 也被禁止。Mitigation: guardrail 检查主 command case 的主路径，不禁止失败 fallback 构造 `AiSettingsScreen`。
- [Risk] 增加 target seam 时让 `application` 导入 feature 页面。Mitigation: target 只包含稳定枚举/字符串，不包含 widget builder。

## Open Questions

- target request method 是否复用 `desktopSettingsFocusMethod` 的 arguments，还是新增 `desktopSettingsOpenTargetMethod` 更清晰。
- 初始 target 应放在 `DesktopMultiWindow.createWindow` payload，还是只通过窗口创建后的 invoke method 传递。
